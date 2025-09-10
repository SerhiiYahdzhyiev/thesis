# Bachelor Thesis

A repository for the Bachelor Thesis paper and Viva Presentation Slides.

## Contents

- `paper` - subdirectory for latex sources (and supporting assets) for
            bachelor thesis paper

- `slides` - subdirectory for viva presentation slides

- `code` - subdirectory holding source codes for tools and programs used
           to complete this thesis

## Dependencies/Requirements

1. [Tex Live](https://tug.org/texlive/). - A distribution of LaTeX that I've used.
   You may use a different one, but than you would probably need to adjust your build process accordingly.
2. [GNU Make](https://www.gnu.org/software/make/) - Simplifies/automates build processes.

## Build

### Paper (PDF)

1. Navigate to `paper` subdirectory: `cd paper`.
2. Build main pdf file with: `make`.
3. (Optional) Use `make clean` to clean out all the auxilary files created by `pdflatex` and `bibtex`.

## License

This project is licensed under [MIT License](https://en.wikipedia.org/wiki/MIT_License).

## Code

This section describes the contents of the `code` subdirectory.

### General Dependencies

1. [ryzen_smu](https://github.com/amkillam/ryzen_smu) kernel driver.
2. [GNU Make](https://www.gnu.org/software/make/).

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
