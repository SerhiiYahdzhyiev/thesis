# Bachelor Thesis

A repository for the Bachelor Thesis paper and Viva Presentation Slides.

## Contents

- `paper` - subdirectory for latex sources (and supporting assets) for
            bachelor thesis paper
- `slides` - subdirectory for viva presentation slides

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
