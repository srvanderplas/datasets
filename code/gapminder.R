if (!"gapminder" %in% installed.packages()) install.packages("gapminder")
library(gapminder)
readr::write_csv(gapminder_unfiltered, file = "raw/gapminder_unfiltered.csv")
