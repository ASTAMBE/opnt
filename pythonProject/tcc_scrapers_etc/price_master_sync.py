#!/usr/bin/env python3
"""
price_master_sync.py

Single driver script that:

1) If --symbol provided:
      - Fetch FULL historical OHLCV
      - UPSERT into stocks.MULTI_10Y_UTDT
      - Call stocks.sp_recalc_all_calc(symbol, min_date, max_date)

2) If --symbol NOT provided:
      - Fetch last N calendar days (default 12) for ALL existing symbols
      - UPSERT
      - Call stocks.sp_recalc_all_calc(symbol, start_date, end_date)

Safety / atomicity:
- Preflight checks table + proc existence BEFORE any write.
- Runs all DB work in a single transaction.
- Default is ROLLBACK unless --commit is provided.
- On ANY error -> rollback (no partial inserts).
"""

import argparse
import datetime as dt
import os
import pandas as pd
import yfinance as yf
import mysql.connector
from dotenv import load_dotenv


# =========================
# ENV CONFIG (YOUR FORMAT)
# =========================

load_dotenv(r"C:\AST\GitHub\set_env.env")

DB_CONFIGS = {
    "DEV": {
        "host": os.getenv("DEV_DB_HOST"),
        "user": os.getenv("DEV_DB_USER"),
        "password": os.getenv("DEV_PWD"),
        "database": os.getenv("DEV_DATABASE"),  # will be overridden to 'stocks'
        "port": int(os.getenv("DEV_DB_PORT", "3306")),
    },
    "PROD": {
        "host": os.getenv("PROD_DB_HOST"),
        "user": os.getenv("PROD_DB_USER"),
        "password": os.getenv("PROD_PWD"),
        "database": os.getenv("PROD_DATABASE"),  # will be overridden to 'stocks' if used later
        "port": int(os.getenv("PROD_DB_PORT", "3306")),
    },
}

# For now, user wants DEV only
DB_CONFIG = DB_CONFIGS["DEV"].copy()

# Force schema/database to 'stocks' regardless of env file value
DB_SCHEMA = "stocks"
DB_CONFIG["database"] = DB_SCHEMA


# =========================
# Utility Functions
# =========================

def connect_db():
    return mysql.connector.connect(**DB_CONFIG, autocommit=False)


def mdy_no_zeros(d: dt.date) -> str:
    return f"{d.month}/{d.day}/{d.year}"


def fetch_yfinance(symbol: str, start=None, end=None, full_history=False) -> pd.DataFrame:

    MIN_FETCH_DATE = dt.date(2015, 1, 1)

    ticker = yf.Ticker(symbol)

    if full_history:
        start = MIN_FETCH_DATE
        end = dt.date.today()
    else:
        # Prevent accidental pre-2015 fetch
        if start < MIN_FETCH_DATE:
            start = MIN_FETCH_DATE

    hist = ticker.history(
        start=start.strftime("%Y-%m-%d"),
        end=(end + dt.timedelta(days=1)).strftime("%Y-%m-%d"),
        auto_adjust=False
    )

    if hist is None or hist.empty:
        return pd.DataFrame()

    hist = hist.reset_index()
    date_col = "Date" if "Date" in hist.columns else ("Datetime" if "Datetime" in hist.columns else None)

    hist["price_date"] = pd.to_datetime(hist[date_col]).dt.date

    hist.rename(columns={
        "Open": "price_open",
        "High": "price_hi",
        "Low": "price_lo",
        "Close": "price_close",
        "Adj Close": "adj_close",
        "Volume": "volume",
    }, inplace=True)

    if "adj_close" not in hist.columns:
        hist["adj_close"] = hist["price_close"]

    hist = hist[[
        "price_date",
        "price_open",
        "price_hi",
        "price_lo",
        "price_close",
        "adj_close",
        "volume"
    ]]

    for c in ["price_open", "price_hi", "price_lo", "price_close", "adj_close"]:
        hist[c] = pd.to_numeric(hist[c], errors="coerce").round(4)

    hist["volume"] = pd.to_numeric(hist["volume"], errors="coerce").fillna(0).astype("int64").astype(str)

    hist = hist.dropna(subset=["price_date", "price_close"]).sort_values("price_date")

    return hist


def preflight_checks(conn):
    """
    Verify:
    - stocks.MULTI_10Y_UTDT exists
    - stocks.sp_recalc_all_calc exists
    - (optional) unique key on (Symbol, price_date) exists (warn only)
    """
    cur = conn.cursor()

    # Table exists?
    cur.execute(
        """
        SELECT COUNT(*)
        FROM information_schema.tables
        WHERE table_schema = %s AND table_name = 'MULTI_10Y_UTDT'
        """,
        (DB_SCHEMA,)
    )
    if cur.fetchone()[0] == 0:
        raise RuntimeError(f"Preflight failed: Table {DB_SCHEMA}.MULTI_10Y_UTDT does not exist")

    # Procedure exists?
    cur.execute(
        """
        SELECT COUNT(*)
        FROM information_schema.routines
        WHERE routine_schema = %s
          AND routine_name = 'sp_recalc_all_calc'
          AND routine_type = 'PROCEDURE'
        """,
        (DB_SCHEMA,)
    )
    if cur.fetchone()[0] == 0:
        raise RuntimeError(f"Preflight failed: Procedure {DB_SCHEMA}.sp_recalc_all_calc does not exist")

    # Unique key (warn only)
    cur.execute(
        """
        SELECT COUNT(*)
        FROM information_schema.statistics
        WHERE table_schema = %s
          AND table_name = 'MULTI_10Y_UTDT'
          AND index_name <> 'PRIMARY'
          AND non_unique = 0
          AND column_name IN ('Symbol','price_date')
        """,
        (DB_SCHEMA,)
    )
    # This is a heuristic; you might have a composite unique index. We'll just warn if it looks missing.
    uniq_hint = cur.fetchone()[0]
    if uniq_hint == 0:
        print("[WARN] Preflight: Could not confirm a UNIQUE index involving (Symbol, price_date). "
              "UPSERT reliability requires UNIQUE KEY(Symbol, price_date).")

    print("[INFO] Preflight checks OK.")


