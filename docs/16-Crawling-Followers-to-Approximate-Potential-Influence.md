---
output: html_document
editor_options: 
  chunk_output_type: console
---
# Crawling Followers to Approximate Primary Influence

## Problem

You want to approximate someone’s influence based upon their popularity and the popularity of their followers.

## Solution

Use the `rtweet::lookup_users()` and `rtweet::get_followers()` combination to pull primary influence and derive "primary influence" based on "followers-of-followers" counts.

## Discussion

"Influence" is _extremely_ more nuanced than both what the original Python chapter delved into and what this exercise shows. Building "#-removed" total reach counts from a large tree traversal (as the Python version suggests) is worthless on face-value since it doesn't take into account how many times any of the 'n-depth' of followers ever retweeted or even favorited content posted by the seminal user over the course of a certain period. Without gathering such stats, multi-depth "followers-of-followers" is nigh meaningless.

_However_, once-removed (so the follower counts of those directly following the target user) has some merit. Marketing folks have varying names for this statistic, so we'll just call it "primary influence" since there is legitimate potential of reaching this once-removed audience. Ideally, the retweet- and fav-counts should be factored in, but that can be added on as an exercise.

Let's create a helper function that will capture a snapshot of this _primary influence_ metric. It will take in a user id or name, pull in that user info and the details of their followers (specify `TRUE` to the `all` parameter if the user has more than 5,000 followers and you want to wait even longer to get their complete influence) and then sum up all the follower counts to get the overall reach number. It returns this information (so it can be processed again without API calls) but also produces a graph of the "number of followers" distribution of the first-level followers. This is usually a heavily skewed distribution so the function also defaults to a log scale, but can be overridden to use a linear scale (log scale will be the correct choice the vast majority of the time, but the function can be modified --- as an exercise -- to test the distribution and auto-pick scales).


```r
library(rtweet)
library(hrbrthemes)
library(tidyverse)
```


```r
influence_snapshot <- function(user, all = FALSE, trans=c("log10", "identity")) {
  
  user <- user[1]
  trans <- match.arg(tolower(trimws(trans[1])), c("log10", "identity"))
  
  scale_lab <- ""
  if (trans == "log10") sclae_lab <- " (log scale)"
  
  user_info <- lookup_users(user)
  
  n <- if (all[1]) user_info$followers_count else 5000
  
  user_followers <- get_followers(user_info$user_id)
  uf_details <- lookup_users(user_followers$user_id)
  
  primary_influence <- sum(c(uf_details$followers_count, user_info$followers_count))
  
  filter(uf_details, followers_count > 0) %>% 
    ggplot(aes(followers_count)) +
    geom_density(aes(y=..count..), color="lightslategray", fill="lightslategray",
                 alpha=2/3, size=1) +
    scale_x_continuous(expand=c(0,0), trans=trans, labels=scales::comma) +
    scale_y_comma() +
    labs(
      x=sprintf("Number of Followers of Followers%s", scale_lab), 
      y="Number of Followers",
      title=sprintf("Follower chain distribution of %s (@%s)", user_info$name, user_info$screen_name),
      subtitle=sprintf("Follower count: %s; Primary influence/reach: %s", 
                       scales::comma(user_info$followers_count),
                       scales::comma(primary_influence))
    ) +
    theme_ipsum_rc(grid="XY") -> gg
  
  print(gg)
  
  return(invisible(list(user_info=user_info, follower_details=uf_details)))
  
}
```

Let's run it on [Julia Silge](https://twitter.com/juliasilge), an incredibly talented data scientist over at Stack Overflow and co-author of [Tidy Text Mining with R](https://www.tidytextmining.com/) --- a book that should be on your shelf _especially_ if you're doing Twitter mining.


```r
juliasilge <- influence_snapshot("juliasilge")
```

<img src="16-Crawling-Followers-to-Approximate-Potential-Influence_files/figure-html/16_js-1.png" width="960" />

```r
glimpse(juliasilge)
```

