all: main.pdf

main.pdf: main.tex *.tex *.bib
	latexmk -pdf main.tex
	bibtex main
	latexmk -pdf main.tex

clean:
	latexmk -C
