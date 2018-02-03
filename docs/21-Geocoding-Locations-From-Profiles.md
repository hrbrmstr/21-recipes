# Geocoding Locations from Profiles (or Elsewhere)

## Problem

You want to geocode information in tweets for situations beyond what the Twitter API provides and not just focus on U.S. states as Ecipe 20 did.

## Solution

Use a geocoding service/package to translate location strings into more precise geographic information.

## Discussion

Recipe 20 focused on extracting U.S. state information from user profiles. But, Twitter is a global service with millions of active users in many countries. Let's use the Google geocoding API function from the `ggmaps` package to try to translate user profile location strings into location data.

>NOTE: Google's API has a limit of 2,500 calls per day for free, so you'll need to pay-up or work in daily batches if you have a large amount of Tweet location data to lookup.


```r
library(rtweet)
library(ggmap)
library(tidyverse)
```

```r
rstats_us <- search_tweets("#rstats", 3000)

user_info <- lookup_users(unique(rstats_us$user_id))

discard(user_info$location, `==`, "") %>% 
  ggmap::geocode() -> coded

coded$location <- discard(user_info$location, `==`, "")

user_info <- left_join(user_info, coded, "location")
```


```
## # A tibble: 503 x 3
##                                        location        lat
##                                           <chr>      <dbl>
##  1                                         Peru  -9.189967
##  2                       Richmond, B.C., Canada  49.166590
##  3                                Massachusetts  42.407211
##  4                                Frederick, MD  39.414269
##  5                                        Japan  36.204824
##  6                                          FMU  34.190425
##  7                                  Chicago, IL  41.878114
##  8                               "\u65e5\u672c"  36.204824
##  9 "\u5317\u5927\u30fb\u74b0\u5883\u79d1\u5b66"  43.072764
## 10                           Stuttgart, Germany  48.775846
## 11                                 New York, NY  40.712775
## 12                              Asbury Park, NJ  40.220391
## 13                                Ann Arbor, MI  42.280826
## 14                                   Ithaca, NY  42.443961
## 15            "\u00dcT: 36.1573208,-95.9526115"  40.532392
## 16                                  Houston, TX  29.760427
## 17                                     Rome, NY  43.212847
## 18                             Perth, Australia -31.950527
## 19                                 Santiago, CL -33.448890
## 20                                 Johnston, IA  41.670983
## 21                             Fort Collins, CO  40.585260
## 22                             Hyderabad, India  17.385044
## 23                                Nashville, TN  36.162664
## 24                                  Canton, CHN  23.129110
## 25                                "Bogot\u00e1"   4.710989
## 26                              3052, Australia -37.786236
## 27                          Charlottesville, VA  38.029306
## 28                             Hobart, Tasmania -42.882138
## 29                                         moon  40.516977
## 30                             Toronto, Ontario  43.653226
## # ... with 473 more rows, and 1 more variables: lon <dbl>
```

## See Also

Google's API is far from perfect, but they have also been collecting gnarly input data for map locations for over a decade, which makes them a good first-choice. You can find more R geocoding packages in the CRAN [Web Technologies](https://cran.r-project.org/web/views/WebTechnologies.html) Task View.
