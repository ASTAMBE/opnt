#!/usr/bin/env python3
"""
Auto-sync daily OHLCV for ALL tickers already present in stocks.MULTI_10Y_UTDT.

FINAL VERSION:
- Always sync through TODAY (assumes you run after market close)
- Writes BOTH:
    price_date_raw (varchar m/d/yyyy, no leading zeros)
    price_date     (DATE column)
- Uses MAX(price_date) DATE column to find missing days
- Prices rounded to 2 decimals
"""

import argparse
import os
import json
from dataclasses import dataclass
from datetime import date, datetime, timedelta
from decimal import Decimal, ROUND_HALF_UP
from typing import Dict, List, Optional

import pandas as pd
import yfinance as yf
import pymysql
from dotenv import load_dotenv


# ============================================================
# 1) LOAD ENV
# ============================================================

load_dotenv(r"C:\AST\GitHub\set_env.env")

DB_CONFIGS = {
    "DEV": {
        "host": os.getenv("DEV_DB_HOST"),
        "user": os.getenv("DEV_DB_USER"),
        "password": os.getenv("DEV_PWD"),
        "database": os.getenv("DEV_DATABASE"),
        "port": int(os.getenv("DEV_DB_PORT", "3306")),
    },
    "PROD": {
        "host": os.getenv("PROD_DB_HOST"),
        "user": os.getenv("PROD_DB_USER"),
        "password": os.getenv("PROD_PWD"),
        "database": os.getenv("PROD_DATABASE"),
        "port": int(os.getenv("PROD_DB_PORT", "3306")),
    },
}


def resolve_db_config(env_key: str) -> Dict:
    env_key = env_key.upper()
    if env_key not in DB_CONFIGS:
        raise KeyError(f"--env must be DEV or PROD. Got {env_key}")

    cfg = DB_CONFIGS[env_key]
    for k in ("host", "user", "password", "database"):
        if not cfg.get(k):
            raise ValueError(f"Missing env variable for {env_key}.{k}")
    return cfg


# ============================================================
# 2) HELPERS
# ============================================================

def to_varchar_mdy_nozeros(d: date) -> str:
    return f"{d.month}/{d.day}/{d.year}"


def r2(x: Optional[float]) -> Optional[float]:
    if x is None:
        return None
    return float(Decimal(str(x)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP))


# ============================================================
# 3) MYSQL HELPERS
# ============================================================

def get_connection(db_cfg: Dict) -> pymysql.connections.Connection:
    return pymysql.connect(
        host=db_cfg["host"],
        port=db_cfg["port"],
        user=db_cfg["user"],
        password=db_cfg["password"],
        database=db_cfg["database"],
        autocommit=False,
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
    )


def fetch_symbols(conn, explicit_symbols: Optional[List[str]] = None, max_symbols: Optional[int] = None) -> List[str]:
    if explicit_symbols:
        syms = [s.strip().upper() for s in explicit_symbols if s.strip()]
        return syms[:max_symbols] if max_symbols else syms

    sql = """
        SELECT DISTINCT symbol
        FROM stocks.MULTI_10Y_UTDT
        WHERE symbol IS NOT NULL AND symbol <> ''
        ORDER BY symbol
    """

    with conn.cursor() as cur:
        cur.execute(sql)
        rows = cur.fetchall()

    syms = [r["symbol"].strip().upper() for r in rows if r.get("symbol")]
    return syms[:max_symbols] if max_symbols else syms


def fetch_max_date_for_symbol(conn, symbol: str) -> Optional[date]:
    sql = """
        SELECT MAX(price_date) AS max_dt
        FROM stocks.MULTI_10Y_UTDT
        WHERE symbol = %s
    """

    with conn.cursor() as cur:
        cur.execute(sql, (symbol,))
        row = cur.fetchone()

    max_dt = row["max_dt"] if row else None
    if max_dt is None:
        return None
    if isinstance(max_dt, datetime):
        return max_dt.date()
    return max_dt


