library(rvest)
library(xml2)

url <- "https://www.cacklehatchery.com/chicken-breeds/"


excludefolders <- paste(paste0("/", c("blog", "cart", "breeding-farms", "catalog-request", "product-category", "chick-care-instructions", "chicken-name-generator", "contact", "faqs", "feed", "guarantees-policies", "helpful-links", "my-account", "orders-and-returns", "poultry-breed-finder-index", "raising-pet-chickens-for-your-backyard", "search-terms", "vaccination-policy", "wholesale-inquiry")), collapse = ",")

system(sprintf("wget -r -e robots=off -l 1 -k -c -H -X %s --domains='cacklehatchery.com' -P html/chickens https://www.cacklehatchery.com/chicken-breeds/", excludefolders))

# Keep breed information and combine into a separate XML file


urls <- list.files("html/chickens/www.cacklehatchery.com/product", ".html", recursive = T, full.names = T)


library(purrr)
library(dplyr)
library(tidyr)
library(stringr)

file.copy("html/chickens/www.cacklehatchery.com/chicken-breeds/index.html", "raw/chicken-breed-overall.html")


htmlfiles <- map(urls, read_html)

chicken_info <- map(htmlfiles, html_node, ".product")

chicken_info_txt <- map(chicken_info, paste)

chicken_info_txt <- c("<html><body>", chicken_info_txt, "</body></html>")
paste(chicken_info_txt, collapse = "") %>%
  writeLines("raw/chicken-breed-details.html")


tmp <- read_html("raw/chicken-breed-details.html")

chickens <- html_nodes(tmp, "body > .product")

parse_breed <- function(node) {
  name <- node %>% html_node("h1.product_title") %>% html_text()

  breed_facts <- node %>% html_nodes(".breed_facts_tab li") %>% html_nodes("strong")
  breed_facts_titles <- breed_facts %>% html_text()
  breed_facts_values <- breed_facts %>%
    map(xml_parent) %>%
    map_chr(html_text2) %>%
    str_remove(breed_facts_titles) %>%
    str_trim()
  breed_facts_titles <- breed_facts_titles %>% str_trim() %>% str_remove_all("[[:punct:]]")
  breed_facts <- data.frame(t(breed_facts_values)) %>% set_names(breed_facts_titles)

  if (nrow(breed_facts) == 0) breed_facts <- list()


  description <- node %>% html_nodes("#tab-description") %>% html_text() %>% str_trim() %>%
    str_remove("Description\\n\\n")

  parse_availability <- function(tab) {
    dates <- html_nodes(tab, "td:first-of-type") %>% html_text()
    avail <- html_nodes(tab, "td:last-of-type") %>% html_attr("class")
    if (length(dates) == 0) return(list())

    data.frame(date = dates, avail = avail)
  }

  availability <- node %>% html_node("#tab-availability table") %>% parse_availability()

  videos <- node %>% html_node(".video_tab") %>% html_nodes("iframe") %>% html_attr("src")


  parse_reviews <- function(rev) {
    res <- data.frame(
      id = rev %>% html_attr("id") %>% str_remove("li-comment-"),
      rating = rev %>% html_node(".star-rating span strong") %>% html_text(),
      author = rev %>% html_node(".woocommerce-review__author") %>% html_text(),
      date = rev %>% html_node(".woocommerce-review__published-date") %>% html_attr("datetime"),
      title = rev %>% html_node(".description h3") %>% html_text(),
      review = rev %>% html_node(".description p") %>% html_text()
    )

    if (nrow(res) == 0) return(list())

    return(res)
  }

  reviews <- node %>% html_nodes(".comment") %>% map_df(parse_reviews)

  return(list(
    name = name,
    description = description,
    breed_facts = breed_facts,
    availability = availability,
    videos = videos,
    reviews = reviews))
}


chicken_data <- map(chickens, parse_breed)

as_xml_document(list(breeds = chicken_data)) %>% write_xml(file = "raw/chicken-breed-details.xml")
