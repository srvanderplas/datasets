# Feed the Baby data (Zoey)
# Exported from Feed Baby Android App on 2023-01-23

library(readr)
library(dplyr)
library(lubridate)
library(stringr)

zoey_feeds <- read_csv("raw/zoey-feeds.csv") %>%
  mutate(start = as.POSIXct(`Start Time`, tz = "America/Chicago", format = "%H:%M:%S %m-%d-%Y"),
         end = as.POSIXct(`End Time`, tz = "America/Chicago", format = "%H:%M:%S %m-%d-%Y"))

# Select first month of life
zoey_first_month <- filter(zoey_feeds, start < as.POSIXct("2021-08-07") + days(30)) %>%
  select(id, Start = `Start Time`, End = `End Time`, Type = `Feed Type`, matches("Quantity")) %>%
  mutate(Type = str_replace_all(Type, c("(Left|Right) " = "")))
write_csv(zoey_first_month, "raw/feeds_first_month.csv")
