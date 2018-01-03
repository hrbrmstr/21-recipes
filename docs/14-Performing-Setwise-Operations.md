# Performing Setwise Operations on Friendship Data

## Problem

You want to operate on collections of friends and followers to answer questions such as _“Who isn’t following me back?”_, _“Who are my mutual friends?”_, and _“What friends/followers do certain users have in common?”_.

## Solution

Use R setwise operations amd `rtweet::lookup_friendships()`.

## Discussion

R has [set operations](https://stat.ethz.ch/R-manual/R-devel/library/base/html/sets.html) and they'll do _just fine_ for helping us cook this recipe.

If you need a refresher on set operations, check out this introductory lesson from [Khan Academy](https://www.khanacademy.org/math/statistics-probability/probability-library/basic-set-ops/v/intersection-and-union-of-sets).

<iframe width="363" height="204" src="https://www.youtube.com/embed/jAfNg3ylZAI" frameborder="0" gesture="media" allow="encrypted-media" allowfullscreen></iframe>


```r
library(rtweet)
library(tidyverse)
```

```r
brooke_followers <- rtweet::get_followers("gbwanderson")
brooke_friends <- rtweet::get_friends("gbwanderson")
```

Now we can see the count of mutual and disperate relationships:


```r
# common
length(intersect(brooke_followers$user_id, brooke_friends$user_id))
```

```
## [1] 50
```

```r
# diff
length(setdiff(brooke_followers$user_id, brooke_friends$user_id))
```

```
## [1] 206
```

The Python counterpart to this cookbook suggests [Redis](https://redis.io/topics/data-types-intro) as a "big-ish" data solution for performing set operations at-scale. R has at least 3 packages that provide direct support for Redis, so if you need to perform these operations at-scale, cache the info you retrieve from the Twitter API into Redis and then go crazy!

## See Also

- Google (yes, seriously) `redis packages r` to see the impressive/diverse number of packages linking R to Redis
- [Official Twitter API documentation](https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/overview) on friends and followers.
