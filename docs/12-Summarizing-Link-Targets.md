# Summarizing Link Targets 

## Problem

You want to summarize the text of a web page that’s indicated by a short URL in a tweet.

## Solution

Extract the text from the web page, and then use a natural language processing (NLP) toolkit to help you extract the most important sentences to create a machine-generated abstract.

## Discussion

R has more than a few NLP tools to work with. We'll work with the `LSAfun` package for this exercise. As the acronym-laden package name implies, it uses  Latent Semantic Analysis (LSA) to determine the most important bits in a set of text.

We'll use tweets by data journalist extraordinaire [Matt Stiles](https://twitter.com/stiles). Matt works for the Los Angeles Times and I learn a _ton_ from him on a daily basis. He's on top of _everything_. Let's summarise some news he shared recently from the New York Times, Reuters, Washington Post, Five Thirty-Eight and his employer. 

We'll limit our exploration to the first three new links we find.


```r
library(rtweet)
library(LSAfun)
library(jerichojars) # hrbrmstr/jerichojars
library(jericho) # hrbrmstr/jericho
library(tidyverse)
```

```r
stiles <- get_timeline("stiles")

filter(stiles, str_detect(urls_expanded_url, "nyti|reut|wapo|lat\\.ms|53ei")) %>%  # only get tweets with news links
  pull(urls_expanded_url) %>% # extract the links
  flatten_chr() %>% # mush them into a nice character vector
  head(3) %>% # get the first 3
  map_chr(~{
    httr::GET(.x) %>% # get the URL (I'm lazily calling "fair use" here vs check robots.txt since I'm suggesting you do this for your benefit vs profit)
      httr::content(as="text") %>%  # extract the HTML
      jericho::html_to_text() %>% # strip away extraneous HTML tags
      LSAfun::genericSummary(k=3) %>% # summarise!
      paste0(collapse="\n\n") # easier to see
  }) %>%
  walk(cat)
```

```
##  Continue reading the main story Advertisement Continue reading the main story The North Korea tweet near the end of the day seemed most distressing to some in Washington watching the escalating clash between the United States and a nuclear-armed North
## 
##  LEARN MORE » Sections Home Search Skip to content Skip to navigation View mobile version The New York Times Politics|Trump Says His ‘Nuclear Button’ Is ‘Much Bigger’ Than North Korea’s Search Subscribe Now Log In 0 Settings Close search Site Search Navigation Search NYTimes
## 
##  He called for an aide to Hillary Clinton to be thrown in jail, threatened to cut off aid to Pakistan and the Palestinians, assailed Democrats over immigration, claimed credit for the fact that no one died in a jet plane crash last year and announced that he would announce his own award next Monday for the most dishonest and corrupt news media We will continue to put the fairness and accuracy of everything we publish above all else — and in the inevitable moments we fall short, we will continue to own up to our mistakes, and we’ll strive to do better
## 
##  We will continue to put the fairness and accuracy of everything we publish above all else — and in the inevitable moments we fall short, we will continue to own up to our mistakes, and we’ll strive to do better
## 
##  Our report is stronger than ever, thanks to investments in new forms of journalism like interactive graphics, podcasting and digital video and even greater spending in areas like investigative, international and beat reporting Trump is the 45th president of the United States, but he has spent much of his first year in office defying the conventions and norms established by the previous 44, and transforming the presidency in ways that were once unimaginable
## 
##  Trump essentially calls it fake, making no effort to pretend to be above it all, except to boast that he is stronger, richer, smarter and more successful than anyone else
## 
##  “The hope would be that given the American people’s reaction to the way he’s handled the presidency, the people running next time will run in the opposite direction
```

## See Also

As noted, there are other NLP packages. Check out the [CRAN Task View](https://cran.r-project.org/web/views/NaturalLanguageProcessing.html) on NLP for more resources.
