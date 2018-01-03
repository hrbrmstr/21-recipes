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
##  1 Airline passenger safety has clearly immeasurably improved under the presen
##  2 J'aimerais que plus de profs d'économétrie lisent ceci https://t.co/xFf78u9
##  3 The new version of tidycensus for @uscensusbureau data in #rstats (version 
##  4 I couldn't resist and I just signed up @DataCamp using this promo https://t
##  5 What is the most efficient way to apply the same function to elements of a 
##  6 My team is growing again. Looking to hire a couple managers on a really fun
##  7 I find it verrry difficult to read #rstats code where if statements have no
##  8 "Microsoft SQL Server R Services - Internals XVII.\nUsing WinDbg to find ou
##  9 "Adobe Illustrator swallows time. I spent the entire day creating the conce
## 10 Rbloggers Helpful Data Science Reads https://t.co/QxVddTUaj7 #Rstats #DataS
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
##  1 @kearneymw @MattJStannard This is going to come in really handy for me in t
##  2                                              @kearneymw @slcathena And bam!
##  3 "@kearneymw @jhollist @dmi3k @ucfagls Could be worse: I brought an entire t
##  4                    @kearneymw Well, the algorithm's namesake, in that case.
##  5 "@kearneymw His namesake died from an intestinal blockage. Where are the sh
##  6 @kearneymw @BreitbartNews First thing's first: Breitbart is NOT 'news'.  Na
##  7 @kearneymw @Twitter interesting. This is what I see https://t.co/PVcuXp8u0r
##  8 "@kearneymw @Grantimus9 Dang, he was right again.\n\nDebate world is small!
##  9                                     @kearneymw Amazing. Indeed. @Grantimus9
## 10                   "@kearneymw Really good. Thanks. \n\n...Eating more fish"
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
##  1 The new version of tidycensus for @uscensusbureau data in #rstats (version 
##  2 RT @krlmlr: Soon on CRAN: Joint profiling of #rstats and native code, with 
##  3 RT @krlmlr: Soon on CRAN: Joint profiling of #rstats and native code, with 
##  4 RT @krlmlr: Soon on CRAN: Joint profiling of #rstats and native code, with 
##  5 RT @krlmlr: Soon on CRAN: Joint profiling of #rstats and native code, with 
##  6 RT @noamross: Had a little New Year's brainstorm for an @rOpenSci #rstats p
##  7 RT @noamross: Had a little New Year's brainstorm for an @rOpenSci #rstats p
##  8 RT @sbmalev: To all 4 of you doing fire history analysis in #rstats: burnr 
##  9 RT @kwbroman: I think my default should be to always include NAs in any sca
## 10 RT @sbmalev: To all 4 of you doing fire history analysis in #rstats: burnr 
## # ... with 90 more rows
```

## See Also

- Twitter standard [search operators](https://developer.twitter.com/en/docs/tweets/search/guides/standard-operators)
