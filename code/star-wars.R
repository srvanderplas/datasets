library(readr)
data(starwars)
write_csv(starwars[,1:11], "clean/starwars.csv")
