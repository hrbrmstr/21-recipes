# Extracting Tweet Entities

## Problem

You want to extract tweet entities such as `@mentions`, `#hashtags`, and short URLs from Twitter search results or other batches of tweets.

## Solution

Use `rtweet::search_tweets()` or any of the _timeline_ functions in `rtweet`.

## Discussion

Michael has provided a very powerful search interace for Twitter data mining. `rtweet::search_tweets()` retrieves, parses and extracts an asounding amount of data for you to then use. Let's search Twitter for the `#rstats` hashtag and see what is available:


```r
library(rtweet)
library(tidyverse)
```

```r
(rstats <- search_tweets("#rstats", n=300)) # pull 300 tweets that used the "#rstats" hashtag
```

```
## # A tibble: 300 x 42
##             status_id          created_at            user_id
##                 <chr>              <dttm>              <chr>
##  1 948590403036569601 2018-01-03 16:22:30          280608149
##  2 948590359524786176 2018-01-03 16:22:20 781583089667420161
##  3 948590304223006721 2018-01-03 16:22:07          594746010
##  4 948590234584911872 2018-01-03 16:21:50          144529492
##  5 948589562187735040 2018-01-03 16:19:10          280455470
##  6 948589232838332416 2018-01-03 16:17:51           18057156
##  7 948589231332560896 2018-01-03 16:17:51 732217484972048384
##  8 948588899265257472 2018-01-03 16:16:32          368551889
##  9 948588777152417793 2018-01-03 16:16:03           37686255
## 10 948588614715367424 2018-01-03 16:15:24         2865404679
## # ... with 290 more rows, and 39 more variables: screen_name <chr>,
## #   text <chr>, source <chr>, reply_to_status_id <chr>,
## #   reply_to_user_id <chr>, reply_to_screen_name <chr>, is_quote <lgl>,
## #   is_retweet <lgl>, favorite_count <int>, retweet_count <int>,
## #   hashtags <list>, symbols <list>, urls_url <list>, urls_t.co <list>,
## #   urls_expanded_url <list>, media_url <list>, media_t.co <list>,
## #   media_expanded_url <list>, media_type <list>, ext_media_url <list>,
## #   ext_media_t.co <list>, ext_media_expanded_url <list>,
## #   ext_media_type <lgl>, mentions_user_id <list>,
## #   mentions_screen_name <list>, lang <chr>, quoted_status_id <chr>,
## #   quoted_text <chr>, retweet_status_id <chr>, retweet_text <chr>,
## #   place_url <chr>, place_name <chr>, place_full_name <chr>,
## #   place_type <chr>, country <chr>, country_code <chr>,
## #   geo_coords <list>, coords_coords <list>, bbox_coords <list>
```

```r
glimpse(rstats)
```

```
## Observations: 300
## Variables: 42
## $ status_id              <chr> "948590403036569601", "9485903595247861...
## $ created_at             <dttm> 2018-01-03 16:22:30, 2018-01-03 16:22:...
## $ user_id                <chr> "280608149", "781583089667420161", "594...
## $ screen_name            <chr> "cortinah", "LynnYarmey", "thibaultdej"...
## $ text                   <chr> "Airline passenger safety has clearly i...
## $ source                 <chr> "TweetDeck", "Twitter for iPhone", "Twi...
## $ reply_to_status_id     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
## $ reply_to_user_id       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
## $ reply_to_screen_name   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
## $ is_quote               <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALS...
## $ is_retweet             <lgl> FALSE, TRUE, FALSE, FALSE, FALSE, TRUE,...
## $ favorite_count         <int> 0, 0, 0, 1, 1, 0, 0, 2, 1, 0, 0, 0, 0, ...
## $ retweet_count          <int> 0, 11, 0, 0, 2, 9, 15, 1, 0, 15, 4, 0, ...
## $ hashtags               <list> [<"rstats", "ggplot2">, "rstats", "rst...
## $ symbols                <list> [NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
## $ urls_url               <list> [NA, NA, "tidyverse.org/articles/2017/...
## $ urls_t.co              <list> [NA, NA, "https://t.co/xFf78u9sIX", "h...
## $ urls_expanded_url      <list> [NA, NA, "https://www.tidyverse.org/ar...
## $ media_url              <list> ["http://pbs.twimg.com/media/DSoOd51Wk...
## $ media_t.co             <list> ["https://t.co/DNifWLdiVY", NA, NA, NA...
## $ media_expanded_url     <list> ["https://twitter.com/cortinah/status/...
## $ media_type             <list> ["photo", NA, NA, NA, NA, NA, "photo",...
## $ ext_media_url          <list> ["http://pbs.twimg.com/media/DSoOd51Wk...
## $ ext_media_t.co         <list> ["https://t.co/DNifWLdiVY", NA, NA, NA...
## $ ext_media_expanded_url <list> ["https://twitter.com/cortinah/status/...
## $ ext_media_type         <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
## $ mentions_user_id       <list> [NA, <"189172089", "862680370436874240...
## $ mentions_screen_name   <list> [NA, <"rgfitzjohn", "vaccineimpact">, ...
## $ lang                   <chr> "en", "en", "fr", "en", "en", "en", "en...
## $ quoted_status_id       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
## $ quoted_text            <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
## $ retweet_status_id      <chr> NA, "948501344989663233", NA, NA, NA, "...
## $ retweet_text           <chr> NA, "Last week to apply for our #rstats...
## $ place_url              <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
## $ place_name             <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
## $ place_full_name        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
## $ place_type             <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
## $ country                <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
## $ country_code           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
## $ geo_coords             <list> [<NA, NA>, <NA, NA>, <NA, NA>, <NA, NA...
## $ coords_coords          <list> [<NA, NA>, <NA, NA>, <NA, NA>, <NA, NA...
## $ bbox_coords            <list> [<NA, NA, NA, NA, NA, NA, NA, NA>, <NA...
```

From the output, you can see that all the URLs (short and expanded), status id's, user id's and other hashtags are all available and all in a [tidy](http://r4ds.had.co.nz/tidy-data.html) data frame. 

What are the top 10 (with ties) other hashtags used in conjunction with `#rstats` (for this search group)?


```r
select(rstats, hashtags) %>% 
  unnest() %>% 
  mutate(hashtags = tolower(hashtags)) %>% 
  count(hashtags, sort=TRUE) %>% 
  filter(hashtags != "rstats") %>% 
  top_n(10)
```

```
## # A tibble: 10 x 2
##           hashtags     n
##              <chr> <int>
##  1     datascience    60
##  2         bigdata    23
##  3         ggplot2    15
##  4          python    15
##  5         dataviz    13
##  6 machinelearning    11
##  7           abdsc    10
##  8          dbplyr    10
##  9           dplyr    10
## 10      statistics    10
```

## See Also

- Official Twitter [search API](https://developer.twitter.com/en/docs/tweets/search/guides/build-standard-query) documentation
- Twitter [entites](https://developer.twitter.com/en/docs/tweets/data-dictionary/overview/entities-object) information
- The [tidyverse](https://www.tidyverse.org/) introduction.
