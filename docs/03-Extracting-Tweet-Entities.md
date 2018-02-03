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
##  1 948239409790337024 2018-01-02 17:07:47           62219905
##  2 948238781018136577 2018-01-02 17:05:17 844152803991994368
##  3 948238133396758529 2018-01-02 17:02:43         1885980073
##  4 948237585435983873 2018-01-02 17:00:32         2311645130
##  5 948237466556825600 2018-01-02 17:00:04 933993004133732352
##  6 948237231604621312 2018-01-02 16:59:08         2359597790
##  7 948236927194542080 2018-01-02 16:57:55             944231
##  8 948236596352114689 2018-01-02 16:56:36 734457714567438337
##  9 948235971501481985 2018-01-02 16:54:07 847851963773460481
## 10 948235268297052161 2018-01-02 16:51:19         1308811981
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
## $ status_id              <chr> "948239409790337024", "9482387810181365...
## $ created_at             <dttm> 2018-01-02 17:07:47, 2018-01-02 17:05:...
## $ user_id                <chr> "62219905", "844152803991994368", "1885...
## $ screen_name            <chr> "alisonmarigold", "rweekly_live", "C_Ba...
## $ text                   <chr> "RT @sellorm: Introducing the Field Gui...
## $ source                 <chr> "Carbon v.2", "R Weekly Live", "Twitter...
## $ reply_to_status_id     <chr> NA, NA, NA, NA, NA, NA, "94823184946102...
## $ reply_to_user_id       <chr> NA, NA, NA, NA, NA, NA, "18931434", NA,...
## $ reply_to_screen_name   <chr> NA, NA, NA, NA, NA, NA, "RussellSPierce...
## $ is_quote               <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALS...
## $ is_retweet             <lgl> TRUE, FALSE, TRUE, FALSE, FALSE, FALSE,...
## $ favorite_count         <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...
## $ retweet_count          <int> 100, 0, 13, 0, 0, 0, 0, 1, 15, 100, 0, ...
## $ hashtags               <list> ["rstats", <"rstats", "datascience">, ...
## $ symbols                <list> [NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
## $ urls_url               <list> ["blog.sellorm.com/2018/01/01/fie\u202...
## $ urls_t.co              <list> ["https://t.co/Hfrs1fi74u", "https://t...
## $ urls_expanded_url      <list> ["http://blog.sellorm.com/2018/01/01/f...
## $ media_url              <list> [NA, NA, "http://pbs.twimg.com/media/D...
## $ media_t.co             <list> [NA, NA, "https://t.co/W7OtYESyEG", "h...
## $ media_expanded_url     <list> [NA, NA, "https://twitter.com/dataandm...
## $ media_type             <list> [NA, NA, "photo", "photo", "photo", NA...
## $ ext_media_url          <list> [NA, NA, "http://pbs.twimg.com/media/D...
## $ ext_media_t.co         <list> [NA, NA, "https://t.co/W7OtYESyEG", "h...
## $ ext_media_expanded_url <list> [NA, NA, "https://twitter.com/dataandm...
## $ ext_media_type         <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
## $ mentions_user_id       <list> ["14351134", "25213966", "3230388598",...
## $ mentions_screen_name   <list> ["sellorm", "MicrosoftR", "dataandme",...
## $ lang                   <chr> "en", "en", "en", "en", "en", "en", "en...
## $ quoted_status_id       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
## $ quoted_text            <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
## $ retweet_status_id      <chr> "947909537859809281", NA, "947954865464...
## $ retweet_text           <chr> "Introducing the Field Guide to the #rs...
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
## # A tibble: 11 x 2
##          hashtags     n
##             <chr> <int>
##  1    datascience    43
##  2         python    19
##  3        dataviz    12
##  4        newyear    11
##  5      tidyverse     8
##  6              r     7
##  7        ggplot2     6
##  8     regression     6
##  9 soccersalaries     6
## 10      analytics     5
## 11        bigdata     5
```

## See Also

- Official Twitter [search API](https://developer.twitter.com/en/docs/tweets/search/guides/build-standard-query) documentation
- Twitter [entites](https://developer.twitter.com/en/docs/tweets/data-dictionary/overview/entities-object) information
- The [tidyverse](https://www.tidyverse.org/) introduction.
