# Looking Up the Trending Topics

## Problem

You want to keep track of the trending topics on Twitter over a period of time.

## Solution

Use `rtweet::trends_available()` to see trend areas and `rtweet::get_trends()` to pull trends, after which you can setup a task to retrieve and cache the trend data periodically.

## Discussion

Twitter has [extensive information](https://help.twitter.com/en/using-twitter/twitter-trending-faqs) on trending topics and their API enables you to see topics that are trending globally or regionally. Twitter uses [Yahoo! Where on Earth](https://developer.yahoo.com/geo/geoplanet/guide/concepts.html) identifiers (WOEIDs) for the regions which can be obtained from `rtweet::trends_available()`:


```r
library(rtweet)
library(tidyverse)
```

```r
(trends_avail <- trends_available())
```

```
## # A tibble: 467 x 8
##          name                                       url parentid
##  *      <chr>                                     <chr>    <int>
##  1  Worldwide     http://where.yahooapis.com/v1/place/1        0
##  2   Winnipeg  http://where.yahooapis.com/v1/place/2972 23424775
##  3     Ottawa  http://where.yahooapis.com/v1/place/3369 23424775
##  4     Quebec  http://where.yahooapis.com/v1/place/3444 23424775
##  5   Montreal  http://where.yahooapis.com/v1/place/3534 23424775
##  6    Toronto  http://where.yahooapis.com/v1/place/4118 23424775
##  7   Edmonton  http://where.yahooapis.com/v1/place/8676 23424775
##  8    Calgary  http://where.yahooapis.com/v1/place/8775 23424775
##  9  Vancouver  http://where.yahooapis.com/v1/place/9807 23424775
## 10 Birmingham http://where.yahooapis.com/v1/place/12723 23424975
## # ... with 457 more rows, and 5 more variables: country <chr>,
## #   woeid <int>, countryCode <chr>, code <int>, place_type <chr>
```

```r
glimpse(trends_avail)
```

```
## Observations: 467
## Variables: 8
## $ name        <chr> "Worldwide", "Winnipeg", "Ottawa", "Quebec", "Mont...
## $ url         <chr> "http://where.yahooapis.com/v1/place/1", "http://w...
## $ parentid    <int> 0, 23424775, 23424775, 23424775, 23424775, 2342477...
## $ country     <chr> "", "Canada", "Canada", "Canada", "Canada", "Canad...
## $ woeid       <int> 1, 2972, 3369, 3444, 3534, 4118, 8676, 8775, 9807,...
## $ countryCode <chr> NA, "CA", "CA", "CA", "CA", "CA", "CA", "CA", "CA"...
## $ code        <int> 19, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7...
## $ place_type  <chr> "Supername", "Town", "Town", "Town", "Town", "Town...
```

The Twitter API is somewhat unforgiving and unfriendly when you use it directly since it requires the use of a WOEID. Michael has made life much easier for us all by enabling the use of names or regular expressions when asking for trends from a particular place. That means we don't even need to care about capitalization:


```r
(us <- get_trends("united states"))
```

```
## # A tibble: 50 x 9
##                          trend
##  *                       <chr>
##  1                 #backtowork
##  2            #TuesdayThoughts
##  3          #SavannahHodaTODAY
##  4           Justin Timberlake
##  5 #MyTVShowWasCanceledBecause
##  6                      #AM2DM
##  7            Carrie Underwood
##  8            The Trump Effect
##  9                   Sean Ryan
## 10               Micah Parsons
## # ... with 40 more rows, and 8 more variables: url <chr>,
## #   promoted_content <lgl>, query <chr>, tweet_volume <int>, place <chr>,
## #   woeid <int>, as_of <dttm>, created_at <dttm>
```

```r
glimpse(us)
```

```
## Observations: 50
## Variables: 9
## $ trend            <chr> "#backtowork", "#TuesdayThoughts", "#Savannah...
## $ url              <chr> "http://twitter.com/search?q=%23backtowork", ...
## $ promoted_content <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
## $ query            <chr> "%23backtowork", "%23TuesdayThoughts", "%23Sa...
## $ tweet_volume     <int> 27544, 30822, 10279, NA, NA, NA, NA, 12000, N...
## $ place            <chr> "United States", "United States", "United Sta...
## $ woeid            <int> 23424977, 23424977, 23424977, 23424977, 23424...
## $ as_of            <dttm> 2018-01-02 16:34:11, 2018-01-02 16:34:11, 20...
## $ created_at       <dttm> 2018-01-02 16:27:46, 2018-01-02 16:27:46, 20...
```

Twitter's [documentation](https://developer.twitter.com/en/docs/trends/trends-for-location/api-reference/get-trends-place) states that trends are updated every 5 minutes, which means you should not call the API more frequently than that and their current API rate-limit (Twitter puts some restrictions on how frequently you can call certain API targets) is 75 requests per 15-minute window.

The `rtweet::get_trends()` function returns a data frame. Our ultimate goal is to retrieve the trends data on a schedule and cache it. There are numerous --- and usually complex -- ways to schedule jobs. One cross-platform solution is to use R itself to run a task periodically. This means keeping an R console open and running at all times, so is far from an optimal solution. See the [`taskscheduleR`](https://github.com/bnosac/taskscheduleR) package for other ideas on how to setup more robust scheduled jobs.

In this example, we will:

- use a [SQLite](https://www.sqlite.org/) database to store the trends
- use the `DBI` add `RSQlite` packages to work with this database
- setup a never-ending loop with `Sys.sleep()` providing a pause between requests


```r
library(DBI)
library(RSQLite)
library(rtweet) # mkearney/rtweet

repeat {
  message("Retrieveing trends...") # optional
  us <- get_trends("united states")
  db_con <- dbConnect(RSQLite::SQLite(), "data/us-trends.db")
  dbWriteTable(db_con, "us_trends", us, append=TRUE) # append=TRUE will update the table vs overwrite and also create it on first run if it does not exist
  dbDisconnect(db_con)
  Sys.sleep(10 * 60) # sleep for 10 minutes
}
```

Later on, we can look at this data with `dplyr`/`dbplyr`:


```r
library(dplyr)

trends_db <- src_sqlite("data/us-trends.db")
us <- tbl(trends_db, "us_trends")
select(us, trend)
```

```
## # Source:   lazy query [?? x 1]
## # Database: sqlite 3.19.3
## #   [/Users/hrbrmstr/Development/21-recipes/data/us-trends.db]
##                          trend
##                          <chr>
##  1            #TuesdayThoughts
##  2                 #backtowork
##  3          #SavannahHodaTODAY
##  4           Justin Timberlake
##  5 #MyTVShowWasCanceledBecause
##  6                      #AM2DM
##  7            The Trump Effect
##  8            Carrie Underwood
##  9                   Sean Ryan
## 10               Larry Krasner
## # ... with more rows
```

## See Also

- [`RSQlite`](https://www.r-project.org/nosvn/pandoc/RSQLite.html) quick reference
- Introduction to `dbplyr` : <http://dbplyr.tidyverse.org/articles/dbplyr.html>
