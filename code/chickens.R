library(rvest)
url <- "https://www.cacklehatchery.com/chicken-breeds/"
breeds <- read_html(url) |>
  html_table()
breeds <- breeds[[1]]

breeds$link <- read_html(url) %>%
  html_nodes("tr a") %>%
  html_attr("href") %>%
  paste0("https://www.cacklehatchery.com", .)

download.file(url, "raw/chickens/breeds-table.html")

library(dplyr)
library(stringr)
breeds <- breeds %>%
  mutate(name = str_replace_all(`Chicken Breed Name`, c("[[:punct:]]" = "", " " = "-", "[^A-z-]"=""))) %>%
  mutate(outfile = paste0("raw/chickens/", name, ".html"))


purrr::walk2(breeds$link, breeds$outfile, ~read_html(.x) %>% xml2::write_html(.y))
html <- read_html(url)

download.file(breeds$link, destfile = paste0("raw/chickens/", breeds$name, ".html"))
