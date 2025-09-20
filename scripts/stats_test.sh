#! /usr/bin/env python

import csv
import matplotlib.pyplot as plt
from matplotlib.ticker import ScalarFormatter
import os
from pathlib import Path

def read_csv(path: Path):
    with open(path, "r", encoding="utf-8") as data_file:
        reader = csv.reader(data_file, delimiter=',')
        dict_reader = csv.DictReader(data_file, fieldnames=next(reader))
        return list(dict_reader)

def main():
    if not "run" in Path(os.getcwd()).name:
        raise Exception('Script must be run in a test run data directory!')

    if not "processed" in os.listdir('.'):
        raise Exception('No processed directory found!')

    if not len([p for p in os.listdir('processed')]):
        raise Exception('No data to process!')

    data = []
    
    for rp in sorted(os.listdir('processed')):
        path = Path(rp)
        _data = read_csv(Path(f"processed/{path.name}"))
        data += _data


    regions = {d['region'] for d in data }

    for r in regions:
        region_data = [d for d in data if d['region'] == r]


if __name__ == "__main__":
    main()
