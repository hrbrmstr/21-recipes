# Searching for Tweets

## Problem

You want to collect a sample of tweets from the public timeline for a custom query.

## Solution

Use `rtweet::search_tweets()` and custom [search operators](https://developer.twitter.com/en/docs/tweets/search/guides/standard-operators).

## Discussion

The Twitter API has free and paid tiers. The free tier is what many of us use and there are a number of operators that can be added to a search query to refine the results. We saw one of those in Recipe 3 by using the `#rstats` hashtag in the search query. But there are far more options at our disposal.

We can see all the `#rstats` tweets that aren't retweets:


```r
library(rtweet)
library(tidyverse)
```

```r
search_tweets("#rstats -filter:retweets") %>%
  select(text)
```

```
## # A tibble: 100 x 1
##                                                                           text
##                                                                          <chr>
##  1 "New R Package for #SEO\n\nDiscover RsparkleR : a web crawler powered by @S
##  2 Word Embeddings with Keras https://t.co/QHzvmKNdGS #rstats https://t.co/KwD
##  3                  Word Embeddings with Keras https://t.co/cbN12jx74j #rstats
##  4 You can read the first chapter of Practical Data Science with R on #liveBoo
##  5  "Big | Data | Insights! https://t.co/hgMeKIOsjQ\n#in #rstats #datascience"
##  6 Do you have bad R habits? Here's how to identify and fix them. @MicrosoftR 
##  7 What are the resources to learn creating #Chatbot using R? https://t.co/ip9
##  8 I have been playing with #ggplot2 and I rather like this plot of bird densi
##  9 Linking RStudio and GitHub. Very useful blog for anyone interested in produ
## 10 "@RussellSPierce @davidjayharris After using it for a long time, it's reall
## # ... with 90 more rows
```

or, all the recent tweet-replies sent to `@kearneymw`:


```r
search_tweets("to:kearneymw") %>%
  select(text)
```

```
## # A tibble: 100 x 1
##                                                                           text
##                                                                          <chr>
##  1 @kearneymw @BreitbartNews First thing's first: Breitbart is NOT 'news'.  Na
##  2 @kearneymw @Twitter interesting. This is what I see https://t.co/PVcuXp8u0r
##  3 "@kearneymw @Grantimus9 Dang, he was right again.\n\nDebate world is small!
##  4                                     @kearneymw Amazing. Indeed. @Grantimus9
##  5                   "@kearneymw Really good. Thanks. \n\n...Eating more fish"
##  6      @kearneymw Examples sing things well (cohort analysis!) always welcome
##  7 @josephofiowa I'm using it as an example of (a) difficulties in making caus
##  8                                         @kearneymw  https://t.co/JI5AZvdoTq
##  9 "@kearneymw Ohhh, this is neat.\n\nLol @ the projections that simply omit t
## 10                                                  @kearneymw I just Lacan't?
## # ... with 90 more rows
```

and, even all the `#rstats` tweets that have GitHub links in them (but no `#python` hashtags):


```r
search_tweets("#rstats url:github -#python") %>% 
  select(text)
```

```
## # A tibble: 100 x 1
##                                                                           text
##                                                                          <chr>
##  1 "RT @dataandme: \U0001f60e\U0001f4e6 for changing up your R-\U0001f4ca text
##  2 Linking RStudio and GitHub. Very useful blog for anyone interested in produ
##  3 "New year, new blog! Find out how to build this animation that brings a tSN
##  4 "Open-source #rstats package mclust provides results that are identical to 
##  5 "RT @dataandme: \U0001f60e\U0001f4e6 for changing up your R-\U0001f4ca text
##  6 "RT @dataandme: \U0001f60e\U0001f4e6 for changing up your R-\U0001f4ca text
##  7 "RT @ellessenne: That feeling \U0001f525 thanks #devtools! Interested in co
##  8 "RT @ma_salmon: @zevross I'll stop the link dumping I promise, but @astroer
##  9 @zevross I'll stop the link dumping I promise, but @astroeringrand's recent
## 10 RT @keyboardpipette: @RyanEs Done: https://t.co/kuLOh3liMj My first #rstats
## # ... with 90 more rows
```

## See Also

- Twitter standard [search operators](https://developer.twitter.com/en/docs/tweets/search/guides/standard-operators)
