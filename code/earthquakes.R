# Source: https://earthquake.usgs.gov/earthquakes/map/?starttime%22:%222000-01-01%2000:00:00%22,%22endtime%22:%222023-01-01%2000:00:00%22,%22minmagnitude%22:6,%22orderby%22:%22time%22%7D%7D

library(httr)
library(readr)
library(magrittr)

url <- "https://earthquake.usgs.gov/fdsnws/event/1/query?format=text&starttime=2000-01-01&endtime=2023-01-01&minmagnitude=6"

res <- GET(url)
content(res, as = "parsed") %>%
  read_delim(delim = "|") %>%
  write_csv("raw/earthquakes2000.csv")
