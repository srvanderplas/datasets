library(readr)
legosets <- read_csv("https://cdn.rebrickable.com/media/downloads/sets.csv.gz")
write_csv(legosets, "clean/lego_sets.csv")

# mirror site
dir.create("html/rebrickable")
system("wget -r -e robots=off -l 1 -k -c -H --domains='cdn.rebrickable.com' -P html/rebrickable https://rebrickable.com/downloads/")
