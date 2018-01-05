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
##  Found 500 records... Found 1000 records... Found 1323 records... Imported 1323 records. Simplifying...
```

A 60 second stream resulted in well over 1,000 records. 

Where are they tweeting from?


```r
count(usa, place_full_name, sort=TRUE)
```

```
## # A tibble: 724 x 2
##      place_full_name     n
##                <chr> <int>
##  1   Los Angeles, CA    31
##  2       Houston, TX    28
##  3     Manhattan, NY    24
##  4      Florida, USA    19
##  5      Georgia, USA    18
##  6   California, USA    16
##  7 Pennsylvania, USA    16
##  8        Texas, USA    15
##  9     Charlotte, NC    14
## 10       Chicago, IL    14
## # ... with 714 more rows
```

What are they tweeting about?


```r
unnest(usa, hashtags) %>% 
  count(hashtags, sort=TRUE) %>% 
  filter(!is.na(hashtags))
```

```
## # A tibble: 289 x 2
##          hashtags     n
##             <chr> <int>
##  1            job    60
##  2      CareerArc    46
##  3         Hiring    43
##  4         hiring    23
##  5            Job    12
##  6           Jobs    12
##  7    Hospitality     7
##  8 Transportation     6
##  9     Healthcare     5
## 10        Nursing     5
## # ... with 279 more rows
```

What app are they using?


```r
count(usa, source, sort=TRUE)
```

```
## # A tibble: 26 x 2
##                      source     n
##                       <chr> <int>
##  1       Twitter for iPhone   894
##  2      Twitter for Android   190
##  3              TweetMyJOBS    81
##  4                Instagram    62
##  5       Twitter Web Client    43
##  6  "Tweetbot for i\u039fS"    10
##  7               Foursquare     6
##  8         Twitter for iPad     6
##  9                   Cities     4
## 10 SafeTweet by TweetMyJOBS     4
## # ... with 16 more rows
```

Michael covers the streaming topic in-depth in [a vignette](http://rtweet.info/articles/stream.html).

## See Also

- [Consuming streaming data](https://developer.twitter.com/en/docs/tutorials/consuming-streaming-data)
