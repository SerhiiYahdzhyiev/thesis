#! /usr/bin/env python

import csv
import os
from pathlib import Path

def is_core(row: dict):
    return "core" in row['device_name'] and "core." not in row['device_name']

def is_package(row: dict):
    return "package" in row['device_name']

def read_csv(path: Path):
    with open(path, "r", encoding="utf-8") as data_file:
        reader = csv.reader(data_file, delimiter=',')
        dict_reader = csv.DictReader(data_file, fieldnames=next(reader))
        return list(dict_reader)

def filter_data(rows: list[dict]):
    return [
        r for r in rows
        if is_package(r) or is_core(r)
    ]

def get_plugin_type(row: dict):
    return "RAPL" if "CPU" in row['device_name'] else "RYZEN"

def get_domain(row: dict):
    return "package" if "package" in row['device_name'] else "core"

def process_data(rows: list[dict], runid: int):
    return [
        {
            'plugin': get_plugin_type(r),
            'domain': get_domain(r),
            'region': r['region_idf'],
            'energy_uj': int(r['energy']),
            'time_us': int(r['time']),
            'runid': runid
        }
        for r in rows
    ]

def write_csv(path: Path, data: list[dict]):
    out_path = Path("./processed") / f"{path.name}.processed.csv"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with open(
            Path(f"./processed/{path.name}.processed.csv"),
            "w", encoding="utf-8"
        ) as f:
        header = [k for k in data[0].keys()]
        writer = csv.DictWriter(f, fieldnames=header)
        writer.writeheader()
        writer.writerows(data)

def main():
    if not "run" in Path(os.getcwd()).name:
        raise Exception('Script must be run in a test run data directory!')

    if not len([
        p for p in os.listdir('.') if p != 'logs' and p != 'processed'
    ]):
        raise Exception('No data to process!')

    for rp in os.listdir('.'):
        if rp != "logs" and rp != "processed" and rp != "plots":
            path = Path(rp)
            runid = int(path.name.split('.')[2])
            data = read_csv(path)
            filtered = filter_data(data)
            processed = process_data(filtered, runid)
            write_csv(path, processed)

if __name__ == "__main__":
    main()
