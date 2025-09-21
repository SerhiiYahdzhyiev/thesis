#!/usr/bin/env python3

from pathlib import Path
import pandas as pd
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt

def load_all_csv(processed_dir: Path) -> pd.DataFrame:
    frames = []
    for f in sorted(processed_dir.glob("*.csv")):
        df = pd.read_csv(f)
        df["source_file"] = f.name
        frames.append(df)
    return pd.concat(frames, ignore_index=True)

def compute_metrics(x: pd.Series, y: pd.Series) -> dict:
    r, p = stats.pearsonr(x, y)
    diff = x - y
    mae  = np.mean(np.abs(diff))
    rmse = np.sqrt(np.mean(diff**2))
    mape = np.mean(np.abs(diff / x)) * 100
    bland_mean = np.mean([x, y], axis=0)
    bland_diff = diff
    return {
        "pearson_r": r,
        "pearson_p": p,
        "mae": mae,
        "rmse": rmse,
        "mape_pct": mape,
        "bland_mean_series": bland_mean,
        "bland_diff_series": bland_diff,
        "bland_diff_mean": bland_diff.mean(),
        "bland_diff_sd": bland_diff.std(ddof=1),
    }

def plot_bland_altman(mean_vals, diff_vals, title, out_file):
    mean_diff = np.mean(diff_vals)
    sd_diff   = np.std(diff_vals, ddof=1)
    loa_upper = mean_diff + 1.96 * sd_diff
    loa_lower = mean_diff - 1.96 * sd_diff

    plt.figure(figsize=(7,5))
    plt.scatter(mean_vals, diff_vals, alpha=0.6, edgecolor="k", s=40)
    plt.axhline(mean_diff, color="red", linestyle="-", label=f"Mean bias = {mean_diff:.2f}")
    plt.axhline(loa_upper, color="blue", linestyle="--", label=f"+1.96 SD = {loa_upper:.2f}")
    plt.axhline(loa_lower, color="blue", linestyle="--", label=f"-1.96 SD = {loa_lower:.2f}")
    plt.axhline(0, color="gray", linestyle=":")
    plt.xlabel("Mean of RAPL and RYZEN (µJ)")
    plt.ylabel("Difference (RAPL − RYZEN) (µJ)")
    plt.title(title)
    plt.legend(frameon=False)
    plt.tight_layout()
    plt.savefig(out_file, dpi=300)
    plt.close()

def main():
    cwd = Path.cwd()
    if "run" not in cwd.name:
        raise RuntimeError("Script must be run in a test run data directory!")

    processed_dir = cwd / "processed"
    if not processed_dir.is_dir():
        raise RuntimeError("No processed directory found!")

    df = load_all_csv(processed_dir)
    df["energy_uj"] = pd.to_numeric(df["energy_uj"])
    df["time_us"]   = pd.to_numeric(df["time_us"])

    wide = df.pivot_table(
        index=["runid", "region", "domain"],
        columns="plugin",
        values="energy_uj"
    )

    results = []
    plots_dir = cwd / "plots"
    plots_dir.mkdir(exist_ok=True)

    # Глобальные метрики по доменам
    for domain in wide.index.get_level_values("domain").unique():
        dsub = wide.xs(domain, level="domain")
        metrics = compute_metrics(dsub["RAPL"], dsub["RYZEN"])
        metrics.update({"domain": domain, "region": "ALL"})
        results.append(metrics)

        # График на домен
        plot_bland_altman(
            metrics["bland_mean_series"],
            metrics["bland_diff_series"],
            f"Bland–Altman ({domain})",
            plots_dir / f"bland_altman_{domain}.png"
        )

    # Метрики и графики по каждой паре домен+регион
    for domain in wide.index.get_level_values("domain").unique():
        for region in wide.index.get_level_values("region").unique():
            try:
                subset = wide.xs((region, domain), level=("region", "domain"))
            except KeyError:
                continue
            metrics = compute_metrics(subset["RAPL"], subset["RYZEN"])
            metrics.update({"domain": domain, "region": region})
            results.append(metrics)

            plot_bland_altman(
                metrics["bland_mean_series"],
                metrics["bland_diff_series"],
                f"Bland–Altman ({domain}, {region})",
                plots_dir / f"bland_altman_{domain}_{region}.png"
            )

    results_df = pd.DataFrame(results)
    results_df.drop(columns=["bland_mean_series","bland_diff_series"]) \
              .to_csv(cwd / "stats_summary.csv", index=False)

if __name__ == "__main__":
    main()

