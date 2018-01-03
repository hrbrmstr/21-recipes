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
##               user_id                name     screen_name
##                 <chr>               <chr>           <chr>
##  1         1217315090 Women in Statistics     WomenInStat
##  2          172176348               Heidi ideaofhappiness
##  3          554300827     Nujcharee (เป็ด)       Nujcharee
##  4 746493721215008768 Vidhya Kalaichelvan   itsmevidhya_k
##  5            5685812           b❆B Rudis        hrbrmstr
##  6          280608149    Hernando Cortina        cortinah
##  7 781583089667420161         Lynn Yarmey      LynnYarmey
##  8          594746010   Thibault Dejeanne     thibaultdej
##  9          144529492         Kyle Walker   kyle_e_walker
## 10          280455470         Tom Martens    tommartens68
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
## $ user_id                <chr> "1217315090", "172176348", "554300827",...
## $ name                   <chr> "Women in Statistics", "Heidi", "Nujcha...
## $ screen_name            <chr> "WomenInStat", "ideaofhappiness", "Nujc...
## $ location               <chr> "USA", "North Carolina", "North Yorkshi...
## $ description            <chr> "Enticing, Elevating and Empowering the...
## $ url                    <chr> "http://t.co/6ZTyTgVzrn", NA, NA, "http...
## $ protected              <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALS...
## $ followers_count        <int> 958, 830, 539, 48, 9139, 48, 329, 168, ...
## $ friends_count          <int> 253, 988, 660, 98, 389, 80, 382, 151, 5...
## $ listed_count           <int> 34, 96, 229, 30, 612, 2, 19, 8, 204, 10...
## $ statuses_count         <int> 275, 12316, 4447, 6367, 71001, 221, 215...
## $ favourites_count       <int> 68, 7434, 6363, 3931, 11019, 140, 3010,...
## $ account_created_at     <dttm> 2013-02-25 04:45:27, 2010-07-29 02:27:...
## $ verified               <lgl> FALSE, FALSE, FALSE, FALSE, TRUE, FALSE...
## $ profile_url            <chr> "http://t.co/6ZTyTgVzrn", NA, NA, "http...
## $ profile_expanded_url   <chr> "http://women-in-stats.org", NA, NA, "h...
## $ account_lang           <chr> "en", "en", "en", "en", "en", "en", "en...
## $ profile_banner_url     <chr> NA, "https://pbs.twimg.com/profile_bann...
## $ profile_background_url <chr> "http://abs.twimg.com/images/themes/the...
## $ profile_image_url      <chr> "http://pbs.twimg.com/profile_images/33...
```

## See Also

- [Official Twitter API documentation](https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-users-lookup) on users.
