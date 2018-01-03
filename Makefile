all : book
.PHONY: book

book :
	Rscript -e 'bookdown::render_book("index.Rmd")' && open docs/index.html