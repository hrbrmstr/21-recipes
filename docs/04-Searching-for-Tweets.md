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
## # A tibble: 92 x 1
##    text                                                                   
##    <chr>                                                                  
##  1 Just published an update to the #tidycensus documentation: a table sho…
##  2 "Is Stagraph Open Source?\n#DataVisualization #dataviz #DataAnalytics …
##  3 Day 13: Sometimes I doubt my commitment to #sparklines. #rstats #100Da…
##  4 How to detect heteroscedasticity and rectify it? https://t.co/kq5lVSAh…
##  5 runs scored and allowed #MLB #dataviz #rstats https://t.co/m21biXBWwE  
##  6 CRAN updates: cati xyloplot https://t.co/y5W2NTKSXT #rstats            
##  7 #rstats pkgdown discovery- if you format your function name correctly …
##  8 I've felt one very-long and super-annoying day away from being compete…
##  9 This looks like a really interesting addition to #rstats with #shiny h…
## 10 BTRY 6020 has been my favorite course @Cornell. @JoeGuinnesss ended th…
## # ... with 82 more rows
```

or, all the recent tweet-replies sent to `@kearneymw`:


```r
search_tweets("to:kearneymw") %>%
  select(text)
```

```
## # A tibble: 94 x 1
##    text                                                                   
##    <chr>                                                                  
##  1 @kearneymw Adverts all over public transit stations too.               
##  2 @kearneymw I like it, better than falling back on the truth that earni…
##  3 @kearneymw 🤦                                                          
##  4 @kearneymw It is trying to tell you something about importance of usin…
##  5 @kearneymw Ugh this is a @josephofiowa joke if I ever heard one        
##  6 @kearneymw and, of course, it's pres elecs                             
##  7 @gelliottmorris But obvi that original tweet was overselling regardles…
##  8 @kearneymw 😂                                                          
##  9 @kearneymw I 💜 this and want to read your replies...how do I find you …
## 10 @kearneymw magic mike                                                  
## # ... with 84 more rows
```

and, even all the `#rstats` tweets that have GitHub links in them (but no `#python` hashtags):


```r
search_tweets("#rstats url:github -#python") %>% 
  select(text)
```

```
## # A tibble: 100 x 1
##    text                                                                   
##    <chr>                                                                  
##  1 RT @_pvictorr: Pimp your #shiny apps with custom input control from pa…
##  2 RT @_pvictorr: Some fun with #r2d3: maps in D3 (made possible by aweso…
##  3 RT @ingorohlfing: @Thoughtfulnz I am not sure whether it helps, but yo…
##  4 RT @David_McGaughey: Let’s Plot 6: Simple guide to ComplexHeatmaps htt…
##  5 RT @David_McGaughey: Let’s Plot 6: Simple guide to ComplexHeatmaps htt…
##  6 RT @JennyBryan: I think these worked examples of operating on a data f…
##  7 Finally, while I plan to retain maintainership, if you have any intere…
##  8 RT @David_McGaughey: Let’s Plot 6: Simple guide to ComplexHeatmaps htt…
##  9 RT @jilly_mackay: *Deep breath* Okay! I have some #rstats teaching mat…
## 10 RT @David_McGaughey: Let’s Plot 6: Simple guide to ComplexHeatmaps htt…
## # ... with 90 more rows
```

## See Also

- Twitter standard [search operators](https://developer.twitter.com/en/docs/tweets/search/guides/standard-operators)
