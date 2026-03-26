# save as csv_to_parquet.py
import pandas as pd


csv_path = "C:\AST\OPN_SFC_CONTENT.csv"
parquet_path = "C:\AST\OPN_SFC_CONTENT.parquet"

df = pd.read_csv(
    csv_path,
    dtype=str,                  # keep everything as text first
    engine="python",            # more tolerant parser
    on_bad_lines="skip",        # skip malformed rows
    quoting=0,                  # let engine handle quotes
)
df.to_parquet(parquet_path, engine="pyarrow", index=False)
print(f"Parquet written: {parquet_path}, rows: {len(df)}")
