# Resolving User Profile Information

## Problem

You have a collection of ids and need to resolve basic profile information (such as screen names) for these users.

## Solution

Use `rtweet::lookup_users()`.

## Discussion

The `rtweet` interface to the Twitter API makes this task very straightforward.


```r
library(rtweet)
library(tidyverse)
```

```r
rstats <- rtweet::search_tweets("#rstats", n=30)

(recent_rtweeters <- lookup_users(unique(rstats$user_id)))
```

```
## # A tibble: 27 x 20
##               user_id                   name     screen_name
##                 <chr>                  <chr>           <chr>
##  1         2938142309                Flavien  flavien_perier
##  2          534563976             Kirk Borne      KirkDBorne
##  3          368551889    Isabella R. Ghement IsabellaGhement
##  4         2429747641      J. Vandekerckhove VandekerckhoveJ
##  5          588438037          Carlos Ospino carlos_g_ospino
##  6         2491600901   Suman Kumar Pramanik sumankumarpram1
##  7           18238982          Thomas Hütter        DerFredo
##  8          144592995             R-bloggers       Rbloggers
##  9 875903982530514945 ふにゅ ver.3.5.0_1.0.0      hunyufunyu
## 10 932657569822228480               swami_ds        swamids1
## # ... with 17 more rows, and 17 more variables: location <chr>,
## #   description <chr>, url <chr>, protected <lgl>, followers_count <int>,
## #   friends_count <int>, listed_count <int>, statuses_count <int>,
## #   favourites_count <int>, account_created_at <dttm>, verified <lgl>,
## #   profile_url <chr>, profile_expanded_url <chr>, account_lang <chr>,
## #   profile_banner_url <chr>, profile_background_url <chr>,
## #   profile_image_url <chr>
```

```r
glimpse(recent_rtweeters)
```

```
## Observations: 27
## Variables: 20
## $ user_id                <chr> "2938142309", "534563976", "368551889",...
## $ name                   <chr> "Flavien", "Kirk Borne", "Isabella R. G...
## $ screen_name            <chr> "flavien_perier", "KirkDBorne", "Isabel...
## $ location               <chr> "Limoges, France", "Booz Allen Hamilton...
## $ description            <chr> "Passionné d'#informatique, et d'#intel...
## $ url                    <chr> "https://t.co/KBu65E640Z", "https://t.c...
## $ protected              <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALS...
## $ followers_count        <int> 3105, 182446, 1386, 926, 625, 69, 769, ...
## $ friends_count          <int> 4834, 49666, 3361, 394, 642, 114, 727, ...
## $ listed_count           <int> 105, 6903, 275, 32, 52, 16, 104, 1706, ...
## $ statuses_count         <int> 58934, 80925, 15600, 1826, 13605, 464, ...
## $ favourites_count       <int> 38523, 130382, 25042, 294, 9403, 222, 2...
## $ account_created_at     <dttm> 2014-12-23 10:21:08, 2012-03-23 16:35:...
## $ verified               <lgl> FALSE, TRUE, FALSE, FALSE, FALSE, FALSE...
## $ profile_url            <chr> "https://t.co/KBu65E640Z", "https://t.c...
## $ profile_expanded_url   <chr> "http://www.flavien.cc", "http://www.li...
## $ account_lang           <chr> "fr", "en", "en", "en", "en", "en", "de...
## $ profile_banner_url     <chr> "https://pbs.twimg.com/profile_banners/...
## $ profile_background_url <chr> "http://pbs.twimg.com/profile_backgroun...
## $ profile_image_url      <chr> "http://pbs.twimg.com/profile_images/71...
```

## See Also

- [Official Twitter API documentation](https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-users-lookup) on users.
