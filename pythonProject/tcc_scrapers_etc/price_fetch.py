import yfinance as yf
import os

SAVE_PATH = r"C:\AST\Research and Data\Stocks Deep"

def download_data(ticker, start_date, end_date):
    print(f"\nDownloading {ticker} from {start_date} to {end_date}...\n")

    df = yf.download(
        ticker,
        start=start_date,
        end=end_date,
        interval="1d",
        auto_adjust=False,
        actions=False
    )

    if df.empty:
        print("⚠️ No data returned. Check ticker or date range.")
        return

    # Remove multi-index columns if present
    if isinstance(df.columns, type(df.columns)):
        if hasattr(df.columns, "levels"):
            df.columns = df.columns.get_level_values(0)

    df.reset_index(inplace=True)

    # Reorder columns to standard OHLCAdjV
    desired_order = ["Date", "Open", "High", "Low", "Close", "Adj Close", "Volume"]
    df = df[desired_order]

    filename = f"{ticker}_{start_date}_to_{end_date}.csv"
    full_path = os.path.join(SAVE_PATH, filename)

    df.to_csv(full_path, index=False)

    print("Download complete.")
    print(f"Rows downloaded: {len(df)}")
    print(f"First date: {df['Date'].min().date()}")
    print(f"Last date: {df['Date'].max().date()}")
    print(f"Saved as: {full_path}\n")


if __name__ == "__main__":
    ticker = input("Enter ticker (e.g., QQQ or RELIANCE.NS): ").strip().upper()
    start_date = input("Enter start date (YYYY-MM-DD): ").strip()
    end_date = input("Enter end date (YYYY-MM-DD): ").strip()

    download_data(ticker, start_date, end_date)
