# Geocoding Locations from Profiles (or Elsewhere)

## Problem

You want to geocode information in tweets for situations beyond what the Twitter API provides and not just focus on U.S. states as Recipe 20 did.

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
##    location                      lat     lon
##    <chr>                       <dbl>   <dbl>
##  1 Peru                        -9.19  -75.0 
##  2 Richmond, B.C., Canada      49.2  -123.  
##  3 Massachusetts               42.4   -71.4 
##  4 Frederick, MD               39.4   -77.4 
##  5 Japan                       36.2   138.  
##  6 FMU                         34.2   -79.7 
##  7 Chicago, IL                 41.9   -87.6 
##  8 日本                        36.2   138.  
##  9 北大・環境科学              43.1   141.  
## 10 Stuttgart, Germany          48.8     9.18
## 11 New York, NY                40.7   -74.0 
## 12 Asbury Park, NJ             40.2   -74.0 
## 13 Ann Arbor, MI               42.3   -83.7 
## 14 Ithaca, NY                  42.4   -76.5 
## 15 ÜT: 36.1573208,-95.9526115  40.5  -112.  
## 16 Houston, TX                 29.8   -95.4 
## 17 Rome, NY                    43.2   -75.5 
## 18 Perth, Australia           -32.0   116.  
## 19 Santiago, CL               -33.4   -70.7 
## 20 Johnston, IA                41.7   -93.7 
## 21 Fort Collins, CO            40.6  -105.  
## 22 Hyderabad, India            17.4    78.5 
## 23 Nashville, TN               36.2   -86.8 
## 24 Canton, CHN                 23.1   113.  
## 25 Bogotá                       4.71  -74.1 
## 26 3052, Australia            -37.8   145.  
## 27 Charlottesville, VA         38.0   -78.5 
## 28 Hobart, Tasmania           -42.9   147.  
## 29 moon                        40.5   -80.2 
## 30 Toronto, Ontario            43.7   -79.4 
## # ... with 473 more rows
```

## See Also

Google's API is far from perfect, but they have also been collecting gnarly input data for map locations for over a decade, which makes them a good first-choice. You can find more R geocoding packages in the CRAN [Web Technologies](https://cran.r-project.org/web/views/WebTechnologies.html) Task View.
