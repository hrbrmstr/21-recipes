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
##  We will continue to put the fairness and accuracy of everything we publish above all else — and in the inevitable moments we fall short, we will continue to own up to our mistakes, and we’ll strive to do better
## 
##  We will continue to put the fairness and accuracy of everything we publish above all else — and in the inevitable moments we fall short, we will continue to own up to our mistakes, and we’ll strive to do better
## 
##  Our report is stronger than ever, thanks to investments in new forms of journalism like interactive graphics, podcasting and digital video and even greater spending in areas like investigative, international and beat reporting Trump is the 45th president of the United States, but he has spent much of his first year in office defying the conventions and norms established by the previous 44, and transforming the presidency in ways that were once unimaginable
## 
##  Trump essentially calls it fake, making no effort to pretend to be above it all, except to boast that he is stronger, richer, smarter and more successful than anyone else
## 
##  “The hope would be that given the American people’s reaction to the way he’s handled the presidency, the people running next time will run in the opposite direction Supreme Court CONFIRMED District courts Circuit courts PENDING Obama 1 3 9 9 11 Trump 1 12 7 6 43 White nominees as percent of total Reagan 94% Trump 91 Bush I 89 Bush II 83 Carter 79 Clinton 75 Obama 64 Male nominees Reagan 92% Carter 84 Bush I 81 Trump 81 Bush II 78 Clinton 71 Obama 58 Supreme Court Circuit courts District courts Obama 1 3 9 9 11 CONFIRMED PENDING CONFIRMED PENDING Trump 1 12 7 6 43 CONFIRMED PENDING CONFIRMED PENDING White nominees as percent of total Male nominees Reagan 94% Reagan 92% 91 Carter 84 Trump Bush I 89 Bush I 81 Bush II 83 Trump 81 Carter 79 Bush II 78 75 Clinton Clinton 71 Obama 64 Obama 58 Supreme Court Circuit courts District courts Obama 1 3 9 9 11 CONFIRMED PENDING CONFIRMED PENDING Trump 1 12 7 6 43 CONFIRMED PENDING CONFIRMED PENDING White nominees as percent of total Male nominees Reagan 94% Reagan 92% 91 Carter 84 Trump Bush I 89 Bush I 81 Bush II 83 Trump 81 Carter 79 Bush II 78 75 Clinton Clinton 71 Obama 64 Obama 58 Trump nominee demographics as of Nov
## 
##  The improvement in sentiment in the private sector shouldn’t be shocking: If you had been told that you would receive a huge tax cut and be freed from thousands of government regulations, wouldn’t you feel better about your business? As for consumers, their improved mood since the election represents a continuation of a trend that began in 2009 as the floodwaters of the financial crisis were starting to recede
## 
##  Additional uninsured after repeal: Uninsured, in millions, before repeal of mandate 4 7 12 12 12 12 13 Total uninsured, 2025: 28 30 31 31 44 million ’17 ’18 ’19 ’20 ’21 ’22 ’23 ’24 ’25 Additional uninsured after repeal: Uninsured, in millions, before repeal of mandate: Total uninsured, 2025: 4 7 12 12 12 12 13 44 28 30 31 31 million 2017 ’18 ’19 ’20 ’21 ’22 ’23 ’24 ’25 Sources: Kaiser Family Foundation; Congressional Budget Office More, and Whiter, Judges From Trump While the new administration has struggled to advance its legislative priorities, it has (unfortunately) excelled at another of its responsibilities: appointing judges
```

## See Also

As noted, there are other NLP packages. Check out the [CRAN Task View](https://cran.r-project.org/web/views/NaturalLanguageProcessing.html) on NLP for more resources.
