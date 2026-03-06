#!/usr/bin/env python3

"""
Fetch OHLCV for a US equity ticker on a given date and upsert into MULTI_10Y_UTDT.

- Input date format: YYYY-MM-DD
- price_date stored as VARCHAR MM/DD/YYYY
- Uses environment file: C:\\AST\\GitHub\\set_env.env
"""

import argparse
import json
import os
import sys
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Dict, Optional

import pandas as pd
import yfinance as yf
import pymysql
from dotenv import load_dotenv


# ============================================================
# 1) LOAD ENV (HARDCODED LOCATION PER YOUR REQUEST)
# ============================================================

load_dotenv("C:\\AST\\GitHub\\set_env.env")

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
# 2) FETCH OHLCV
# ============================================================

@dataclass
class OHLCV:
    ticker: str
    resolved_date: str   # YYYY-MM-DD
    open: float
    high: float
    low: float
    close: float
    adj_close: Optional[float]
    volume: int


def fetch_ohlcv_for_date(
    ticker: str,
    date_yyyy_mm_dd: str,
    fallback_to_prev_trading_day: bool = True
) -> OHLCV:

    req_dt = datetime.strptime(date_yyyy_mm_dd, "%Y-%m-%d").date()

    start_dt = req_dt - timedelta(days=7)
    end_dt = req_dt + timedelta(days=1)

    t = yf.Ticker(ticker)
    df = t.history(interval="1d",
                   start=start_dt.isoformat(),
                   end=end_dt.isoformat(),
                   auto_adjust=False)

    if df.empty:
        raise RuntimeError("No data returned from yfinance.")

    df["__date__"] = pd.to_datetime(df.index).date

    exact = df[df["__date__"] == req_dt]

    if not exact.empty:
        row = exact.iloc[0]
        resolved_dt = req_dt
    else:
        if not fallback_to_prev_trading_day:
            raise RuntimeError("Requested date not a trading day.")
        prior = df[df["__date__"] < req_dt].sort_values("__date__", ascending=False)
        if prior.empty:
            raise RuntimeError("No prior trading day found.")
        row = prior.iloc[0]
        resolved_dt = row["__date__"]

    return OHLCV(
        ticker=ticker.upper(),
        resolved_date=resolved_dt.isoformat(),
        open=float(row["Open"]),
        high=float(row["High"]),
        low=float(row["Low"]),
        close=float(row["Close"]),
        adj_close=float(row["Adj Close"]) if "Adj Close" in row else None,
        volume=int(row["Volume"])
    )


def yyyy_mm_dd_to_mm_dd_yyyy(d: str) -> str:
    dt = datetime.strptime(d, "%Y-%m-%d")
    return f"{dt.month}/{dt.day}/{dt.year}"


# ============================================================
# 3) UPSERT INTO MULTI_10Y_UTDT
# ============================================================

def upsert_ohlcv(db_cfg: Dict, o: OHLCV):

    sql = """
        INSERT INTO stocks.MULTI_10Y_UTDT
            (price_date, symbol, price_open, price_hi, price_lo, price_close, adj_close, volume)
        VALUES
            (%s, %s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            price_open  = VALUES(price_open),
            price_hi    = VALUES(price_hi),
            price_lo    = VALUES(price_lo),
            price_close = VALUES(price_close),
            adj_close   = VALUES(adj_close),
            volume      = VALUES(volume)
    """

    price_date_varchar = yyyy_mm_dd_to_mm_dd_yyyy(o.resolved_date)

    values = (
        price_date_varchar,
        o.ticker,
        round(o.open,2),
        round(o.high,2),
        round(o.low,2),
        round(o.close,2),
        round(o.adj_close,2),
        o.volume,
    )

    conn = pymysql.connect(
        host=db_cfg["host"],
        port=db_cfg["port"],
        user=db_cfg["user"],
        password=db_cfg["password"],
        database=db_cfg["database"],
        autocommit=False,
        charset="utf8mb4",
    )

    try:
        with conn.cursor() as cur:
            cur.execute(sql, values)
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


# ============================================================
# 4) MAIN
# ============================================================

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ticker", required=True)
    parser.add_argument("--date", required=True)   # YYYY-MM-DD
    parser.add_argument("--env", default="DEV")
    parser.add_argument("--no-fallback", action="store_true")
    parser.add_argument("--print-only", action="store_true")
    args = parser.parse_args()

    o = fetch_ohlcv_for_date(
        ticker=args.ticker,
        date_yyyy_mm_dd=args.date,
        fallback_to_prev_trading_day=not args.no_fallback
    )

    print(json.dumps({
        "ticker": o.ticker,
        "resolved_date_yyyy_mm_dd": o.resolved_date,
        "resolved_date_varchar": yyyy_mm_dd_to_mm_dd_yyyy(o.resolved_date),
        "open": o.open,
        "high": o.high,
        "low": o.low,
        "close": o.close,
        "adj_close": o.adj_close,
        "volume": o.volume
    }, indent=2))

    if args.print_only:
        return

    db_cfg = resolve_db_config(args.env)
    upsert_ohlcv(db_cfg, o)

    print("OK: upserted into MULTI_10Y_UTDT")


if __name__ == "__main__":
    main()
