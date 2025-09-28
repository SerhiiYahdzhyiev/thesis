# Bachelor Thesis

A repository for the Bachelor Thesis paper and Viva Presentation Slides.

## Contents

- `data` - subdirectory for raw primary data gathered for this research.

- `dumps` - subdirectory for target system state dumps (running services,
            sockets, processes, etc)

- `paper` - subdirectory for latex sources (and supporting assets) for
            bachelor thesis paper

- `slides` - subdirectory for viva presentation slides

- `code` - subdirectory holding source codes for tools and programs used
           to complete this thesis

- `scripts` - subdirectory holding some bsupporting helper scripts used to
              gather data for this research and collect dumps

## Dependencies/Requirements

1. [Tex Live](https://tug.org/texlive/). - A distribution of LaTeX that I've used.
   You may use a different one, but than you would probably need to adjust your build process accordingly.
2. [GNU Make](https://www.gnu.org/software/make/) - Simplifies/automates build processes.
3. [Marp CLI](https://github.com/marp-team/marp-cli) *(As stand-along binary)*

## Build

### Paper (PDF)

1. Navigate to `paper` subdirectory: `cd paper`.
2. Build main pdf file with: `make`.
3. (Optional) Use `make clean` to clean out all the auxilary files created by `pdflatex` and `bibtex`.

### Slides

1. Navigate to `slides` subdirectory.
2. Build the pdf by running: `make pdf`.

## Code

This section describes the contents of the `code` subdirectory.

### General Dependencies

1. [ryzen_smu](https://github.com/amkillam/ryzen_smu) kernel driver.
2. [GNU Make](https://www.gnu.org/software/make/).
3. Essential build tools (c compiler of choice).

### Build

Run `make` (from `code` sub-directory) to build all the executables/utilities
at once.

### Profiler

Used to test the possible sampling/polling rate of `ryzen_smu`.

To build run `make profile`.

### Monitor

Striped/modified version of just energy values monitoring from `ryzen_smu`'s
user-space utility `monitor_cpu`.

To build run `make monitor`.

### Benchmark

An executable used to collect the energy measurements data.

To build run `make bench`.

#### Dependencies

1. [EMA](https://github.com/PERFACCT/EMA)
2. [stress-ng](https://github.com/ColinIanKing/stress-ng)

## Scripts

### Prerequisites

1. [Python3](https://pyton.org/downloads).
2. `venv` module or any other tool to manage Python's virtual environments.

### Setup environment

1. Create virtual environment and activate it.
2. Install packages from `requirements.txt` file in the root of this repo. 

### Build plots

1. Activate the virtual environment and install requirements if not done already.
2. Navigate to a directory with raw data e.g. `cd data/test_run`.
3. Run: `../../scripts/preprocess_data.sh`.
4. Run: `../../scripts/stats_test.sh`.
5. Inspect `.png`s in created `plots` sub-directory.
5. Inspect metrics in `summary_stats.csv`.

## License

This project is licensed under [MIT License](https://en.wikipedia.org/wiki/MIT_License).
For external parts (prefixed or contained in the parent directlry `ext`) see nested `LICENSE` files.
