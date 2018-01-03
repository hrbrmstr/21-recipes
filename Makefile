all : gitbook
.PHONY: gitbook pdf epub

gitbook :
	Rscript -e 'bookdown::render_book("index.Rmd", "bookdown::gitbook", quiet=TRUE)' && open docs/index.html

pdf:
	Rscript -e 'bookdown::render_book("index.Rmd", "bookdown::pdf_book", quiet=TRUE)' && open docs/index.html

epub:
	Rscript -e 'bookdown::render_book("index.Rmd", "bookdown::epub_book", quiet=TRUE)' && open docs/index.html