# ============================================================
# 4) FETCH + UPSERT
# ============================================================

@dataclass
class Bar:
    symbol: str
    d: date
    open: float
    high: float
    low: float
    close: float
    adj_close: Optional[float]
    volume: int


def fetch_daily_bars(symbol: str, start_d: date, end_d: date) -> List[Bar]:
    start_s = start_d.isoformat()
    end_s = (end_d + timedelta(days=1)).isoformat()

    df = yf.Ticker(symbol).history(interval="1d", start=start_s, end=end_s, auto_adjust=False)

    if df is None or df.empty:
        return []

    df = df.copy()
    df["__date__"] = pd.to_datetime(df.index).date

    bars: List[Bar] = []
    for _, row in df.iterrows():
        d = row["__date__"]
        bars.append(
            Bar(
                symbol=symbol,
                d=d,
                open=float(row["Open"]),
                high=float(row["High"]),
                low=float(row["Low"]),
                close=float(row["Close"]),
                adj_close=float(row["Adj Close"]) if "Adj Close" in row and pd.notna(row["Adj Close"]) else None,
                volume=int(row["Volume"]) if pd.notna(row["Volume"]) else 0,
            )
        )
    return bars


def upsert_bar(conn, b: Bar, dry_run: bool = False) -> None:
    sql = """
        INSERT INTO stocks.MULTI_10Y_UTDT
            (price_date_raw, price_date, symbol, price_open, price_hi, price_lo, price_close, adj_close, volume)
        VALUES
            (%s,            %s,         %s,     %s,         %s,       %s,       %s,          %s,        %s)
        ON DUPLICATE KEY UPDATE
            price_date_raw = VALUES(price_date_raw),
            price_date     = VALUES(price_date),
            price_open     = VALUES(price_open),
            price_hi       = VALUES(price_hi),
            price_lo       = VALUES(price_lo),
            price_close    = VALUES(price_close),
            adj_close      = VALUES(adj_close),
            volume         = VALUES(volume)
    """

    values = (
        to_varchar_mdy_nozeros(b.d),
        b.d,
        b.symbol,
        r2(b.open),
        r2(b.high),
        r2(b.low),
        r2(b.close),
        r2(b.adj_close) if b.adj_close is not None else None,
        b.volume,
    )

    if dry_run:
        return

    with conn.cursor() as cur:
        cur.execute(sql, values)


# ============================================================
# 5) MAIN
# ============================================================

def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--env", default="DEV")
    p.add_argument("--symbols", default=None)
    p.add_argument("--max-symbols", type=int, default=None)
    p.add_argument("--end-date", default=None)
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--verbose", action="store_true")
    args = p.parse_args()

    db_cfg = resolve_db_config(args.env)

    # ALWAYS include today
    end_d = date.today()
    if args.end_date:
        end_d = datetime.strptime(args.end_date, "%Y-%m-%d").date()

    explicit = args.symbols.split(",") if args.symbols else None

    conn = get_connection(db_cfg)
    total_upserted = 0

    try:
        symbols = fetch_symbols(conn, explicit_symbols=explicit, max_symbols=args.max_symbols)

        for sym in symbols:
            max_dt = fetch_max_date_for_symbol(conn, sym)
            start_d = (max_dt + timedelta(days=1)) if max_dt else (end_d - timedelta(days=30))

            if start_d > end_d:
                continue

            bars = fetch_daily_bars(sym, start_d, end_d)
            if not bars:
                continue

            for b in bars:
                upsert_bar(conn, b, dry_run=args.dry_run)
                total_upserted += 1

                if args.verbose:
                    print(f"{sym} {to_varchar_mdy_nozeros(b.d)} O={r2(b.open)} H={r2(b.high)} L={r2(b.low)} C={r2(b.close)}")

            if not args.dry_run:
                conn.commit()

        print(f"Total bars upserted: {total_upserted}")
        return 0

    finally:
        conn.close()


if __name__ == "__main__":
    raise SystemExit(main())
