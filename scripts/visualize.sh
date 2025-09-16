#! /usr/bin/env python

import csv
from collections import defaultdict
import matplotlib.pyplot as plt
from matplotlib.ticker import ScalarFormatter
import os
from pathlib import Path

def read_csv(path: Path):
    with open(path, "r", encoding="utf-8") as data_file:
        reader = csv.reader(data_file, delimiter=',')
        dict_reader = csv.DictReader(data_file, fieldnames=next(reader))
        return list(dict_reader)

def plot_ax(ax, data, name, plugin):
    x = [d['runid'] for d in sorted(data, key=lambda d: d['runid'])]
    y = [d['energy_uj'] for d in sorted(data, key=lambda d: d['runid'])]
    ax.plot(x, y)
    ax.set_ylabel('Energy (J)')
    ax.yaxis.set_major_formatter(ScalarFormatter(useMathText=True))
    ax.ticklabel_format(axis='y', style='sci', scilimits=(0,0))
    ax.set_xlabel('Runs')
    ax.set_title(name + plugin)

def plot_region(axs, i: int, name: str, data: list[dict]):
    fig, axs2 = plt.subplots(1, 2, figsize=(15, 5))
    region_data = [d for d in data if d['region'] == name]
    smu = [d for d in region_data if d['plugin'] != "RAPL"]
    rapl = [d for d in region_data if d['plugin'] == "RAPL"]

    plot_ax(axs[i][0], smu, name, '_ryzen_smu')
    plot_ax(axs[i][1], rapl, name, '_rapl')

    plot_ax(axs2[0], smu, name, '_ryzen_smu')
    plot_ax(axs2[1], rapl, name, '_rapl')

    out_path = Path("./plots/") / name
    out_path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig('plots/' + out_path.name)


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

    fig, axs = plt.subplots(5, 2, figsize=(15, 25))
    i = 0
    for r in regions:
        plot_region(axs, i, r, data)
        i = i + 1
    out_path = Path("./plots/") / "regions"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig('plots/' + "regions")

if __name__ == "__main__":
    main()
