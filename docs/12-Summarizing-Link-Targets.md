# Summarizing Link Targets 

## Problem

You want to summarize the text of a web page that’s indicated by a short URL in a tweet.

## Solution

Extract the text from the web page, and then use a natural language processing (NLP) toolkit to help you extract the most important sentences to create a machine-generated abstract.

## Discussion

R has more than a few NLP tools to work with. We'll work with the `LSAfun` package for this exercise. As the acronym-laden package name implies, it uses  Latent Semantic Analysis (LSA) to determine the most important bits in a set of text.

We'll use tweets by data journalist extraordinaire [Matt Stiles](https://twitter.com/stiles). Matt works for the Los Angeles Times and I learn a _ton_ from him on a daily basis. He's on top of _everything_. Let's summarise some news he shared recently from the New York Times, Reuters, Washington Post, Five Thirty-Eight and his employer. 

We'll limit our exploration to the first three new links we find.


```r
library(rtweet)
library(LSAfun)
library(jerichojars) # hrbrmstr/jerichojars
library(jericho) # hrbrmstr/jericho
library(tidyverse)
```

```r
stiles <- get_timeline("stiles")

filter(stiles, str_detect(urls_expanded_url, "nyti|reut|wapo|lat\\.ms|53ei")) %>%  # only get tweets with news links
  pull(urls_expanded_url) %>% # extract the links
  flatten_chr() %>% # mush them into a nice character vector
  head(3) %>% # get the first 3
  map_chr(~{
    httr::GET(.x) %>% # get the URL (I'm lazily calling "fair use" here vs check robots.txt since I'm suggesting you do this for your benefit vs profit)
      httr::content(as="text") %>%  # extract the HTML
      jericho::html_to_text() %>% # strip away extraneous HTML tags
      LSAfun::genericSummary(k=3) %>% # summarise!
      paste0(collapse="\n\n") # easier to see
  }) %>%
  walk(cat)
```

```
##  says North Korea's ICBM launch is 'a new escalation of the threat to the United States' and the world As the world focuses on its nuclear ambitions, North Korea deploys another weapon: Drones North Korea is building mysterious artificial islands that would be perfect for missile launches Advertisement Be the first to comment Hide Comments Please enable JavaScript to view the comments powered by SolidOpinion
## 
## com Travel Offers About Press Releases Staff Directory Giving Search xml:space="preserve"> Local Politics Sports Entertainment Opinion Place an ad Advertisement Asia When this broadcaster makes a rare appearance, North Koreans know it's serious By Matt Stiles Jul 05, 2017 | 9:55 AM | Seoul When Ri Chun Hee appears on North Korea’s state-run news network, the audience knows the looming declaration is serious
## 
##  says North Korea's ICBM launch is 'a new escalation of the threat to the United States' and the world As the world focuses on its nuclear ambitions, North Korea deploys another weapon: Drones North Korea is building mysterious artificial islands that would be perfect for missile launches Advertisement Be the first to comment Hide Comments Please enable JavaScript to view the comments powered by SolidOpinion<!–– 0000000 000 0000000 111111111 11111111100 000 111111111 00000 111111111111111111 00000 000000 000 1111111111111111111111111100000 000 000 1111 1111111111111111100 000 000 11 0 1111111100 000 000 1 00 1 000 000 00 00 1 000 000 000 00000 1 000 00000 0000 00000000 1 00000 11111 000 00 000000 000 11111 00000 0000 000000 00000 00000 000 10000 000000 000 0000 000 00000 000000 1 000 000 000000 10000 1 0 000 000 1000000 00 1 00 000 000 1111111 1 0000 000 000 1111111100 000000 000 0000 111111111111111110000000 0000 111111111 111111111111100000 111111111 0000000 00000000 0000000 NYTimes
## 
## com/Tech --> New Revelations Suggest a President Losing Control of His Narrative - The New York Times Sections SEARCH Skip to contentSkip to site index Politics Subscribe Log In SubscribeLog In Advertisement Supported by News Analysis New Revelations Suggest a President Losing Control of His Narrative Image President Trump is used to dictating the terms of his own life to create a narrative that suits his desired image
## 
##  politics politics New York business tech science sports obituaries today's paper corrections corrections opinion today's opinion today's opinion op-ed columnists editorials editorials contributing writers op-ed Contributors letters letters sunday review sunday review taking note video: opinion arts today's arts art & design books dance movies music television theater video: arts living automobiles automobiles crossword food food education fashion & style health jobs magazine real estate t magazine travel weddings listings & more tools & services N By Jane Mayer May 07, 2018 Listen to the New Yorker Radio Hour Buy the Cover Play the Jigsaw Puzzle News & Politics Daily Comment Our Columnists News Desk Culture Cultural Comment Culture Desk Goings On About Town The Critics Jia Tolentino Persons of Interest Business, Science & Tech Currency Elements Maria Konnikova Humor Daily Shouts Shouts & Murmurs The Borowitz Report Cartoons Daily Cartoon Cartoon Caption Contest Cartoon Bank Books & Fiction Page-Turner Books Literary Lives Poems Fiction Magazine This Week's Issue Archive Subscribe Photography Photo Booth Portfolio Video Culture Humor Politics Business Science & Tech Books Sports Podcasts The New Yorker Radio Hour Political Scene The Writer's Voice Fiction Poetry Out Loud More Customer Care Buy the Cover Apps Jigsaw Puzzle SecureDrop Store RSS Site Map Newsletters The Daily Culture Review Podcasts Cartoons John Cassidy The Borowitz Report Fiction Goings On About Town About Us About Careers Contact FAQ Media Kit Press Accessibility Help Sections News & Politics Culture Business, Science & Tech Humor Cartoons Books & Fiction Magazine Photography Video Podcasts More Newsletters About Careers Contact FAQ Media Kit Press Accessibility Help Follow Us © 2018 Condé Nast
## 
##  By Jane Mayer May 07, 2018 Listen to the New Yorker Radio Hour Buy the Cover Play the Jigsaw Puzzle News & Politics Daily Comment Our Columnists News Desk Culture Cultural Comment Culture Desk Goings On About Town The Critics Jia Tolentino Persons of Interest Business, Science & Tech Currency Elements Maria Konnikova Humor Daily Shouts Shouts & Murmurs The Borowitz Report Cartoons Daily Cartoon Cartoon Caption Contest Cartoon Bank Books & Fiction Page-Turner Books Literary Lives Poems Fiction Magazine This Week's Issue Archive Subscribe Photography Photo Booth Portfolio Video Culture Humor Politics Business Science & Tech Books Sports Podcasts The New Yorker Radio Hour Political Scene The Writer's Voice Fiction Poetry Out Loud More Customer Care Buy the Cover Apps Jigsaw Puzzle SecureDrop Store RSS Site Map Newsletters The Daily Culture Review Podcasts Cartoons John Cassidy The Borowitz Report Fiction Goings On About Town About Us About Careers Contact FAQ Media Kit Press Accessibility Help Sections News & Politics Culture Business, Science & Tech Humor Cartoons Books & Fiction Magazine Photography Video Podcasts More Newsletters About Careers Contact FAQ Media Kit Press Accessibility Help Follow Us © 2018 Condé Nast
## 
##  It has become commonplace to say that enough was known about Trump’s shady business before he was elected; his followers voted for him precisely because they liked that he was someone willing to do whatever it takes to succeed, and they also believe that all rich businesspeople have to do shady things from time to time
```

## See Also

As noted, there are other NLP packages. Check out the [CRAN Task View](https://cran.r-project.org/web/views/NaturalLanguageProcessing.html) on NLP for more resources.
