## Data Files

| Topic | Source | Repository Links | Attributes |
| ----- | ----- | ----- | ----- |
| Pokemon Stats (Generations 1-9) | [pokemondb.net](https://pokemondb.net/pokedex/all) | [Raw data](raw/pokemon_data_pokemondb.csv) | list columns, images, database merges, string manipulation |
| Pokemon Stats (Generations 1-9) | [Bulbapedia](https://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_National_Pok%C3%A9dex_number) | [Raw data](raw/pokemon_data_bulbapedia.csv) | images, database merges, string manipulation |
| Pokemon Stats (Generations 1-9) | Merged | [Clean data](clean/pokemon_gen_1-9.csv), [Code](code/pokemon.R) | limited to pokemondb rows with generational info added. |
| Lego Sets | [Rebrickable.com](https://cdn.rebrickable.com/media/downloads/sets.csv.gz) | [Clean data](clean/lego-sets.csv), [Code](code/lego-sets.R) | database merges (with other tables), images, time-series |
| Star Wars | `readr` R package | [Data](clean/starwars.csv), [Code](code/star-wars.R) | filtering |
