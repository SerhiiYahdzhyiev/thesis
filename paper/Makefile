all: main

main: main.tex references.bib
	pdflatex $<
	biber main
	makeglossaries main
	pdflatex $<
	pdflatex $<


clean:
	rm -f *.pdf *.aux *.toc *.out *.bbl *.log *.blg *.bcf *.xml *.glg *.glo \
	*.gls *.ist *.acn *.acr *.alg *.lof *.lot
	rm -f sections/*.aux
