# Making Robust Twitter Requests

## Problem
You want to write a long-running script that harvests large amounts of data, such as the friend and follower ids for a very popular Twitterer; however, the Twitter API is inherently unreliable and imposes rate limits that require you to always expect the unexpected.

## Solution

Use `rtweet`.

## Discussion

No code examples and not much expository in this chaper (unlike it's Python counterpart). Michael has taken much of the pain away by having the package abstract the rate-limit issues and API wonkiness away from your code.

Having said that, you can work on making these Twitter scripts or other scripts more robust by wrapping potentially troublesome calls in `purrr::safely()`and testing for the `result` before continuing with data operations.

## See Also

- [`purrr::safely()`](http://purrr.tidyverse.org/reference/safely.html)
