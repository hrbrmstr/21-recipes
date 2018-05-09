all : gitbook
.PHONY: gitbook pdf epub word

gitbook :
	Rscript -e 'bookdown::render_book("index.Rmd", "bookdown::gitbook", quiet=FALSE)' && open docs/index.html

pdf:
	Rscript -e 'bookdown::render_book("index.Rmd", "bookdown::pdf_book", quiet=TRUE)' 

epub:
	Rscript -e 'bookdown::render_book("index.Rmd", "bookdown::epub_book", quiet=TRUE)' 

word:
	Rscript -e 'bookdown::render_book("index.Rmd", "bookdown::word_document2", quiet=FALSE)' 

sync:
	rsync -azP --delete docs/ bob@rud.is:/var/sites/rud.is/books/21-recipes/