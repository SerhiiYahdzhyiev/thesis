#!/bin/bash

set -e

systemctl list-units --all > baseline_units.txt
systemctl list-units --state=running > baseline_running.txt
systemctl list-unit-files --state=enabled > baseline_enabled.txt
systemctl list-sockets --all > baseline_sockets.txt
systemctl list-timers --all > baseline_timers.txt

ps -eo pid,ppid,cmd,%cpu --sort=%cpu > baseline-ps.txt
