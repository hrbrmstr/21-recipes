# Harvesting Tweets

## Problem

You want to harvest and store tweets from a collection of id values, or harvest entire timelines of tweets.

## Solution

Use `rtweet`'s timeline and status functions.

## Discussion

Recipe 2 showed how to do this with SQLite. Unlike other API's `rtweet` returns a tidy data frame which makes it easy to put data into such rectangular data stores. 

Rather than repeat the example, let's take a quick look at all of the harvesting functions in `rtweet`:

- `get_collections`: Get collections by user or status id.
- `get_favorites`: Get tweets data for statuses favorited by one or more target users.
- `get_followers`: Get user IDs for accounts following target user.
- `get_friends`: Get user IDs of accounts followed by target user(s).
- `get_mentions`:  Get mentions for the authenticating user.
- `get_retweeters`:  Get user IDs of users who retweeted a given status.
- `get_retweets`:  Get the most recent retweets of a specific Twitter status
- `get_timeline`:  Get one or more user timelines (tweets posted by target user(s)).
- `get_timelines`: Get one or more user timelines (tweets posted by target user(s)).

- `lookup_collections`:  Get collections by user or status id.
- `lookup_coords`: Get coordinates of specified location.
- `lookup_friendships`:  Lookup friendship information between two specified users.
- `lookup_statuses`: Get tweets data for given statuses (status IDs).
- `lookup_tweets`: Get tweets data for given statuses (status IDs).
- `lookup_users`:  Get Twitter users data for given users (user IDs or screen names).

- `search_tweets`: Get tweets data on statuses identified via search query.
- `search_tweets2`:  Get tweets data on statuses identified via search query.
- `search_users`:  Get users data on accounts identified via search query.

- `stream_tweets`: Collect a live stream of Twitter data.
- `stream_tweets2`:  Collect a live stream of Twitter data.

One handy method for exporting this rectangular tweet data to a file format virtually any collaborator can use is `rtweet::write_as_csv()` which saves a flattened CSV (no nested column data).

