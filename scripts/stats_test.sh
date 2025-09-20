#!/usr/bin/env python3
import os
from pathlib import Path
import pandas as pd

def load_all_csv(processed_dir: Path) -> pd.DataFrame:
    frames = []
    for f in sorted(processed_dir.glob("*.csv")):
        df = pd.read_csv(f)
        df["source_file"] = csv_file.name
        frames.append(df)
    return pd.concat(frames, ignore_index=True)

def main():
    cwd = Path.cwd()
    if "run" not in cwd.name:
        raise Exception("Script must be run in a test run data directory!")

    processed_dir = cwd / "processed"
    if not processed_dir.is_dir():
        raise Exception("No processed directory found!")

    df = load_all_csv(processed_dir)

    df["energy_uj"] = pd.to_numeric(df["energy_uj"])
    df["time_us"]   = pd.to_numeric(df["time_us"])

    domains = df["domain"].unique()
    print("Domains:", domains)

    regions = df["region"].unique()
    print("Regions:", regions)

    agg = (df.groupby(["runid","domain","region", "plugin"], as_index=False)
             .agg({"energy_uj": "sum", "time_us": "max"}))
    print(agg.head())

    wide = agg.pivot_table(
        index=["runid", "region"],
        columns="plugin",
        values="energy_uj"
    ).reset_index()
    print(wide.head())

if __name__ == "__main__":
    main()
