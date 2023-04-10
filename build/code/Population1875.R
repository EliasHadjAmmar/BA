# Input: cross-section of city populations in 1875.
# Output: 1875 population of cities that are in the Städtebuch data, with city_id.

suppressPackageStartupMessages(library(tidyverse))

setwd("~/GitHub/BA")

Main <- function(){
  staedtebuch <- read_csv("build/input/city_locations.csv", show_col_types = F)
  cities1875 <- read_csv("build/input/destatis1881.csv", show_col_types = F)
  
  cities1875 <- UnifyNames(cities1875)
  
  
  cities_joined <- cities1875 |> 
    left_join(staedtebuch, by="name") |> 
    drop_na(city_id) |> 
    select(city_id, name, pop1875)
  
  write_csv(cities_joined, "build/temp/cities1875.csv")
}


UnifyNames <- function(cities1875){
  cities1875 |> 
    rename(name = city) |> 
    mutate(name = str_replace_all(name, "ü", "ue")) |>
    mutate(name = str_replace_all(name, "ä", "ae")) |>
    mutate(name = str_replace_all(name, "ö", "oe")) |> 
    mutate(name = str_replace(name, "Koenigsberg i. Pr.", "Koenigsberg Pr.")) |> 
    mutate(name = str_replace(name, "Frankfurt a. M.", "Frankfurt")) |> 
    mutate(name = str_replace(name, "Frankfurt a. O.", "Frankfurt (Oder)")) |> 
    mutate(name = str_replace(name, "Crefeld", "Krefeld")) |> 
    mutate(name = str_replace(name, "Halle a. S.", "Halle a. d. S.")) |> 
    mutate(name = str_replace(name, "Muenchen-Gladbach", "Moenchen Gladbach")) |> 
    mutate(name = str_replace(name, "Freiburg i. Bad.", "Freiburg/Br.")) |> 
    mutate(name = str_replace(name, "Brandenburg a. H.", "Brandenburg")) |> 
    mutate(name = str_replace(name, "Spandau", "Berlin-Spandau")) |> 
    mutate(name = str_replace(name, "Charlottenburg", "Berlin-Charlottenburg")) |> 
    mutate(name = str_replace(name, "Hagen i. W.", "Hagen")) |> 
    mutate(name = str_replace(name, "Kottbus", "Cottbus")) |> 
    mutate(name = str_replace(name, "Landsberg a. W.", "Landsberg (Warthe)")) |> 
    mutate(name = str_replace(name, "Muehlhausen i. Th.", "Muehlhausen i. Thuer.")) |> 
    mutate(name = str_replace(name, "Stargard a. d. I.", "Stargard in Pommern")) |> 
    mutate(name = str_replace(name, "Elberfeld", "Wuppertal-Elberfeld")) |> 
    mutate(name = str_replace(name, "Barmen", "Wuppertal-Barmen"))
}

# I manually checked and name-corrected cities that weren't immediately joined to an id
# remaining <- base::setdiff(cities1875$name, cities_joined$name)

# staedtebuch |>
#   filter(grepl("Colmar", name))
# 
# staedtebuch |>
#   filter(grepl("Colmar", name_alt))

# Double-check:
# remaining |> 
#   enframe(name=NULL, value="name_alt") |> 
#   left_join(staedtebuch, by ="name_alt")
# should be all NAs

Main()