def upsert_prices(conn, symbol: str, df: pd.DataFrame):
    sql = f"""
    INSERT INTO {DB_SCHEMA}.MULTI_10Y_UTDT
      (Symbol, price_date, price_date_raw,
       price_open, price_hi, price_lo, price_close, adj_close, volume)
    VALUES
      (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    ON DUPLICATE KEY UPDATE
      price_date_raw = VALUES(price_date_raw),
      price_open     = VALUES(price_open),
      price_hi       = VALUES(price_hi),
      price_lo       = VALUES(price_lo),
      price_close    = VALUES(price_close),
      adj_close      = VALUES(adj_close),
      volume         = VALUES(volume)
    """

    cur = conn.cursor()

    rows = []
    for _, r in df.iterrows():
        d = r["price_date"]
        rows.append((
            symbol,
            d,
            mdy_no_zeros(d),
            None if pd.isna(r["price_open"]) else float(r["price_open"]),
            None if pd.isna(r["price_hi"]) else float(r["price_hi"]),
            None if pd.isna(r["price_lo"]) else float(r["price_lo"]),
            None if pd.isna(r["price_close"]) else float(r["price_close"]),
            None if pd.isna(r["adj_close"]) else float(r["adj_close"]),
            str(r["volume"]) if pd.notna(r["volume"]) else "0",
        ))

    cur.executemany(sql, rows)
    return df["price_date"].min(), df["price_date"].max(), len(rows)


def call_recalc(conn, symbol: str, start_date: dt.date, end_date: dt.date):
    cur = conn.cursor()
    # Fully qualify schema for safety
    cur.callproc(f"{DB_SCHEMA}.sp_recalc_all_calc", [symbol, start_date, end_date])

    # Drain result sets
    try:
        while True:
            cur.fetchall()
            if not cur.nextset():
                break
    except Exception:
        pass


def get_existing_symbols(conn):
    cur = conn.cursor()
    cur.execute(f"SELECT DISTINCT Symbol FROM {DB_SCHEMA}.MULTI_10Y_UTDT ORDER BY Symbol")
    return [r[0] for r in cur.fetchall()]


# =========================
# MAIN
# =========================

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--symbol", help="Ticker symbol for full historical load (ex: ORCL)")
    parser.add_argument("--days", type=int, default=12,
                        help="Calendar days for incremental update (default=12 ~ 7 trading days)")
    parser.add_argument("--commit", action="store_true",
                        help="Commit changes. If not provided, script will rollback (dry but fully executes).")
    args = parser.parse_args()

    conn = connect_db()
    print(f"[INFO] Connected to host={DB_CONFIG['host']} db/schema={DB_SCHEMA} (forced)")

    try:
        # 1) Preflight BEFORE any writes
        preflight_checks(conn)

        # 2) Work (single transaction)
        if args.symbol:
            symbol = args.symbol.upper().strip()
            print(f"\n[INFO] FULL LOAD: {symbol}")

            df = fetch_yfinance(symbol, full_history=True)
            if df.empty:
                raise RuntimeError(f"No yfinance data returned for {symbol}")

            min_d = df["price_date"].min()
            max_d = df["price_date"].max()
            print(f"[INFO] {symbol}: fetched rows={len(df)} span={min_d} → {max_d}")

            min_u, max_u, nrows = upsert_prices(conn, symbol, df)
            print(f"[INFO] {symbol}: upsert attempted rows={nrows}")

            call_recalc(conn, symbol, min_u, max_u)
            print(f"[INFO] {symbol}: sp_recalc_all_calc done for {min_u} → {max_u}")

        else:
            print("\n[INFO] INCREMENTAL LOAD (all existing symbols)")

            symbols = get_existing_symbols(conn)
            if not symbols:
                raise RuntimeError("No symbols found in MULTI_10Y_UTDT")

            end_dt = dt.date.today()
            start_dt = end_dt - dt.timedelta(days=args.days)
            print(f"[INFO] Fetch window (calendar): {start_dt} → {end_dt} symbols={len(symbols)}")

            for symbol in symbols:
                df = fetch_yfinance(symbol, start=start_dt, end=end_dt, full_history=False)
                if df.empty:
                    print(f"[WARN] {symbol}: no data in window; skipping")
                    continue

                _, _, nrows = upsert_prices(conn, symbol, df)
                print(f"[INFO] {symbol}: upsert attempted rows={nrows}")

                call_recalc(conn, symbol, start_dt, end_dt)
                print(f"[INFO] {symbol}: sp_recalc_all_calc done for {start_dt} → {end_dt}")

        # 3) Commit/rollback gate
        if args.commit:
            conn.commit()
            print("\n[INFO] COMMIT successful. (All changes persisted)")
        else:
            conn.rollback()
            print("\n[INFO] ROLLBACK complete. (No changes persisted)")

    except Exception as e:
        conn.rollback()
        print(f"\n[ERROR] Script failed; rolled back. Reason: {e}")
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()
