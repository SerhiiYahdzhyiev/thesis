#!/bin/bash

set -e

BENCH="bench"
RUNS=$1
SLEEP_BETWEEN=15
LOGDIR="./logs"

if [ -z "$RUNS" ]; then
    echo "Usage: $0 <num_runs>"
    exit 1
fi

mkdir -p "$LOGDIR"
GOVFILE="/tmp/orig_governors.txt"

sudo touch $GOVFILE
sudo chown root:root $GOVFILE

> "$GOVFILE"
for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
    gov=$(cat "$cpu/cpufreq/scaling_governor")
    echo "$cpu $gov" >> "$GOVFILE"
done

for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
    echo performance | sudo tee "$cpu/cpufreq/scaling_governor" >/dev/null
done

for i in $(seq 1 $RUNS); do
    ts=$(date +"%Y-%m-%d_%H-%M-%S")
    logfile="$LOGDIR/run_${i}_$ts.log"
    echo "[RUN $i/$RUNS] $(date)" | tee -a "$logfile"
    $BENCH | tee -a "$logfile"
    sleep $SLEEP_BETWEEN
done

while read -r cpu gov; do
    echo $gov | sudo tee "$cpu/cpufreq/scaling_governor" >/dev/null
done < "$GOVFILE"
