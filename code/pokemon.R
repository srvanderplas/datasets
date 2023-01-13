# Source: https://pokemondb.net/pokedex/all

library(rvest)
library(magrittr)
library(dplyr)
library(readr)
library(purrr)

url <- "https://pokemondb.net/pokedex/all"
html <- read_html(url)

rows <- html_nodes(html, "tr")

parse_rows <- function(row) {
  tibble(
    pokedex_no = html_node(row, "td span:last-child") %>% html_text() %>% parse_number(),
    img_link = html_node(row, ".icon-pkmn") %>% html_attr("src"),
    name = html_node(row, ".cell-name a") %>% html_text(),
    variant = html_node(row, ".cell-name small") %>% html_text(),
    type = html_nodes(row, ".cell-icon a") %>% html_text() %>% list(),
    total = html_nodes(row, ".cell-total") %>% html_text() %>% parse_number(),
    hp = html_nodes(row, "td:nth-child(5)") %>% html_text() %>% parse_number(),
    attack = html_nodes(row, "td:nth-child(6)") %>% html_text() %>% parse_number(),
    defense = html_nodes(row, "td:nth-child(7)") %>% html_text() %>% parse_number(),
    sp_attack = html_nodes(row, "td:nth-child(8)") %>% html_text() %>% parse_number(),
    sp_defense = html_nodes(row, "td:nth-child(9)") %>% html_text() %>% parse_number(),
    speed = html_nodes(row, "td:nth-child(10)") %>% html_text() %>% parse_number()
  )
}

pokemon_data <- map_dfr(rows[-1], parse_rows)
# Collapse list-col to get into csv form
pokemon_data <- pokemon_data %>%
  mutate(type = map_chr(type, paste, collapse = ","))
pokemon_data %>%
  write_csv("clean/pokemon_gen_1-9.csv")


# mirror site
dir.create("html/pokemon_gen_1-9")
system("wget -r -e robots=off -l 1 -k -c -H --domains='img.pokemondb.net' -P html/pokemon_gen_1-9 https://pokemondb.net/pokedex/all")
