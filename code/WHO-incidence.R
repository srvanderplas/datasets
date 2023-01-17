# WHO Disease incidence data

# Tidy version: https://whowiise.blob.core.windows.net/upload/incidence-rate--2021.xlsx

# Wider site: https://immunizationdata.who.int/listing.html?topic=&location=

# Raw data saved is from 2020, before site migration and data format changes.

download.file("https://whowiise.blob.core.windows.net/upload/incidence-rate--2021.xlsx", "raw/2021-incidence-rate.xlsx")

library(readxl)
library(tidyr)
library(dplyr)
library(purrr)
library(stringr)
incidence <- read_xlsx("raw/2021-incidence-rate.xlsx")

# Convert to messy format from tidy format (ugh this is weird)

messy_disease <- function(disease, data) {
  tmp <- data %>%
    filter(DISEASE == disease)

  # assume denominator is the same for each disease
  denom <- tmp$DENOMINATOR %>% unique()

  tmp %>% select(-DENOMINATOR) %>%
    pivot_wider(id_cols = c(GROUP:NAME, DISEASE:DISEASE_DESCRIPTION),
                names_from = YEAR, values_from = INCIDENCE_RATE, values_fill = NA)
}

# messy_disease("CRS", incidence)

messy <- incidence %>%
  filter(!is.na(DISEASE)) %>%
  mutate(DENOMINATOR = str_remove_all(DENOMINATOR, ",")) %>%
  mutate(disease = DISEASE, denom = DENOMINATOR) %>% # copy column
  nest(data = -c(disease, denom)) %>%
  mutate(messy = map2(disease, data, messy_disease))

# Need to save this to spreadsheets along with the denominator information....
