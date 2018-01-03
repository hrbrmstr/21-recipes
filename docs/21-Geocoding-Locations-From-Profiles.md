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
##                      location        lat         lon
##                         <chr>      <dbl>       <dbl>
##  1                       Peru  -9.189967  -75.015152
##  2     Richmond, B.C., Canada  49.166590 -123.133569
##  3              Massachusetts  42.407211  -71.382437
##  4              Frederick, MD  39.414269  -77.410541
##  5                      Japan  36.204824  138.252924
##  6                        FMU  34.190425  -79.651985
##  7                Chicago, IL  41.878114  -87.629798
##  8                       日本  36.204824  138.252924
##  9             北大・環境科学  43.072764  141.346112
## 10         Stuttgart, Germany  48.775846    9.182932
## 11               New York, NY  40.712775  -74.005973
## 12            Asbury Park, NJ  40.220391  -74.012082
## 13              Ann Arbor, MI  42.280826  -83.743038
## 14                 Ithaca, NY  42.443961  -76.501881
## 15 ÜT: 36.1573208,-95.9526115  40.532392 -112.298984
## 16                Houston, TX  29.760427  -95.369803
## 17                   Rome, NY  43.212847  -75.455730
## 18           Perth, Australia -31.950527  115.860457
## 19               Santiago, CL -33.448890  -70.669265
## 20               Johnston, IA  41.670983  -93.713049
## 21           Fort Collins, CO  40.585260 -105.084423
## 22           Hyderabad, India  17.385044   78.486671
## 23              Nashville, TN  36.162664  -86.781602
## 24                Canton, CHN  23.129110  113.264385
## 25                     Bogotá   4.710989  -74.072092
## 26            3052, Australia -37.786236  144.947418
## 27        Charlottesville, VA  38.029306  -78.476678
## 28           Hobart, Tasmania -42.882138  147.327195
## 29                       moon  40.516977  -80.221348
## 30           Toronto, Ontario  43.653226  -79.383184
## # ... with 473 more rows
```

## See Also

Google's API is far from perfect, but they have also been collecting gnarly input data for map locations for over a decade, which makes them a good first-choice. You can find more R geocoding packages in the CRAN [Web Technologies](https://cran.r-project.org/web/views/WebTechnologies.html) Task View.
