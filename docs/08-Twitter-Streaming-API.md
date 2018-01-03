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
##  Found 500 records... Found 1000 records... Found 1238 records... Imported 1238 records. Simplifying...
```

A 60 second stream resulted in well over 1,000 records. 

Where are they tweeting from?


```r
count(usa, place_full_name, sort=TRUE)
```

```
## # A tibble: 686 x 2
##     place_full_name     n
##               <chr> <int>
##  1    Manhattan, NY    28
##  2      Houston, TX    26
##  3  Los Angeles, CA    23
##  4     Florida, USA    22
##  5      Chicago, IL    20
##  6     Georgia, USA    19
##  7       Texas, USA    15
##  8 Toronto, Ontario    15
##  9     Brooklyn, NY    14
## 10 Philadelphia, PA    13
## # ... with 676 more rows
```

What are they tweeting about?


```r
unnest(usa, hashtags) %>% 
  count(hashtags, sort=TRUE) %>% 
  filter(!is.na(hashtags))
```

```
## # A tibble: 321 x 2
##          hashtags     n
##             <chr> <int>
##  1            job    73
##  2      CareerArc    45
##  3         Hiring    44
##  4         hiring    32
##  5            Job    20
##  6           Jobs    20
##  7         Retail    13
##  8 WPMOYChallenge    10
##  9    Hospitality     4
## 10         Boston     3
## # ... with 311 more rows
```

What app are they using?


```r
count(usa, source, sort=TRUE)
```

```
## # A tibble: 27 x 2
##                      source     n
##                       <chr> <int>
##  1       Twitter for iPhone   818
##  2      Twitter for Android   175
##  3              TweetMyJOBS    91
##  4                Instagram    58
##  5       Twitter Web Client    40
##  6         Twitter for iPad    14
##  7 SafeTweet by TweetMyJOBS     8
##  8               Foursquare     6
##  9         Tweetbot for Mac     5
## 10                circlepix     3
## # ... with 17 more rows
```

Michael covers the streaming topic in-depth in [a vignette](http://rtweet.info/articles/stream.html).

## See Also

- [Consuming streaming data](https://developer.twitter.com/en/docs/tutorials/consuming-streaming-data)
