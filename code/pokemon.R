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

write_csv(pokemon_data, "raw/pokemon_data_pokemondb.csv")

# mirror site
dir.create("html/pokemon_gen_1-9")
system("wget -r -e robots=off -l 1 -k -c -H --domains='img.pokemondb.net' -P html/pokemon_gen_1-9 https://pokemondb.net/pokedex/all")


# pokemondb doesn't have generation... so bulbapedia.
library(stringr)
library(tidyr)
url <- "https://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_National_Pok%C3%A9dex_number"
html <- read_html(url)

rows2 <- html_nodes(html, "tr")[-c(1,2)]

tables <- html_nodes(html, "table")[-c(1, 11, 12, 13)]

parse_rows2 <- function(row) {
  tibble(
  pokedex_no = html_node(row, "td:first-child") %>% html_text() %>% parse_number(),
  pokedex_link = html_node(row, "td:nth-child(2) a") %>% html_attr("href"),
  img_link = html_node(row, "td a img") %>% html_attr("src"),
  name = html_node(row, "td a[title*=\"(Pokémon)\"]") %>% html_text() %>% str_remove(" (Pokémon)"),
  variant = html_node(row, "td small") %>% html_text(),
  type = html_node(row, "td[style*=\"background\"]") %>% html_text() %>% str_trim(),
  type2 = html_node(row, "td[style*=\"background\"]:last-child") %>% html_text() %>% str_trim()
  )
}

parse_tables <- function(tab, id) {
  tabrows <- html_nodes(tab, "tr")[-1]
  map_dfr(tabrows, parse_rows2) %>%
    mutate(gen = id)
}

pokemon_data2 <- map2_df(tables, 1:length(tables), parse_tables)

write_csv(pokemon_data2, "raw/pokemon_data_bulbapedia.csv")


# Clean up and join the pokemon data together

pokemon_data_clean <- pokemon_data %>%
  mutate(variant = variant %>% str_remove("Forme?") %>% str_remove("Mode") %>%
           str_remove(name) %>% str_trim())

pokemon_data2_adj <- pokemon_data2 %>%
  fill(pokedex_no) %>%
  mutate(variant = str_remove(variant, "Forme?") %>% str_remove("Mode") %>%
           str_remove(name) %>% str_trim()) %>%
  mutate(variant = ifelse(nchar(variant) == 0, NA, variant)) %>%
  mutate(type1 = type,
         type2 = ifelse(type2 == type1, "", type2),
         type = paste(type1, type2, sep = ",") %>% str_remove(",$"))


poke_cluster <- full_join(pokemon_data_clean, pokemon_data2_adj)

poke_mismatch1 <- anti_join(pokemon_data, pokemon_data2_adj)
poke_mismatch2 <- anti_join(pokemon_data2_adj, pokemon_data)


pokemon_data_gen <- left_join(pokemon_data, select(pokemon_data2_adj, pokedex_no, gen)) %>%
  select(gen, everything())
pokemon_data_gen %>%
  mutate(type_1 = str_split_i(type, ",", 1),
         type_2 = str_split_i(type, ",", 2)) %>%
  write_csv("clean/pokemon_gen_1-9.csv")
