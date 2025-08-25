all: main

main: main.tex references.bib
	pdflatex $<
	biber main
	pdflatex $<
	pdflatex $<


clean:
	rm -f *.pdf *.aux *.toc *.out *.bbl *.log *.blg *.bcf *.xml
	rm -f sections/*.aux
