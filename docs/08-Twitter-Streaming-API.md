# Capturing Tweets in Real-time with the Streaming API

## Problem

You want to capture a stream of public tweets in real-time, optionally filtering by select screen names or keywords in the text of the tweet.

## Solution

Use `rtweet::stream_tweets()`.

## Discussion

Michael has --- once again --- made it way too easy to work with Twitter's API. The `rtweet::stream_tweets()` function has tons of handy options to help capture tweets in real time. The primary `q` parameter is very versatile and has four possible capture modes:

- The default, `q = ""`, returns a small random sample of all publicly available Twitter statuses.
- To filter by keyword, provide a comma separated character string with the desired phrase(s) and keyword(s).
- Track users by providing a comma separated list of user IDs or screen names.
- Use four latitude/longitude bounding box points to stream by geo location. This must be provided via a vector of length 4, e.g., `c(-125, 26, -65, 49)`.

Let's capture one minute of tweets in the good ol' U S of A (this is one of Michael's examples from the manual page for `rtweet::stream_tweets()`.


```r
library(rtweet)
library(tidyverse)
```

```r
stream_tweets(
  lookup_coords("usa"), # handy helper function in rtweet
  verbose = FALSE,
  timeout = (60 * 1),
) -> usa
```

```
##  Found 500 records... Found 1000 records... Found 1500 records... Found 1560 records... Imported 1560 records. Simplifying...
```

A 60 second stream resulted in well over 1,000 records. 

Where are they tweeting from?


```r
count(usa, place_full_name, sort=TRUE)
```

```
## # A tibble: 854 x 2
##    place_full_name         n
##    <chr>               <int>
##  1 Los Angeles, CA        35
##  2 Manhattan, NY          34
##  3 Houston, TX            29
##  4 North Carolina, USA    18
##  5 Texas, USA             18
##  6 Chicago, IL            15
##  7 Florida, USA           13
##  8 Georgia, USA           13
##  9 Indianapolis, IN       13
## 10 San Antonio, TX        13
## # ... with 844 more rows
```

What are they tweeting about?


```r
unnest(usa, hashtags) %>% 
  count(hashtags, sort=TRUE) %>% 
  filter(!is.na(hashtags))
```

```
## # A tibble: 541 x 2
##    hashtags       n
##    <chr>      <int>
##  1 job          346
##  2 CareerArc    294
##  3 Hiring       240
##  4 hiring       132
##  5 Job           74
##  6 Jobs          74
##  7 IT            20
##  8 Accounting    15
##  9 HR            14
## 10 Retail        12
## # ... with 531 more rows
```

What app are they using?


```r
count(usa, source, sort=TRUE)
```

```
## # A tibble: 23 x 2
##    source                  n
##    <chr>               <int>
##  1 Twitter for iPhone    806
##  2 TweetMyJOBS           472
##  3 Twitter for Android   135
##  4 Twitter Web Client     46
##  5 Instagram              40
##  6 Twitter for iPad       19
##  7 Foursquare              8
##  8 Tweetbot for iΟS        8
##  9 Cities                  6
## 10 "Beer Menus "           3
## # ... with 13 more rows
```

Michael covers the streaming topic in-depth in [a vignette](http://rtweet.info/articles/stream.html).

## See Also

- [Consuming streaming data](https://developer.twitter.com/en/docs/tutorials/consuming-streaming-data)
