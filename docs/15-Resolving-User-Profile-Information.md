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
## # A tibble: 29 x 20
##       user_id                       name     screen_name
##         <chr>                      <chr>           <chr>
##  1  453028244           Lutra Consulting lutraconsulting
##  2   61190451                  pacoramon       pacoramon
##  3  347261357         David Rubal, CISSP       DaveRubal
##  4   97174061             Claudia Vitolo       clavitolo
##  5   54220643           Darren Wilkinson     wilkinsondi
##  6  379204076         "Cruz Juli\u00e1n"    Cruz_Julian_
##  7  111561495         Alfie Abdul-Rahman     thisisalfie
##  8  169920416 "h(o x o_)m\uff1c Moanin'"          hoxo_m
##  9 1579555238             Peter Meissner      marvin_dpr
## 10  720477266                     Luz Ka       databayou
## # ... with 19 more rows, and 17 more variables: location <chr>,
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
## Observations: 29
## Variables: 20
## $ user_id                <chr> "453028244", "61190451", "347261357", "...
## $ name                   <chr> "Lutra Consulting", "pacoramon", "David...
## $ screen_name            <chr> "lutraconsulting", "pacoramon", "DaveRu...
## $ location               <chr> "United Kingdom", "Zaragoza", "Washingt...
## $ description            <chr> "Lutra Consulting Ltd provides consulta...
## $ url                    <chr> "http://t.co/mKCfOH5S4j", "https://t.co...
## $ protected              <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALS...
## $ followers_count        <int> 818, 1297, 4003, 567, 636, 325, 265, 26...
## $ friends_count          <int> 312, 5001, 3035, 426, 698, 710, 418, 36...
## $ listed_count           <int> 34, 493, 2511, 17, 97, 15, 15, 77, 75, ...
## $ statuses_count         <int> 1095, 11820, 49591, 492, 1729, 1254, 76...
## $ favourites_count       <int> 403, 27902, 18510, 1401, 16, 354, 659, ...
## $ account_created_at     <dttm> 2012-01-02 14:10:17, 2009-07-29 13:11:...
## $ verified               <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALS...
## $ profile_url            <chr> "http://t.co/mKCfOH5S4j", "https://t.co...
## $ profile_expanded_url   <chr> "http://www.lutraconsulting.co.uk", "ht...
## $ account_lang           <chr> "en", "es", "en", "en", "en", "es", "en...
## $ profile_banner_url     <chr> NA, "https://pbs.twimg.com/profile_bann...
## $ profile_background_url <chr> "http://abs.twimg.com/images/themes/the...
## $ profile_image_url      <chr> "http://pbs.twimg.com/profile_images/52...
```

## See Also

- [Official Twitter API documentation](https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-users-lookup) on users.
