all: main

main: main.tex
	pdflatex $^
	bibtex $@
	pdflatex $^
	pdflatex $^


clean:
	rm -f *.pdf *.aux *.toc *.out *.bbl *.log *.blg
	rm -f sections/*.aux
