library(rvest)
library(WriteXLS)
library(dplyr)
url <- "https://www.eia.gov/dnav/pet/hist/LeafHandler.ashx?n=pet&s=emm_epm0u_pte_nus_dpg&f=w"

tmp <- url %>%
  read_html() %>%
  html_table()

tmp[[5]] %>%
  magrittr::extract(1:11) %>%
  subset(rowSums(!is.na(.)) > 1) %>%
  WriteXLS(., "raw/gas_prices_updated.xlsx", row.names = F)