```
## List of 2
##  $ user_info       :Classes 'tbl_df', 'tbl' and 'data.frame':	1 obs. of  87 variables:
##   ..$ user_id                : chr "13074042"
##   ..$ name                   : chr "Julia Silge"
##   ..$ screen_name            : chr "juliasilge"
##   ..$ location               : chr "Salt Lake City, UT"
##   ..$ description            : chr "Data science and visualization at @StackOverflow, #rstats, author of Text Mining with R, parenthood."
##   ..$ url                    : chr "https://t.co/FHvuUC23eg"
##   ..$ protected              : logi FALSE
##   ..$ followers_count        : int 15074
##   ..$ friends_count          : int 494
##   ..$ listed_count           : int 511
##   ..$ statuses_count         : int 17473
##   ..$ favourites_count       : int 23514
##   ..$ account_created_at     : POSIXct[1:1], format: "2008-02-05 00:47:07"
##   ..$ verified               : logi FALSE
##   ..$ profile_url            : chr "https://t.co/FHvuUC23eg"
##   ..$ profile_expanded_url   : chr "https://juliasilge.com/"
##   ..$ account_lang           : chr "en"
##   ..$ profile_banner_url     : chr "https://pbs.twimg.com/profile_banners/13074042/1517974680"
##   ..$ profile_background_url : chr "http://abs.twimg.com/images/themes/theme13/bg.gif"
##   ..$ profile_image_url      : chr "http://pbs.twimg.com/profile_images/930639796510244865/D_N-CofS_normal.jpg"
##   ..$ status_id              : chr "994185929328738305"
##   ..$ created_at             : POSIXct[1:1], format: "2018-05-09 12:02:51"
##   ..$ text                   : chr "RT @adamrpearce: *Finally* published my piece on why the subways have slowed down so much since I moved to NYC "| __truncated__
##   ..$ source                 : chr "Twitter for iPhone"
##   ..$ display_text_width     : int NA
##   ..$ reply_to_status_id     : logi NA
##   ..$ reply_to_user_id       : logi NA
##   ..$ reply_to_screen_name   : logi NA
##   ..$ is_quote               : logi FALSE
##   ..$ is_retweet             : logi TRUE
##   ..$ favorite_count         : int 0
##   ..$ retweet_count          : int 291
##   ..$ hashtags               :List of 1
##   .. ..$ : chr NA
##   ..$ symbols                :List of 1
##   .. ..$ : chr NA
##   ..$ urls_url               :List of 1
##   .. ..$ : chr NA
##   ..$ urls_t.co              :List of 1
##   .. ..$ : chr NA
##   ..$ urls_expanded_url      :List of 1
##   .. ..$ : chr NA
##   ..$ media_url              :List of 1
##   .. ..$ : chr NA
##   ..$ media_t.co             :List of 1
##   .. ..$ : chr NA
##   ..$ media_expanded_url     :List of 1
##   .. ..$ : chr NA
##   ..$ media_type             :List of 1
##   .. ..$ : chr NA
##   ..$ ext_media_url          :List of 1
##   .. ..$ : chr NA
##   ..$ ext_media_t.co         :List of 1
##   .. ..$ : chr NA
##   ..$ ext_media_expanded_url :List of 1
##   .. ..$ : chr NA
##   ..$ ext_media_type         : chr NA
##   ..$ mentions_user_id       :List of 1
##   .. ..$ : chr "555102816"
##   ..$ mentions_screen_name   :List of 1
##   .. ..$ : chr "adamrpearce"
##   ..$ lang                   : chr "en"
##   ..$ quoted_status_id       : chr NA
##   ..$ quoted_text            : chr NA
##   ..$ quoted_created_at      : POSIXct[1:1], format: NA
##   ..$ quoted_source          : chr NA
##   ..$ quoted_favorite_count  : int NA
##   ..$ quoted_retweet_count   : int NA
##   ..$ quoted_user_id         : chr NA
##   ..$ quoted_screen_name     : chr NA
##   ..$ quoted_name            : chr NA
##   ..$ quoted_followers_count : int NA
##   ..$ quoted_friends_count   : int NA
##   ..$ quoted_statuses_count  : int NA
##   ..$ quoted_location        : chr NA
##   ..$ quoted_description     : chr NA
##   ..$ quoted_verified        : logi NA
##   ..$ retweet_status_id      : chr "994180171379957762"
##   ..$ retweet_text           : chr "*Finally* published my piece on why the subways have slowed down so much since I moved to NYC five years ago.… "| __truncated__
##   ..$ retweet_created_at     : POSIXct[1:1], format: "2018-05-09 11:39:58"
##   ..$ retweet_source         : chr NA
##   ..$ retweet_favorite_count : int 706
##   ..$ retweet_retweet_count  : int 291
##   ..$ retweet_user_id        : chr NA
##   ..$ retweet_screen_name    : chr NA
##   ..$ retweet_name           : chr NA
##   ..$ retweet_followers_count: int NA
##   ..$ retweet_friends_count  : int NA
##   ..$ retweet_statuses_count : int NA
##   ..$ retweet_location       : chr NA
##   ..$ retweet_description    : chr NA
##   ..$ retweet_verified       : logi NA
##   ..$ place_url              : chr NA
##   ..$ place_name             : chr NA
##   ..$ place_full_name        : chr NA
##   ..$ place_type             : chr NA
##   ..$ country                : chr NA
##   ..$ country_code           : chr NA
##   ..$ geo_coords             :List of 1
##   .. ..$ : num [1:2] NA NA
##   ..$ coords_coords          :List of 1
##   .. ..$ : num [1:2] NA NA
##   ..$ bbox_coords            :List of 1
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##  $ follower_details:Classes 'tbl_df', 'tbl' and 'data.frame':	4336 obs. of  87 variables:
##   ..$ user_id                : chr [1:4336] "5511242" "18176555" "15769985" "23010579" ...
##   ..$ name                   : chr [1:4336] "John Mulligan \U0001f4ca" "nathanetaylor" "naseers" "Vinay Yadappanavar" ...
##   ..$ screen_name            : chr [1:4336] "jpmulligan" "nathanetaylor" "naseers" "vinaymy" ...
##   ..$ location               : chr [1:4336] "United States" "" "" "" ...
##   ..$ description            : chr [1:4336] "Engineer." "" "" "" ...
##   ..$ url                    : chr [1:4336] NA NA NA NA ...
##   ..$ protected              : logi [1:4336] FALSE FALSE FALSE FALSE FALSE FALSE ...
##   ..$ followers_count        : int [1:4336] 7 9 20 176 6 6 59 14 6 81 ...
##   ..$ friends_count          : int [1:4336] 46 33 511 441 27 37 293 27 204 2153 ...
##   ..$ listed_count           : int [1:4336] 0 0 0 0 0 0 0 0 0 1 ...
##   ..$ statuses_count         : int [1:4336] 1 1 3 47 4 1 80 1 7 2 ...
##   ..$ favourites_count       : int [1:4336] 25 1 17 0 0 1 0 0 3 7 ...
##   ..$ account_created_at     : POSIXct[1:4336], format: "2007-04-25 23:41:10" ...
##   ..$ verified               : logi [1:4336] FALSE FALSE FALSE FALSE FALSE FALSE ...
##   ..$ profile_url            : chr [1:4336] NA NA NA NA ...
##   ..$ profile_expanded_url   : chr [1:4336] NA NA NA NA ...
##   ..$ account_lang           : chr [1:4336] "en" "en" "en" "en" ...
##   ..$ profile_banner_url     : chr [1:4336] "https://pbs.twimg.com/profile_banners/5511242/1512875378" NA NA NA ...
##   ..$ profile_background_url : chr [1:4336] "http://abs.twimg.com/images/themes/theme1/bg.png" "http://abs.twimg.com/images/themes/theme1/bg.png" "http://abs.twimg.com/images/themes/theme1/bg.png" "http://abs.twimg.com/images/themes/theme1/bg.png" ...
##   ..$ profile_image_url      : chr [1:4336] "http://pbs.twimg.com/profile_images/939692761544052737/MSBrvC9x_normal.jpg" "http://abs.twimg.com/sticky/default_profile_images/default_profile_normal.png" "http://abs.twimg.com/sticky/default_profile_images/default_profile_normal.png" "http://pbs.twimg.com/profile_images/110990915/74201849608_0_ALB_normal.jpg" ...
##   ..$ status_id              : chr [1:4336] "39976742" "1061742772" "1481373987" "3518977454" ...
##   ..$ created_at             : POSIXct[1:4336], format: "2007-04-25 23:41:00" ...
##   ..$ text                   : chr [1:4336] "Signing up for Twitter!" "I have finished my Christmas shopping" "@emilysiddique booooooooooooooooooo!" "@amitseshan Thanks for recos, will check them out. Meanwhile go back follow discussion on my blog and @lakshmia"| __truncated__ ...
##   ..$ source                 : chr [1:4336] "Twitter Web Client" "Twitter Web Client" "Twitter Web Client" "Twitter Web Client" ...
##   ..$ display_text_width     : int [1:4336] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ reply_to_status_id     : chr [1:4336] NA NA NA NA ...
##   ..$ reply_to_user_id       : chr [1:4336] NA NA "29775417" "16119053" ...
##   ..$ reply_to_screen_name   : chr [1:4336] NA NA "emilysiddique" "amitseshan" ...
##   ..$ is_quote               : logi [1:4336] FALSE FALSE FALSE FALSE FALSE FALSE ...
##   ..$ is_retweet             : logi [1:4336] FALSE FALSE FALSE FALSE FALSE FALSE ...
##   ..$ favorite_count         : int [1:4336] 0 3 0 3 0 2 0 0 2 27 ...
##   ..$ retweet_count          : int [1:4336] 0 3 0 0 0 0 0 0 5 5 ...
##   ..$ hashtags               :List of 4336
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "fb"
##   .. ..$ : chr "Illini"
##   .. ..$ : chr "mtv"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "coolerthanme"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:6] "Stanford" "ND" "fightingirish" "fearthetree" ...
##   .. ..$ : chr NA
##   .. ..$ : chr "PS3"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "myfirstTweet"
##   .. ..$ : chr "RunKeeper"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "tripleganchosolidario"
##   .. ..$ : chr NA
##   .. ..$ : chr "kzone"
##   .. ..$ : chr [1:3] "Kazan" "Russia" "Scorpions"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "laundry" "hackathons"
##   .. ..$ : chr NA
##   .. ..$ : chr "ChennaiFloods"
##   .. ..$ : chr "BioInfoSummer2015"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "ZOZOTOWN福引"
##   .. ..$ : chr [1:2] "AWSomeDay" "AmazonGlacier"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "hacksummit"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "AnnabelleFashionStar" "WhatIsSexy"
##   .. ..$ : chr NA
##   .. ..$ : chr "awwneversorry"
##   .. ..$ : chr [1:2] "MSSQL" "sqlserver"
##   .. ..$ : chr "slitherio"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "halfkgoulu"
##   .. ..$ : chr [1:2] "الإمارات" "الحمدلله_على_نعمة_الإمارات"
##   .. ..$ : chr "esf16"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "zdfemlive"
##   .. ..$ : chr "EURO2016"
##   .. ..$ : chr "EURefResults"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "خرجوا_مالك_عدلي"
##   .. .. [list output truncated]
##   ..$ symbols                :List of 4336
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ urls_url               :List of 4336
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "emacswiki.org/emacs/Twitteri…"
##   .. ..$ : chr NA
##   .. ..$ : chr "lnkd.in/YTdTsM"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "wapo.st/VJqYXt"
##   .. ..$ : chr NA
##   .. ..$ : chr "huff.to/15BvVGT"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "politiken.dk/debat/kroniken…"
##   .. ..$ : chr "bankier.pl/wiadomosc/Kied…"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "rnkpr.com/a6b4c2y"
##   .. ..$ : chr "instagram.com/p/qJYNl1OxIk/"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "wapo.st/1kHGUuh"
##   .. ..$ : chr NA
##   .. ..$ : chr "wp.me/p4sXQo-11"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "twitter.com/WojYahooNBA/st…"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "embank.tk/?t.co=@chadewa…"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "goo.gl/t5pWcg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "bit.ly/1WO2qBO?yrukyp…"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "twitter.com/josh_wills/sta…"
##   .. ..$ : chr NA
##   .. ..$ : chr "t.zozo.jp/crsu9"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "bit.ly/1MpKwtr"
##   .. ..$ : chr "bit.ly/20H17kD"
##   .. ..$ : chr "stacksocial.com/sales/git-trai…"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "i.victoria.com/wis"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "macsqlclient.com"
##   .. ..$ : chr "slither.io"
##   .. ..$ : chr "lnkd.in/e3S3gdK"
##   .. ..$ : chr "ctt.ec/A4ptI+"
##   .. ..$ : chr NA
##   .. ..$ : chr "twitter.com/intlspectator/…"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "dlvr.it/Lm0hgw"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ urls_t.co              :List of 4336
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/Sw1oPYhj"
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/ged3mmRB"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/9E9Mpny0"
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/qGqtJykA4Q"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/uJtGyKJSBX"
##   .. ..$ : chr "http://t.co/Jo2Eiuw8Td"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/LZE8GeswZT"
##   .. ..$ : chr "http://t.co/Iaf8JzPOHk"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/pkBQA8F0wm"
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/rCfBzWGW9s"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/tNcJ0eXm2l"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/hD6nXmPKuP"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/RNbH56sg45"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/jYSnt9nN0x"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/lSlUTIVh3p"
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/B0s8kTfBpQ"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/rX1AjWQwqG"
##   .. ..$ : chr "https://t.co/bUvmeZytSe"
##   .. ..$ : chr "https://t.co/Ws4ohrXKNF"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/ADrCmZcoxT"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/8D5xt5Xsyg"
##   .. ..$ : chr "https://t.co/8MaJpffBE0"
##   .. ..$ : chr "https://t.co/tuWYFTXyKD"
##   .. ..$ : chr "https://t.co/LumtoKCzjP"
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/UWGaAjJ66X"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/3RM42A9GUQ"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ urls_expanded_url      :List of 4336
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://www.emacswiki.org/emacs/TwitteringMode"
##   .. ..$ : chr NA
##   .. ..$ : chr "http://lnkd.in/YTdTsM"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://wapo.st/VJqYXt"
##   .. ..$ : chr NA
##   .. ..$ : chr "http://huff.to/15BvVGT"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://politiken.dk/debat/kroniken/ECE2249036/da-jeg-fik-en-tumor-paa-stoerrelse-med-en-mandarin-i-hjernen/"
##   .. ..$ : chr "http://www.bankier.pl/wiadomosc/Kiedy-najlepiej-kupic-akcje-3098262.html"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://rnkpr.com/a6b4c2y"
##   .. ..$ : chr "http://instagram.com/p/qJYNl1OxIk/"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://wapo.st/1kHGUuh"
##   .. ..$ : chr NA
##   .. ..$ : chr "http://wp.me/p4sXQo-11"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/WojYahooNBA/status/618231787114749952"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://embank.tk?t.co=@chadewalker72"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://goo.gl/t5pWcg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://bit.ly/1WO2qBO?yrukypuw47443"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/josh_wills/status/198093512149958656"
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.zozo.jp/crsu9"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://bit.ly/1MpKwtr"
##   .. ..$ : chr "http://bit.ly/20H17kD"
##   .. ..$ : chr "https://stacksocial.com/sales/git-training-course?rid=2825938"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://i.victoria.com/wis"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://macsqlclient.com"
##   .. ..$ : chr "http://slither.io"
##   .. ..$ : chr "https://lnkd.in/e3S3gdK"
##   .. ..$ : chr "http://ctt.ec/A4ptI+"
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/intlspectator/status/722122708696236033"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://dlvr.it/Lm0hgw"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ media_url              :List of 4336
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/BlKt7s8CIAASE6z.png"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/CGQ6EdSUQAAMVPI.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/CV0-mp1VEAADXd8.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/CiOlw8cUUAAnzHG.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/ext_tw_video_thumb/744600189999128577/pu/img/dwIMM95y4tO6_tG0.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ media_t.co             :List of 4336
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/mvvXi6Zd61"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/9OhiX5j8Qs"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/TjeITQjRg4"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/XPEzwcX4FA"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/i7f2Pmhw2j"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ media_expanded_url     :List of 4336
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/piotrlonczak1/status/455617753496297472/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/scorpions/status/604672104617910272/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/shazanfar/status/674764370107170816/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/TaoYANLogos/status/730609870357962753/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/BriceBachon/status/744600246769098753/video/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ media_type             :List of 4336
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "photo"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "photo"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "photo"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "photo"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "photo"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ ext_media_url          :List of 4336
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/BlKt7s8CIAASE6z.png"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/CGQ6EdSUQAAMVPI.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/CV0-mp1VEAADXd8.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:4] "http://pbs.twimg.com/media/CiOlw8cUUAAnzHG.jpg" "http://pbs.twimg.com/media/CiOlwvPUUAArQzg.jpg" "http://pbs.twimg.com/media/CiOlzFhUUAATShq.jpg" "http://pbs.twimg.com/media/CiOlzFiU4AA3SvM.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/ext_tw_video_thumb/744600189999128577/pu/img/dwIMM95y4tO6_tG0.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ ext_media_t.co         :List of 4336
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/mvvXi6Zd61"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/9OhiX5j8Qs"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/TjeITQjRg4"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:4] "https://t.co/XPEzwcX4FA" "https://t.co/XPEzwcX4FA" "https://t.co/XPEzwcX4FA" "https://t.co/XPEzwcX4FA"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/i7f2Pmhw2j"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ ext_media_expanded_url :List of 4336
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/piotrlonczak1/status/455617753496297472/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/scorpions/status/604672104617910272/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/shazanfar/status/674764370107170816/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:4] "https://twitter.com/TaoYANLogos/status/730609870357962753/photo/1" "https://twitter.com/TaoYANLogos/status/730609870357962753/photo/1" "https://twitter.com/TaoYANLogos/status/730609870357962753/photo/1" "https://twitter.com/TaoYANLogos/status/730609870357962753/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/BriceBachon/status/744600246769098753/video/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ ext_media_type         : chr [1:4336] NA NA NA NA ...
##   ..$ mentions_user_id       :List of 4336
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "29775417"
##   .. ..$ : chr [1:2] "16119053" "28686579"
##   .. ..$ : chr NA
##   .. ..$ : chr "87855391"
##   .. ..$ : chr "10533432"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "16095150"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "35388404"
##   .. ..$ : chr [1:2] "424472595" "231305417"
##   .. ..$ : chr "84971762"
##   .. ..$ : chr [1:2] "17179368" "2467791"
##   .. ..$ : chr "19002481"
##   .. ..$ : chr "750683096643624964"
##   .. ..$ : chr [1:2] "1175221" "822911848198668290"
##   .. ..$ : chr "25537462"
##   .. ..$ : chr "21091570"
##   .. ..$ : chr "764468148"
##   .. ..$ : chr "19257569"
##   .. ..$ : chr "22864398"
##   .. ..$ : chr [1:4] "874916178" "28204284" "1155475272" "377505387"
##   .. ..$ : chr [1:6] "39092174" "14104847" "14996251" "89587925" ...
##   .. ..$ : chr [1:4] "24251248" "119728086" "62490772" "119728086"
##   .. ..$ : chr NA
##   .. ..$ : chr "1323117829"
##   .. ..$ : chr "2289756346"
##   .. ..$ : chr NA
##   .. ..$ : chr "15445811"
##   .. ..$ : chr NA
##   .. ..$ : chr "23372773"
##   .. ..$ : chr "281368876"
##   .. ..$ : chr NA
##   .. ..$ : chr "2467791"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "17502224"
##   .. ..$ : chr "389773164"
##   .. ..$ : chr "1891806212"
##   .. ..$ : chr "2557521"
##   .. ..$ : chr "337789021"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "12398782"
##   .. ..$ : chr "979305451"
##   .. ..$ : chr "59164949"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:4] "2273061926" "245871795" "89084561" "18534190"
##   .. ..$ : chr "485397054"
##   .. ..$ : chr "3462072440"
##   .. ..$ : chr [1:2] "849185080165662720" "552803420"
##   .. ..$ : chr NA
##   .. ..$ : chr "835335186"
##   .. ..$ : chr "82505537"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:4] "917555706" "6446742" "1877252551" "40945238"
##   .. ..$ : chr [1:2] "3165102498" "33868638"
##   .. ..$ : chr [1:2] "2848551188" "1859123587"
##   .. ..$ : chr NA
##   .. ..$ : chr "989583160538263553"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:3] "27743648" "38660877" "526316060"
##   .. ..$ : chr "58569513"
##   .. ..$ : chr "137390625"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "243742269"
##   .. ..$ : chr "24488318"
##   .. ..$ : chr "15492359"
##   .. ..$ : chr "16193578"
##   .. ..$ : chr "31301354"
##   .. ..$ : chr "24600452"
##   .. ..$ : chr "1094968022"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "763371275960147968"
##   .. ..$ : chr "44644062"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "707349612"
##   .. ..$ : chr "493127463"
##   .. ..$ : chr NA
##   .. ..$ : chr "22503279"
##   .. ..$ : chr "18953259"
##   .. ..$ : chr "160182741"
##   .. ..$ : chr NA
##   .. ..$ : chr "20113713"
##   .. ..$ : chr "18335375"
##   .. ..$ : chr [1:3] "13507972" "1339740637" "2720868859"
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ mentions_screen_name   :List of 4336
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "emilysiddique"
##   .. ..$ : chr [1:2] "amitseshan" "LakshmiA"
##   .. ..$ : chr NA
##   .. ..$ : chr "Cisco_Support"
##   .. ..$ : chr "olyapka"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "visarz"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "AdventureSam"
##   .. ..$ : chr [1:2] "metricjulie" "S_sants"
##   .. ..$ : chr "khyentsenorbu"
##   .. ..$ : chr [1:2] "Richard_Florida" "washingtonpost"
##   .. ..$ : chr "googlereader"
##   .. ..$ : chr "TomCoburn"
##   .. ..$ : chr [1:2] "digiphile" "CraigatFEMA"
##   .. ..$ : chr "markcrilley"
##   .. ..$ : chr "IreneOlivas"
##   .. ..$ : chr "MuseuArteRio"
##   .. ..$ : chr "BillyonBass"
##   .. ..$ : chr "jaswani"
##   .. ..$ : chr [1:4] "BeschlossDC" "kayniine" "instalanigram" "kelley_ec"
##   .. ..$ : chr [1:6] "dwlaratta" "comcastcares" "XFINITY" "comcast" ...
##   .. ..$ : chr [1:4] "AndersBreinholt" "NielsFrid" "Geocomedy" "NielsFrid"
##   .. ..$ : chr NA
##   .. ..$ : chr "FW312"
##   .. ..$ : chr "ahmdswat"
##   .. ..$ : chr NA
##   .. ..$ : chr "Runkeeper"
##   .. ..$ : chr NA
##   .. ..$ : chr "skottieyoung"
##   .. ..$ : chr "BrevilleAus"
##   .. ..$ : chr NA
##   .. ..$ : chr "washingtonpost"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "wobster"
##   .. ..$ : chr "TripleGancho"
##   .. ..$ : chr "AcademicsSay"
##   .. ..$ : chr "espn"
##   .. ..$ : chr "scorpions"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "netw3rk"
##   .. ..$ : chr "D3Centre"
##   .. ..$ : chr "ShopandShip"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:4] "KatieFettig" "JaimeDee1123" "Target" "DiversityWoman"
##   .. ..$ : chr "LikeMyWomen1"
##   .. ..$ : chr "PET_SMlLES"
##   .. ..$ : chr [1:2] "tsbible" "GetFootballNews"
##   .. ..$ : chr NA
##   .. ..$ : chr "vimukthisanjaya"
##   .. ..$ : chr "kmkelley2"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:4] "UFCNews" "ufc" "BuscapeMMA" "effyescudero"
##   .. ..$ : chr [1:2] "bharathshruti" "shrutihaasan"
##   .. ..$ : chr [1:2] "shazanfar" "combine_au"
##   .. ..$ : chr NA
##   .. ..$ : chr "EggYung"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:3] "Ticketmaster" "TicketmasterCA" "DaveChappelle"
##   .. ..$ : chr "DPRK_News"
##   .. ..$ : chr "bondbryanBIM"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "StackSocial"
##   .. ..$ : chr "MartaC17"
##   .. ..$ : chr "TEDTalks"
##   .. ..$ : chr "VictoriasSecret"
##   .. ..$ : chr "ashwinsuresh"
##   .. ..$ : chr "SaintFrankly"
##   .. ..$ : chr "SQLProApp"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "toptalllc"
##   .. ..$ : chr "AchaSetiarso"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "chasm_99"
##   .. ..$ : chr "carras16"
##   .. ..$ : chr NA
##   .. ..$ : chr "dreamteamfc"
##   .. ..$ : chr "Schofe"
##   .. ..$ : chr "tigrillodelsur"
##   .. ..$ : chr NA
##   .. ..$ : chr "WezSiddons"
##   .. ..$ : chr "Twittociate"
##   .. ..$ : chr [1:3] "rajeshkalra" "srikidambi" "Pvsindhu1"
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ lang                   : chr [1:4336] "en" "en" "und" "en" ...
##   ..$ quoted_status_id       : chr [1:4336] NA NA NA NA ...
##   ..$ quoted_text            : chr [1:4336] NA NA NA NA ...
##   ..$ quoted_created_at      : POSIXct[1:4336], format: NA ...
##   ..$ quoted_source          : chr [1:4336] NA NA NA NA ...
##   ..$ quoted_favorite_count  : int [1:4336] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ quoted_retweet_count   : int [1:4336] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ quoted_user_id         : chr [1:4336] NA NA NA NA ...
##   ..$ quoted_screen_name     : chr [1:4336] NA NA NA NA ...
##   ..$ quoted_name            : chr [1:4336] NA NA NA NA ...
##   ..$ quoted_followers_count : int [1:4336] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ quoted_friends_count   : int [1:4336] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ quoted_statuses_count  : int [1:4336] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ quoted_location        : chr [1:4336] NA NA NA NA ...
##   ..$ quoted_description     : chr [1:4336] NA NA NA NA ...
##   ..$ quoted_verified        : logi [1:4336] NA NA NA NA NA NA ...
##   ..$ retweet_status_id      : chr [1:4336] NA NA NA NA ...
##   ..$ retweet_text           : chr [1:4336] NA NA NA NA ...
##   ..$ retweet_created_at     : POSIXct[1:4336], format: NA ...
##   ..$ retweet_source         : chr [1:4336] NA NA NA NA ...
##   ..$ retweet_favorite_count : int [1:4336] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ retweet_retweet_count  : int [1:4336] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ retweet_user_id        : chr [1:4336] NA NA NA NA ...
##   ..$ retweet_screen_name    : chr [1:4336] NA NA NA NA ...
##   ..$ retweet_name           : chr [1:4336] NA NA NA NA ...
##   ..$ retweet_followers_count: int [1:4336] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ retweet_friends_count  : int [1:4336] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ retweet_statuses_count : int [1:4336] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ retweet_location       : chr [1:4336] NA NA NA NA ...
##   ..$ retweet_description    : chr [1:4336] NA NA NA NA ...
##   ..$ retweet_verified       : logi [1:4336] NA NA NA NA NA NA ...
##   ..$ place_url              : chr [1:4336] NA NA NA NA ...
##   ..$ place_name             : chr [1:4336] NA NA NA NA ...
##   ..$ place_full_name        : chr [1:4336] NA NA NA NA ...
##   ..$ place_type             : chr [1:4336] NA NA NA NA ...
##   ..$ country                : chr [1:4336] NA NA NA NA ...
##   ..$ country_code           : chr [1:4336] NA NA NA NA ...
##   ..$ geo_coords             :List of 4336
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. .. [list output truncated]
##   ..$ coords_coords          :List of 4336
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. .. [list output truncated]
##   ..$ bbox_coords            :List of 4336
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. .. [list output truncated]
```

