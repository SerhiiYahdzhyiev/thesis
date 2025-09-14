#! /usr/bin/env python

import csv
from collections import defaultdict
import matplotlib.pyplot as plt
import numpy as np
import os
from pathlib import Path
from scipy.stats import wilcoxon, pearsonr

def read_csv(path: Path):
    with open(path, "r", encoding="utf-8") as data_file:
        reader = csv.reader(data_file, delimiter=',')
        dict_reader = csv.DictReader(data_file, fieldnames=next(reader))
        return list(dict_reader)

def wilcoxon_test(x, y):
    stat, p = wilcoxon(np.array(x), np.array(y))
    return stat, p

def pearson_test(x, y):
    corr, p = pearsonr(np.array(x), np.array(y))
    return corr, p

def plot_regions(data: list[dict], runid: int, ax_dict=None):
    metrics = {"energy_uj": "Energy (µJ)", "time_us": "Time (µs)"}
    grouped = {m: defaultdict(lambda: defaultdict(list)) for m in metrics}

    for row in data:
        region = row["region"]
        plugin = row["plugin"]
        for m in metrics:
            grouped[m][region][plugin].append(int(row[m]))

    regions = sorted(grouped["energy_uj"].keys())
    plugins = sorted({row["plugin"] for row in data})
    colors = plt.cm.tab10.colors[:len(plugins)]

    # create new figure only if no axes passed
    if ax_dict is None:
        fig, axes = plt.subplots(1, 2, figsize=(12, 5), sharex=False)
    else:
        axes = ax_dict['axes']
        fig = ax_dict['fig']

    for ax, m in zip(axes, metrics):
        x = np.arange(len(regions))                      # group positions
        width = 0.35                                     # bar width
        offset = (np.arange(len(plugins)) - (len(plugins)-1)/2) * width

        for j, plugin in enumerate(plugins):
            vals = [np.mean(grouped[m][r][plugin]) for r in regions]
            ax.bar(x + offset[j], vals, width,
                   label=plugin, color=colors[j], edgecolor="black")

        ax.set_xticks(x)
        ax.set_xticklabels(regions, rotation=20)
        ax.set_ylabel(metrics[m])
        ax.set_title(f"Run {runid} - {metrics[m]}")
        ax.legend(title="Plugin")

    return fig, axes


def main():
    if not "run" in Path(os.getcwd()).name:
        raise Exception('Script must be run in a test run data directory!')

    if not "processed" in os.listdir('.'):
        raise Exception('No processed directory found!')

    if not len([p for p in os.listdir('processed')]):
        raise Exception('No data to process!')

    wilcoxons_energy = []
    wilcoxons_time = []
    pearsons_energy = []
    pearsons_time = []

    n_runs = len(os.listdir('processed'))
    fig, axs = plt.subplots(n_runs, 2, figsize=(12, 5 * n_runs), squeeze=False)

    for i, rp in enumerate(sorted(os.listdir('processed'))):
        path = Path(rp)
        runid = int(path.name.split('.')[2])
        data = read_csv(Path(f"processed/{path.name}"))
        smu_energy = [int(p['energy_uj']) for p in data if p['plugin'] == 'RYZEN']
        rapl_energy = [int(p['energy_uj']) for p in data if p['plugin'] == 'RAPL']

        smu_time = [int(p['time_us']) for p in data if p['plugin'] == 'RYZEN']
        rapl_time = [int(p['time_us']) for p in data if p['plugin'] == 'RAPL']

        plot_regions(data, runid, ax_dict={'fig': fig, 'axes': axs[i]})

        # statistics
        stat, p = wilcoxon_test(smu_energy, rapl_energy)
        wilcoxons_energy.append([stat, p])
        corr, p = pearson_test(smu_energy, rapl_energy)
        pearsons_energy.append([corr, p])

        stat, p = wilcoxon_test(smu_time, rapl_time)
        wilcoxons_time.append([stat, p])
        corr, p = pearson_test(smu_time, rapl_time)
        pearsons_time.append([corr, p])

    fig.tight_layout()
    Path("plots").mkdir(exist_ok=True)
    fig.savefig("plots/regions_energy_time.png")
    plt.close(fig)

    print('Wilcoxon energy:')
    for [stat, p] in wilcoxons_energy:
        print(f"Wilcoxon statistic={stat:.3f}, p={p:.4f}")
    print('Pearson energy:')
    for [corr, p] in pearsons_energy:
        print(f"Pearson r={corr:.3f}, p={p:.4f}")

    print('Wilcoxon time:')
    for [stat, p] in wilcoxons_time:
        print(f"Wilcoxon statistic={stat:.3f}, p={p:.4f}")
    print('Pearson time:')
    for [corr, p] in pearsons_time:
        print(f"Pearson r={corr:.3f}, p={p:.4f}")


if __name__ == "__main__":
    main()
