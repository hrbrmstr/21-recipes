--- 
title: "21 Recipes for Mining Twitter Data with rtweet"
author: "Bob Rudis"
date: "2018-01-05"
site: bookdown::bookdown_site
documentclass: book
bibliography: [book.bib]
biblio-style: apalike
link-citations: yes
github-repo: hrbrmstr/21-recipes
url: 'https\://rud.is/books/21-recipes/'
description: "An R/rtweet edition of Matthew A. Russell's Python Twitter Recipes Book"
---

# Preface {-}

I'm using this as way to familiarize myself with bookdown so I don't make as many mistakes with my web scraping field guide book.

It's based on Matthew R. Russell's [book](https://github.com/ptwobrussell/Recipes-for-Mining-Twitter). That book is out of distribution and much of the content is in Matthew's "Mining the Social Web" book. There will be _many_ similarities between his "21 Recipes" book and this book _on purpose_. I am not claiming originality in this work, just making an R-centric version of the cookbook.

As he states in his tome, "this intentionally terse recipe collection provides you with 21 easily adaptable Twitter mining recipes".

The recipes contained in this book use the [`rtweet`](http://rtweet.info/) package by [Michael W. Kearney](https://github.com/mkearney). I'll be using the [GitHub](https://github.com/mkearney/rtweet) version of the package since it has some cutting-edge features and bug-fixes in it.

You can install the GitHub version of [`rtweet`] by first installing the [`devtools`](https://github.com/hadley/devtools) package via:


```r
install.packages("devtools")
```

then installing the GitHub `rtweet` package via:


```r
devtools::install_github("mkearney/rtweet")
```

>NOTE: If you try to run examples in this book and receive an error about a package not being found or not available, you'll need to triage it by using one of the above methods. If any GitHub packages are used, each initial `library()` call will have a comment after it noting which `repository/packagename` to use the `devtools` method with.

Matthew also states that "one other thing you should consider doing up front, if you haven’t already, is quickly skimming through the official Twitter API documentation and related development documents linked on that page. Twitter has a very easy-to-use API with a lot of degrees of freedom". Michael has documented `rtweet` well, but reading the official documentation will really help.

This book also makes extensive use of the `tidyverse` meta-package. You will need to:


```r
install.packages("tidyverse")
```

if you have not used packages from it before (it may take a few minutes, especially on Linux systems).