You'll see that distribution shape quite a bit given the general nature of the social structure of Twitter. Don't believe that? Let's do one more, this time for [Maëlle Salmon](https://twitter.com/ma_salmon/), another incredibly talented data scientist with a [blog](http://www.masalmon.eu/) you _must_ follow if you want to learn how to do fun and useful things with R.


```r
ma_salmon <- influence_snapshot("ma_salmon")
```

<img src="16-Crawling-Followers-to-Approximate-Potential-Influence_files/figure-html/16_ms-1.png" width="960" />

```r
glimpse(ma_salmon)
```

```
## List of 2
##  $ user_info       :Classes 'tbl_df', 'tbl' and 'data.frame':	1 obs. of  87 variables:
##   ..$ user_id                : chr "2865404679"
##   ..$ name                   : chr "Maëlle Salmon \U0001f41f"
##   ..$ screen_name            : chr "ma_salmon"
##   ..$ location               : chr "Nancy, France"
##   ..$ description            : chr "PhD in statistics. \U0001f499#rstats. Living the FOSS dream working for @rOpenSci & @LockeData. Onboarding co-e"| __truncated__
##   ..$ url                    : chr "https://t.co/jaetRA6y4P"
##   ..$ protected              : logi FALSE
##   ..$ followers_count        : int 4825
##   ..$ friends_count          : int 382
##   ..$ listed_count           : int 158
##   ..$ statuses_count         : int 12625
##   ..$ favourites_count       : int 27434
##   ..$ account_created_at     : POSIXct[1:1], format: "2014-11-07 10:24:36"
##   ..$ verified               : logi FALSE
##   ..$ profile_url            : chr "https://t.co/jaetRA6y4P"
##   ..$ profile_expanded_url   : chr "http://www.masalmon.eu/"
##   ..$ account_lang           : chr "ca"
##   ..$ profile_banner_url     : chr "https://pbs.twimg.com/profile_banners/2865404679/1471789668"
##   ..$ profile_background_url : chr "http://pbs.twimg.com/profile_background_images/668084534081167360/yaV5nFT9.jpg"
##   ..$ profile_image_url      : chr "http://pbs.twimg.com/profile_images/703319700235808768/IOlpUXDQ_normal.jpg"
##   ..$ status_id              : chr "994297244026273792"
##   ..$ created_at             : POSIXct[1:1], format: "2018-05-09 19:25:10"
##   ..$ text                   : chr "@thomasp85 Actual #rstats hero logo credit @alice_data in https://t.co/zCre4ZWyGG ☺ https://t.co/Gg4KIfj7DD"
##   ..$ source                 : chr "Twitter for Android"
##   ..$ display_text_width     : int NA
##   ..$ reply_to_status_id     : chr "994295468388765697"
##   ..$ reply_to_user_id       : chr "611597719"
##   ..$ reply_to_screen_name   : chr "thomasp85"
##   ..$ is_quote               : logi FALSE
##   ..$ is_retweet             : logi FALSE
##   ..$ favorite_count         : int 4
##   ..$ retweet_count          : int 1
##   ..$ hashtags               :List of 1
##   .. ..$ : chr "rstats"
##   ..$ symbols                :List of 1
##   .. ..$ : chr NA
##   ..$ urls_url               :List of 1
##   .. ..$ : chr "github.com/adaish/R_hero"
##   ..$ urls_t.co              :List of 1
##   .. ..$ : chr "https://t.co/zCre4ZWyGG"
##   ..$ urls_expanded_url      :List of 1
##   .. ..$ : chr "https://github.com/adaish/R_hero"
##   ..$ media_url              :List of 1
##   .. ..$ : chr "http://pbs.twimg.com/media/Dcx0EoRX4AAnFZk.jpg"
##   ..$ media_t.co             :List of 1
##   .. ..$ : chr "https://t.co/Gg4KIfj7DD"
##   ..$ media_expanded_url     :List of 1
##   .. ..$ : chr "https://twitter.com/ma_salmon/status/994297244026273792/photo/1"
##   ..$ media_type             :List of 1
##   .. ..$ : chr "photo"
##   ..$ ext_media_url          :List of 1
##   .. ..$ : chr "http://pbs.twimg.com/media/Dcx0EoRX4AAnFZk.jpg"
##   ..$ ext_media_t.co         :List of 1
##   .. ..$ : chr "https://t.co/Gg4KIfj7DD"
##   ..$ ext_media_expanded_url :List of 1
##   .. ..$ : chr "https://twitter.com/ma_salmon/status/994297244026273792/photo/1"
##   ..$ ext_media_type         : chr NA
##   ..$ mentions_user_id       :List of 1
##   .. ..$ : chr [1:2] "611597719" "474823395"
##   ..$ mentions_screen_name   :List of 1
##   .. ..$ : chr [1:2] "thomasp85" "alice_data"
##   ..$ lang                   : chr "en"
##   ..$ quoted_status_id       : chr NA
##   ..$ quoted_text            : chr NA
##   ..$ quoted_created_at      : POSIXct[1:1], format: NA
##   ..$ quoted_source          : chr NA
##   ..$ quoted_favorite_count  : int NA
##   ..$ quoted_retweet_count   : int NA
##   ..$ quoted_user_id         : chr NA
##   ..$ quoted_screen_name     : chr NA
##   ..$ quoted_name            : chr NA
##   ..$ quoted_followers_count : int NA
##   ..$ quoted_friends_count   : int NA
##   ..$ quoted_statuses_count  : int NA
##   ..$ quoted_location        : chr NA
##   ..$ quoted_description     : chr NA
##   ..$ quoted_verified        : logi NA
##   ..$ retweet_status_id      : chr NA
##   ..$ retweet_text           : chr NA
##   ..$ retweet_created_at     : POSIXct[1:1], format: NA
##   ..$ retweet_source         : chr NA
##   ..$ retweet_favorite_count : int NA
##   ..$ retweet_retweet_count  : int NA
##   ..$ retweet_user_id        : chr NA
##   ..$ retweet_screen_name    : chr NA
##   ..$ retweet_name           : chr NA
##   ..$ retweet_followers_count: int NA
##   ..$ retweet_friends_count  : int NA
##   ..$ retweet_statuses_count : int NA
##   ..$ retweet_location       : chr NA
##   ..$ retweet_description    : chr NA
##   ..$ retweet_verified       : logi NA
##   ..$ place_url              : chr NA
##   ..$ place_name             : chr NA
##   ..$ place_full_name        : chr NA
##   ..$ place_type             : chr NA
##   ..$ country                : chr NA
##   ..$ country_code           : chr NA
##   ..$ geo_coords             :List of 1
##   .. ..$ : num [1:2] NA NA
##   ..$ coords_coords          :List of 1
##   .. ..$ : num [1:2] NA NA
##   ..$ bbox_coords            :List of 1
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##  $ follower_details:Classes 'tbl_df', 'tbl' and 'data.frame':	4421 obs. of  87 variables:
##   ..$ user_id                : chr [1:4421] "23186340" "28945753" "48975851" "44918206" ...
##   ..$ name                   : chr [1:4421] "Johan Reventlow" "Katja" "Puneet Vats" "Allen Cooper" ...
##   ..$ screen_name            : chr [1:4421] "johanreventlow" "dzepina" "vats_puneet" "ACintheIE" ...
##   ..$ location               : chr [1:4421] "Copenhagen" "" "" "" ...
##   ..$ description            : chr [1:4421] "Datanørd på Bispebjerg og Frederiksberg Hospital. #rstats #datascience #dataviz #healthcare #sundpol" "" "" "" ...
##   ..$ url                    : chr [1:4421] NA NA NA NA ...
##   ..$ protected              : logi [1:4421] FALSE FALSE FALSE FALSE FALSE FALSE ...
##   ..$ followers_count        : int [1:4421] 86 7 9 6 280 82 4 179 19 5 ...
##   ..$ friends_count          : int [1:4421] 880 6 43 204 5000 1581 32 3319 912 146 ...
##   ..$ listed_count           : int [1:4421] 0 1 0 0 2 1 0 0 0 0 ...
##   ..$ statuses_count         : int [1:4421] 2 1 1 7 6 7 3 2 2 1 ...
##   ..$ favourites_count       : int [1:4421] 199 0 0 3 53 7 3 8 80 65 ...
##   ..$ account_created_at     : POSIXct[1:4421], format: "2009-03-07 11:47:16" ...
##   ..$ verified               : logi [1:4421] FALSE FALSE FALSE FALSE FALSE FALSE ...
##   ..$ profile_url            : chr [1:4421] NA NA NA NA ...
##   ..$ profile_expanded_url   : chr [1:4421] NA NA NA NA ...
##   ..$ account_lang           : chr [1:4421] "da" "en" "en" "en" ...
##   ..$ profile_banner_url     : chr [1:4421] "https://pbs.twimg.com/profile_banners/23186340/1514984015" "https://pbs.twimg.com/profile_banners/28945753/1484856145" NA NA ...
##   ..$ profile_background_url : chr [1:4421] "http://abs.twimg.com/images/themes/theme1/bg.png" "http://abs.twimg.com/images/themes/theme1/bg.png" "http://abs.twimg.com/images/themes/theme1/bg.png" "http://abs.twimg.com/images/themes/theme1/bg.png" ...
##   ..$ profile_image_url      : chr [1:4421] "http://pbs.twimg.com/profile_images/90282133/johan__001_normal.jpg" "http://pbs.twimg.com/profile_images/822173347106660352/PePDCqPJ_normal.jpg" "http://abs.twimg.com/sticky/default_profile_images/default_profile_normal.png" "http://abs.twimg.com/sticky/default_profile_images/default_profile_normal.png" ...
##   ..$ status_id              : chr [1:4421] "1295968251" "4032034159" "13519314130" "26410004295" ...
##   ..$ created_at             : POSIXct[1:4421], format: "2009-03-08 10:21:26" ...
##   ..$ text                   : chr [1:4421] "drinking coffee in bed - AGAIN" "I need to start Tweeting!" "@hrishigads Come on facebook????" "Quote of the day: \"With the oven mitts of science fiction we can grasp the red-hot casserole of the now.\" -- "| __truncated__ ...
##   ..$ source                 : chr [1:4421] "Twitter Web Client" "Twitter Web Client" "Twitter Web Client" "Twitter Web Client" ...
##   ..$ display_text_width     : int [1:4421] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ reply_to_status_id     : chr [1:4421] NA NA "13461206914" NA ...
##   ..$ reply_to_user_id       : chr [1:4421] NA NA "45292558" NA ...
##   ..$ reply_to_screen_name   : chr [1:4421] NA NA "hrishigads" NA ...
##   ..$ is_quote               : logi [1:4421] FALSE FALSE FALSE FALSE FALSE FALSE ...
##   ..$ is_retweet             : logi [1:4421] FALSE FALSE FALSE FALSE FALSE TRUE ...
##   ..$ favorite_count         : int [1:4421] 30 0 0 2 2 0 0 4 3 0 ...
##   ..$ retweet_count          : int [1:4421] 14 0 0 5 12 2 1 2 0 35 ...
##   ..$ hashtags               :List of 4421
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "fb"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "NLProc"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "HangoutFest"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "Maghrenov"
##   .. ..$ : chr "RunKeeper"
##   .. ..$ : chr "attpark"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "myfirstTweet"
##   .. ..$ : chr "rstats"
##   .. ..$ : chr NA
##   .. ..$ : chr "YoutubeConnexionInternationaleNarvalo"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "MicrosoftAzure"
##   .. ..$ : chr [1:2] "fintech" "EFTA16"
##   .. ..$ : chr "Addo2016"
##   .. ..$ : chr "EnUnaSociedadSana"
##   .. ..$ : chr [1:3] "ECE" "investinkids" "edchat"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "SDGs" "ICT"
##   .. ..$ : chr "HTownTakeover"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:3] "WorldToiletDay" "TheLastMile" "GlobalCitizenIndia"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "vaccines"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "edtech"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "OlaDeFrioPolar"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "rstats"
##   .. ..$ : chr "RLadiesSuperPower"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "MappingTheCommons"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "babynames" "pregnancypic"
##   .. ..$ : chr "makeovermonday"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "EarthDay2017"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "donate" "cancerresearchuk"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:4] "onetablerestaurant" "onetable" "goodfood" "bestplace"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "myfirstTweet"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "CampoGrande"
##   .. ..$ : chr "runconf17"
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ symbols                :List of 4421
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ urls_url               :List of 4421
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "emacswiki.org/emacs/Twitteri…"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "bl0ggy.bl0ggy.in/kristine"
##   .. ..$ : chr "on.mtv.com/14ioXbr"
##   .. ..$ : chr "fw.to/yF0gyMD"
##   .. ..$ : chr "politiken.dk/debat/kroniken…"
##   .. ..$ : chr "goo.gl/4acWE5"
##   .. ..$ : chr "rnkpr.com/a6b4c2y"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "shar.es/1Xbfx3"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "computerworld.com/article/248642…"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "embank.tk/?t.co=@chadewa…"
##   .. ..$ : chr "stats.stackexchange.com/questions/7386…"
##   .. ..$ : chr "goo.gl/t5pWcg"
##   .. ..$ : chr NA
##   .. ..$ : chr "100.fintech.nl/finexkap"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "heckmanequation.org"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "twitter.com/AmstatNews/sta…"
##   .. ..$ : chr NA
##   .. ..$ : chr "vox.com/2016/8/4/12376…"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "youtu.be/qGUYGcGSWao"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "assessingpsyche.wordpress.com/2016/10/26/a-r…"
##   .. ..$ : chr NA
##   .. ..$ : chr "bit.ly/2f8MEyc"
##   .. ..$ : chr NA
##   .. ..$ : chr "bit.ly/tinderbonfire"
##   .. ..$ : chr "info.extensionengine.com/open-edx-for-r…"
##   .. ..$ : chr "twitter.com/Paul_Yuhnovich…"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "wahoofitness.com/tickrx7minute"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "coursera.org/specialization…"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "rit.edu/science/up-stat" "rit.edu/science/datafe…"
##   .. ..$ : chr "twitter.com/i/web/status/8…"
##   .. ..$ : chr "medium.com/@openaq/bih-u-…"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "producthunt.com/posts/textbot"
##   .. ..$ : chr "wired.com/2017/03/biolog…"
##   .. ..$ : chr NA
##   .. ..$ : chr "twitter.com/jamesrbuk/stat…"
##   .. ..$ : chr "twitter.com/i/web/status/8…"
##   .. ..$ : chr "twitter.com/i/web/status/8…"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "ow.ly/AZ6930aJyBm"
##   .. ..$ : chr "public.tableau.com/profile/nichol…"
##   .. ..$ : chr NA
##   .. ..$ : chr "twitter.com/i/web/status/8…"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "twitter.com/i/web/status/8…"
##   .. ..$ : chr "manchestereveningnews.co.uk/news/greater-m…"
##   .. ..$ : chr NA
##   .. ..$ : chr "instagram.com/p/BToILvNlDQU/"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "twitter.com/meandertail/st…"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "80000hours.org/problem-profil…"
##   .. ..$ : chr "twitter.com/zack_almquist/…"
##   .. ..$ : chr NA
##   .. ..$ : chr "github.com/ropenscilabs/s…"
##   .. ..$ : chr "journals.plos.org/plosone/articl…"
##   .. .. [list output truncated]
##   ..$ urls_t.co              :List of 4421
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/Sw1oPYhj"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/ShQ2HgofoG"
##   .. ..$ : chr "http://t.co/3UOeAYCOug"
##   .. ..$ : chr "http://t.co/xZR2cKtB7s"
##   .. ..$ : chr "http://t.co/uJtGyKJSBX"
##   .. ..$ : chr "http://t.co/y1RZaV7DL1"
##   .. ..$ : chr "http://t.co/LZE8GeswZT"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/Q6rhUYWaEz"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/cLZQPE2E9w"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/hD6nXmPKuP"
##   .. ..$ : chr "http://t.co/QwguefTRpO"
##   .. ..$ : chr "https://t.co/RNbH56sg45"
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/lksq19xXzp"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/Gf0UYHlU5m"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/CMPglzyyTs"
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/3xeKbZSNBJ"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/hrRud8FIE4"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/eXbplyb9nw"
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/8NTjxvG66i"
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/FOKXdMgZlg"
##   .. ..$ : chr "https://t.co/PJeVFdCeeC"
##   .. ..$ : chr "https://t.co/XuRFdHoKIG"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/20enDa8vyA"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/OILplhC0jU"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "https://t.co/GzrzvuCPfn" "https://t.co/zw8ZQTFam3"
##   .. ..$ : chr "https://t.co/aACRq6ZzTg"
##   .. ..$ : chr "https://t.co/WbqW2Xg4s8"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/yHGd5u93W0"
##   .. ..$ : chr "https://t.co/7s0fcbpBS1"
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/auubS14nC1"
##   .. ..$ : chr "https://t.co/jTWp17RWVa"
##   .. ..$ : chr "https://t.co/P9S1TyYRNc"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/7td8FbUneC"
##   .. ..$ : chr "https://t.co/DqnT53BrbB"
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/3yjK72XnyE"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/ILNGdgMfAt"
##   .. ..$ : chr "https://t.co/1inZH0aXv6"
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/GznGeVjTHy"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/akQ9qPhhQS"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/hN0U0z3MKn"
##   .. ..$ : chr "https://t.co/wKnsjBGESd"
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/8mr9rKX2Yk"
##   .. ..$ : chr "https://t.co/hESWVg4xQI"
##   .. .. [list output truncated]
##   ..$ urls_expanded_url      :List of 4421
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://www.emacswiki.org/emacs/TwitteringMode"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://bl0ggy.bl0ggy.in/kristine"
##   .. ..$ : chr "http://on.mtv.com/14ioXbr"
##   .. ..$ : chr "http://fw.to/yF0gyMD"
##   .. ..$ : chr "http://politiken.dk/debat/kroniken/ECE2249036/da-jeg-fik-en-tumor-paa-stoerrelse-med-en-mandarin-i-hjernen/"
##   .. ..$ : chr "http://goo.gl/4acWE5"
##   .. ..$ : chr "http://rnkpr.com/a6b4c2y"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://shar.es/1Xbfx3"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://www.computerworld.com/article/2486425/business-intelligence-4-data-wrangling-tasks-in-r-for-advanced-beginners.html"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://embank.tk?t.co=@chadewalker72"
##   .. ..$ : chr "http://stats.stackexchange.com/questions/73869/suppression-effect-in-regression-definition-and-visual-explanati"| __truncated__
##   .. ..$ : chr "http://goo.gl/t5pWcg"
##   .. ..$ : chr NA
##   .. ..$ : chr "http://100.fintech.nl/finexkap"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://heckmanequation.org"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/AmstatNews/status/750793972973309952"
##   .. ..$ : chr NA
##   .. ..$ : chr "http://www.vox.com/2016/8/4/12376522/political-idealism-enemy?utm_campaign=vox&utm_content=article%3Abottom&utm"| __truncated__
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://youtu.be/qGUYGcGSWao"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://assessingpsyche.wordpress.com/2016/10/26/a-review-of-the-receptive-expressive-social-communication-asse"| __truncated__
##   .. ..$ : chr NA
##   .. ..$ : chr "http://bit.ly/2f8MEyc"
##   .. ..$ : chr NA
##   .. ..$ : chr "http://bit.ly/tinderbonfire"
##   .. ..$ : chr "http://info.extensionengine.com/open-edx-for-revenue-generating-online-education"
##   .. ..$ : chr "https://twitter.com/Paul_Yuhnovich/status/751034791882006528"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://www.wahoofitness.com/tickrx7minute"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://coursera.org/specializations/ruby-on-rails"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "https://www.rit.edu/science/up-stat" "https://www.rit.edu/science/datafest/"
##   .. ..$ : chr "https://twitter.com/i/web/status/838702836238151681"
##   .. ..$ : chr "https://medium.com/@openaq/bih-u-svjetskom-vrhu-zemalja-opasno-ugro%C5%BEenih-zaga%C4%91enjem-zraka-vrijeme-je-"| __truncated__
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://www.producthunt.com/posts/textbot"
##   .. ..$ : chr "https://www.wired.com/2017/03/biologists-teaching-code-survive/?mbid=social_twitter_onsiteshare"
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/jamesrbuk/status/844157483056881664"
##   .. ..$ : chr "https://twitter.com/i/web/status/845843186849263616"
##   .. ..$ : chr "https://twitter.com/i/web/status/845847192581505025"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://ow.ly/AZ6930aJyBm"
##   .. ..$ : chr "https://public.tableau.com/profile/nicholas.denaro#!/vizhome/Week15-OilandGold/Dashboard1"
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/i/web/status/855298673634299904"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/i/web/status/856944427683762176"
##   .. ..$ : chr "http://www.manchestereveningnews.co.uk/news/greater-manchester-news/christie-touched-lives-now-need-12956060"
##   .. ..$ : chr NA
##   .. ..$ : chr "https://www.instagram.com/p/BToILvNlDQU/"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/meandertail/status/865696426046738432"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://80000hours.org/problem-profiles/positively-shaping-artificial-intelligence/"
##   .. ..$ : chr "https://twitter.com/zack_almquist/status/864322895220056065"
##   .. ..$ : chr NA
##   .. ..$ : chr "https://github.com/ropenscilabs/skimr"
##   .. ..$ : chr "http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0085047"
##   .. .. [list output truncated]
##   ..$ media_url              :List of 4421
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/BwVHXDMIMAA73Iw.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/CIqN_yzUMAARGF9.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/CcN2K65UkAEyUGL.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/CiOlw8cUUAAnzHG.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/tweet_video_thumb/Csff5d9VIAEJMBp.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/tweet_video_thumb/C2aUEsHXcAAu4d4.jpg"
##   .. ..$ : chr "http://pbs.twimg.com/media/C3VPem7W8AA5RUq.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/C5XAov8WcAEi9Dt.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/C8BfI4CVAAA4bk6.jpg"
##   .. ..$ : chr "http://pbs.twimg.com/media/C8FI8JUW0AQrrxG.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/C9pjMfMUIAA-6xs.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/DAy2sqgVoAE0vvT.jpg"
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ media_t.co             :List of 4421
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/wu1nkYoLvV"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/QRySTkxYR3"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/mXF4XapXkX"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/XPEzwcX4FA"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/r5B5uoADAk"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/KiaUs1XTHm"
##   .. ..$ : chr "https://t.co/QrJLhkSINk"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/DcsT1s9p7k"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/RkV6PkwXaD"
##   .. ..$ : chr "https://t.co/zkflnFWajq"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/HOT1J2GIfO"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/g739bXD2aZ"
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ media_expanded_url     :List of 4421
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/swimcoach_larry/status/505889004496379904/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/MisterVonline/status/615460496053960704/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/nicmarsh101/status/703535931119308800/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/TaoYANLogos/status/730609870357962753/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/silentmoviegifs/status/776836094272737281/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/Manu_Corleone/status/821506861300088833/photo/1"
##   .. ..$ : chr "https://twitter.com/kingcook1986/status/825653495575502849/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/BloomsburyBooks/status/834785171362684929/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/mcuban/status/846781342083923969/photo/1"
##   .. ..$ : chr "https://twitter.com/BelgiqueMDE/status/847038445381996544/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/ncd8712/status/854104215521824770/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/_inundata/status/868269709996707840/photo/1"
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ media_type             :List of 4421
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "photo"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "photo"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "photo"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "photo"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "photo"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "photo"
##   .. ..$ : chr "photo"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "photo"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "photo"
##   .. ..$ : chr "photo"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "photo"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "photo"
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ ext_media_url          :List of 4421
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/BwVHXDMIMAA73Iw.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/CIqN_yzUMAARGF9.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/CcN2K65UkAEyUGL.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:4] "http://pbs.twimg.com/media/CiOlw8cUUAAnzHG.jpg" "http://pbs.twimg.com/media/CiOlwvPUUAArQzg.jpg" "http://pbs.twimg.com/media/CiOlzFhUUAATShq.jpg" "http://pbs.twimg.com/media/CiOlzFiU4AA3SvM.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/tweet_video_thumb/Csff5d9VIAEJMBp.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/tweet_video_thumb/C2aUEsHXcAAu4d4.jpg"
##   .. ..$ : chr "http://pbs.twimg.com/media/C3VPem7W8AA5RUq.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/C5XAov8WcAEi9Dt.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/C8BfI4CVAAA4bk6.jpg"
##   .. ..$ : chr "http://pbs.twimg.com/media/C8FI8JUW0AQrrxG.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/C9pjMfMUIAA-6xs.jpg"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://pbs.twimg.com/media/DAy2sqgVoAE0vvT.jpg"
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ ext_media_t.co         :List of 4421
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/wu1nkYoLvV"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "http://t.co/QRySTkxYR3"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/mXF4XapXkX"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:4] "https://t.co/XPEzwcX4FA" "https://t.co/XPEzwcX4FA" "https://t.co/XPEzwcX4FA" "https://t.co/XPEzwcX4FA"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/r5B5uoADAk"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/KiaUs1XTHm"
##   .. ..$ : chr "https://t.co/QrJLhkSINk"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/DcsT1s9p7k"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/RkV6PkwXaD"
##   .. ..$ : chr "https://t.co/zkflnFWajq"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/HOT1J2GIfO"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://t.co/g739bXD2aZ"
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ ext_media_expanded_url :List of 4421
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/swimcoach_larry/status/505889004496379904/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/MisterVonline/status/615460496053960704/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/nicmarsh101/status/703535931119308800/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:4] "https://twitter.com/TaoYANLogos/status/730609870357962753/photo/1" "https://twitter.com/TaoYANLogos/status/730609870357962753/photo/1" "https://twitter.com/TaoYANLogos/status/730609870357962753/photo/1" "https://twitter.com/TaoYANLogos/status/730609870357962753/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/silentmoviegifs/status/776836094272737281/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/Manu_Corleone/status/821506861300088833/photo/1"
##   .. ..$ : chr "https://twitter.com/kingcook1986/status/825653495575502849/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/BloomsburyBooks/status/834785171362684929/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/mcuban/status/846781342083923969/photo/1"
##   .. ..$ : chr "https://twitter.com/BelgiqueMDE/status/847038445381996544/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/ncd8712/status/854104215521824770/photo/1"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "https://twitter.com/_inundata/status/868269709996707840/photo/1"
##   .. ..$ : chr NA
##   .. .. [list output truncated]
##   ..$ ext_media_type         : chr [1:4421] NA NA NA NA ...
##   ..$ mentions_user_id       :List of 4421
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "45292558"
##   .. ..$ : chr NA
##   .. ..$ : chr "164194146"
##   .. ..$ : chr "16095150"
##   .. ..$ : chr "18318677"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "2367911" "18159470"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:4] "24251248" "119728086" "62490772" "119728086"
##   .. ..$ : chr "2150919206"
##   .. ..$ : chr "15445811"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "16399949"
##   .. ..$ : chr "14116807"
##   .. ..$ : chr "339003677"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "1891806212"
##   .. ..$ : chr [1:2] "25069929" "216430965"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "3462072440"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:3] "305244640" "845992842" "2920995179"
##   .. ..$ : chr [1:2] "2646262723" "136290059"
##   .. ..$ : chr "102095809"
##   .. ..$ : chr "115754120"
##   .. ..$ : chr NA
##   .. ..$ : chr "15601251"
##   .. ..$ : chr "493127463"
##   .. ..$ : chr "286622708"
##   .. ..$ : chr [1:2] "43878033" "49413866"
##   .. ..$ : chr "4104122234"
##   .. ..$ : chr "160182741"
##   .. ..$ : chr "2347049341"
##   .. ..$ : chr "869884326"
##   .. ..$ : chr "168658290"
##   .. ..$ : chr NA
##   .. ..$ : chr "847112444"
##   .. ..$ : chr [1:2] "2707179805" "2157479071"
##   .. ..$ : chr "2993751197"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "102322045" "14273050"
##   .. ..$ : chr "3405997451"
##   .. ..$ : chr "5520952"
##   .. ..$ : chr NA
##   .. ..$ : chr "48246564"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:3] "294729093" "239352928" "1545976987"
##   .. ..$ : chr [1:2] "743432061088899073" "1682801258"
##   .. ..$ : chr "860173029384564737"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "5685812" "245217900"
##   .. ..$ : chr "725757833178914817"
##   .. ..$ : chr "499153417"
##   .. ..$ : chr NA
##   .. ..$ : chr "18804364"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:3] "69133574" "144529492" "2841558748"
##   .. ..$ : chr [1:3] "159846289" "804027517506093057" "770490229769789440"
##   .. ..$ : chr "2208027565"
##   .. ..$ : chr "1344951"
##   .. ..$ : chr "40578249"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "16228398"
##   .. ..$ : chr NA
##   .. ..$ : chr "54300379"
##   .. ..$ : chr "11348282"
##   .. ..$ : chr "2864661851"
##   .. ..$ : chr NA
##   .. ..$ : chr "26096131"
##   .. ..$ : chr NA
##   .. ..$ : chr "341413775"
##   .. ..$ : chr "19697415"
##   .. ..$ : chr "16186995"
##   .. ..$ : chr NA
##   .. ..$ : chr "109989715"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "90721862" "74725264"
##   .. ..$ : chr "296798997"
##   .. ..$ : chr NA
##   .. ..$ : chr "37495434"
##   .. ..$ : chr NA
##   .. ..$ : chr "18839785"
##   .. ..$ : chr "110688280"
##   .. ..$ : chr "1282121312"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "4861027519" "52267508"
##   .. ..$ : chr [1:2] "267256091" "19520842"
##   .. ..$ : chr [1:2] "69133574" "222618390"
##   .. .. [list output truncated]
##   ..$ mentions_screen_name   :List of 4421
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "hrishigads"
##   .. ..$ : chr NA
##   .. ..$ : chr "quant_strat"
##   .. ..$ : chr "visarz"
##   .. ..$ : chr "bigdata"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "MTV" "macklemore"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:4] "AndersBreinholt" "NielsFrid" "Geocomedy" "NielsFrid"
##   .. ..$ : chr "maghrenov"
##   .. ..$ : chr "Runkeeper"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "felixsalmon"
##   .. ..$ : chr "ShareThis"
##   .. ..$ : chr "FrontierMarkets"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "AcademicsSay"
##   .. ..$ : chr [1:2] "MisterVonline" "Caspar_Lee"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "PET_SMlLES"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:3] "Leaveran" "Finexkap" "FinTechNL"
##   .. ..$ : chr [1:2] "kamarshall14" "Salomon_SA"
##   .. ..$ : chr "AdaColau"
##   .. ..$ : chr "heckmanequation"
##   .. ..$ : chr NA
##   .. ..$ : chr "nickvujicic"
##   .. ..$ : chr "carras16"
##   .. ..$ : chr "PITFAR"
##   .. ..$ : chr [1:2] "jburnmurdoch" "randal_olson"
##   .. ..$ : chr "JdelpilarPhD"
##   .. ..$ : chr "tigrillodelsur"
##   .. ..$ : chr "voxdotcom"
##   .. ..$ : chr "CloseTheGapInt"
##   .. ..$ : chr "UHCougarFB"
##   .. ..$ : chr NA
##   .. ..$ : chr "windsorhm"
##   .. ..$ : chr [1:2] "vijayanpinarayi" "drthomasisaac"
##   .. ..$ : chr "silentmoviegifs"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "jbschnittstelle" "NZZ"
##   .. ..$ : chr "mchi_mcgill"
##   .. ..$ : chr "paulocoelho"
##   .. ..$ : chr NA
##   .. ..$ : chr "ExtensionEngine"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:3] "ISGLOBALorg" "Patipatosa" "ISGlobal_Rad"
##   .. ..$ : chr [1:2] "Qofficiel" "ericetquentin"
##   .. ..$ : chr "Manu_Corleone"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "hrbrmstr" "timelyportfolio"
##   .. ..$ : chr "randombox_es"
##   .. ..$ : chr "StineNielsenEPI"
##   .. ..$ : chr NA
##   .. ..$ : chr "BloomsburyBooks"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr [1:3] "hadleywickham" "kyle_e_walker" "hannah_recht"
##   .. ..$ : chr [1:3] "pacocuak" "RLadiesAmes" "RLadiesGlobal"
##   .. ..$ : chr "ProductHunt"
##   .. ..$ : chr "WIRED"
##   .. ..$ : chr "Cryptoterra"
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr NA
##   .. ..$ : chr "mcuban"
##   .. ..$ : chr NA
##   .. ..$ : chr "juliathibaud"
##   .. ..$ : chr "NASA"
##   .. ..$ : chr "ExpectingMamas"
##   .. ..$ : chr NA
##   .. ..$ : chr "COSportsNut"
##   .. ..$ : chr NA
##   .. ..$ : chr "MacarenaEstevez"
##   .. ..$ : chr "billmaher"
##   .. ..$ : chr "kickstarter"
##   .. ..$ : chr NA
##   .. ..$ : chr "metinfeyzioglu"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "ColumbiaLaw" "ColumbiaClimate"
##   .. ..$ : chr "fukusima88"
##   .. ..$ : chr NA
##   .. ..$ : chr "mrcroissant"
##   .. ..$ : chr NA
##   .. ..$ : chr "narendramodi"
##   .. ..$ : chr "MatterOfStats"
##   .. ..$ : chr "waitbutwhy"
##   .. ..$ : chr NA
##   .. ..$ : chr [1:2] "nousegonsevoo" "Chef_Paulo"
##   .. ..$ : chr [1:2] "_inundata" "AmeliaMN"
##   .. ..$ : chr [1:2] "hadleywickham" "benmschmidt"
##   .. .. [list output truncated]
##   ..$ lang                   : chr [1:4421] "en" "en" "en" "en" ...
##   ..$ quoted_status_id       : chr [1:4421] NA NA NA NA ...
##   ..$ quoted_text            : chr [1:4421] NA NA NA NA ...
##   ..$ quoted_created_at      : POSIXct[1:4421], format: NA ...
##   ..$ quoted_source          : chr [1:4421] NA NA NA NA ...
##   ..$ quoted_favorite_count  : int [1:4421] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ quoted_retweet_count   : int [1:4421] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ quoted_user_id         : chr [1:4421] NA NA NA NA ...
##   ..$ quoted_screen_name     : chr [1:4421] NA NA NA NA ...
##   ..$ quoted_name            : chr [1:4421] NA NA NA NA ...
##   ..$ quoted_followers_count : int [1:4421] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ quoted_friends_count   : int [1:4421] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ quoted_statuses_count  : int [1:4421] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ quoted_location        : chr [1:4421] NA NA NA NA ...
##   ..$ quoted_description     : chr [1:4421] NA NA NA NA ...
##   ..$ quoted_verified        : logi [1:4421] NA NA NA NA NA NA ...
##   ..$ retweet_status_id      : chr [1:4421] NA NA NA NA ...
##   ..$ retweet_text           : chr [1:4421] NA NA NA NA ...
##   ..$ retweet_created_at     : POSIXct[1:4421], format: NA ...
##   ..$ retweet_source         : chr [1:4421] NA NA NA NA ...
##   ..$ retweet_favorite_count : int [1:4421] NA NA NA NA NA 16 4 NA NA 25 ...
##   ..$ retweet_retweet_count  : int [1:4421] NA NA NA NA NA 2 1 NA NA 35 ...
##   ..$ retweet_user_id        : chr [1:4421] NA NA NA NA ...
##   ..$ retweet_screen_name    : chr [1:4421] NA NA NA NA ...
##   ..$ retweet_name           : chr [1:4421] NA NA NA NA ...
##   ..$ retweet_followers_count: int [1:4421] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ retweet_friends_count  : int [1:4421] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ retweet_statuses_count : int [1:4421] NA NA NA NA NA NA NA NA NA NA ...
##   ..$ retweet_location       : chr [1:4421] NA NA NA NA ...
##   ..$ retweet_description    : chr [1:4421] NA NA NA NA ...
##   ..$ retweet_verified       : logi [1:4421] NA NA NA NA NA NA ...
##   ..$ place_url              : chr [1:4421] NA NA NA NA ...
##   ..$ place_name             : chr [1:4421] NA NA NA NA ...
##   ..$ place_full_name        : chr [1:4421] NA NA NA NA ...
##   ..$ place_type             : chr [1:4421] NA NA NA NA ...
##   ..$ country                : chr [1:4421] NA NA NA NA ...
##   ..$ country_code           : chr [1:4421] NA NA NA NA ...
##   ..$ geo_coords             :List of 4421
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. .. [list output truncated]
##   ..$ coords_coords          :List of 4421
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. ..$ : num [1:2] NA NA
##   .. .. [list output truncated]
##   ..$ bbox_coords            :List of 4421
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] -93.7 -93.6 -93.6 -93.7 42 ...
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. ..$ : num [1:8] NA NA NA NA NA NA NA NA
##   .. .. [list output truncated]
```

## See Also

- Simply Measured's [guide to measuring influence on Twitter](https://simplymeasured.com/blog/7-ways-to-measure-influence-on-twitter/)
