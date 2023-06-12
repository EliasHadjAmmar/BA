# Input: Bairoch data, city locations (with names)
# Output: Bairoch data linked to city_ids from Princes and Townspeople.

library(tidyverse) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

Main <- function(){

  # Read data
  staedtebuch <- read_csv("drive/raw/attributes/city_locations.csv", show_col_types = F) |> 
    select(city_id, name, name_alt, name_foreign, nat, region_id)
  
  bairoch_raw <- read_csv("drive/raw/population/bairoch1988.csv", show_col_types = F)
  
  # Get subset of cities that is most likely to be in the data
  bairoch_cities_HRE <- bairoch_raw |> 
    select(country, city) |> 
    distinct() |> 
    filter(country %in% c("Germany", "Austria", "Poland", "Czechoslovakia"))
  
  # Clean the city names so I can match them
  bairoch_clean <- bairoch_cities_HRE |> 
    BatchClean() |> 
    ExactClean()
  
  # Match terr_ids to Bairoch city names ()
  matched_keys <- GetBestMatch(bairoch_clean, staedtebuch)
  
  matched_data <- bairoch_raw |> 
    filter(country %in% c("Germany", "Austria", "Poland", "Czechoslovakia")) |> 
    left_join(matched_keys, by="city") |> 
    drop_na(city_id) |> 
    select(city_id, year, city, population) |> 
    arrange(city_id, year)
  
  # Could not find: Hardenberg, Schmalkalden
  # Multiple candidates: Saarbruecken, Mecklenburg, Frankenberg
  
  write_csv(matched_data, "drive/derived/population.csv")

  return(0)
}


GetBestMatch <- function(bairoch_clean, staedtebuch){
  # Separately matches the city name in Bairoch to the three name columns
  # given in the Städtebuch, then combines them. Ultimate match is `name` if
  # available, then `name_alt` and then `name_foreign`.
  
  joined1 <- bairoch_clean |> 
    mutate(name = city) |> 
    left_join(staedtebuch, by="name") |> 
    drop_na(city_id) |> 
    rename(match1 = name) |> 
    select(city_id, city, match1)
  
  joined2 <- bairoch_clean |> 
    mutate(name_alt = city) |> 
    left_join(staedtebuch, by="name_alt") |> 
    drop_na(city_id)|> 
    rename(match2 = name_alt) |> 
    select(city_id, city, match2)
  
  joined3 <- bairoch_clean |> 
    mutate(name_foreign = city) |> 
    left_join(staedtebuch, by="name_foreign") |> 
    drop_na(city_id) |> 
    rename(match3 = name_foreign) |> 
    select(city_id, city, match3)
  
  joined <- list(joined1, joined2, joined3) |> 
    reduce(\(a, b) full_join(a, b, by = "city_id")) |> 
    mutate(match_staedtebuch = coalesce(match1, match2, match3))
  
  # matched_keys |> filter(city.x != city.y) |> nrow()
  
  joined <- joined |>
    mutate(city = coalesce(city.x, city.y, city)) |> 
    select(city_id, match_staedtebuch, city)
  
  return(joined)
}


BatchClean <- function(bairoch){
  bairoch_clean <- bairoch |> 
    mutate(city = str_replace_all(city, " Am ", " am ")) |>
    mutate(city = str_replace_all(city, " An Der ", " an der ")) |> 
    mutate(city = str_replace_all(city, " Ob Der ", " ob der "))
  return(bairoch_clean)
}


ExactClean <- function(bairoch){
  # Manually recode cities that can't immediately be matched 
  bairoch_clean <- bairoch |> 
    filter(city != "Burg") |>  # not unique
    filter(city != "Harburg") |>  # not unique
    filter(city != "Landau") |> # not unique
    filter(city != "Marienberg") |> # not unique
    mutate(city = str_replace(city, "Karl-Marx-Stadt", "Chemnitz")) |> 
    mutate(city = str_replace(city, "Frankfurt an der Oder", "Frankfurt (Oder)")) |> 
    mutate(city = str_replace(city, "Charlottenburg", "Berlin-Charlottenburg")) |> 
    mutate(city = str_replace(city, "Lauingen", "Lauingen (Donau)")) |> 
    mutate(city = str_replace(city, "Neuburg", "Neuburg a. d. Donau")) |> 
    mutate(city = str_replace(city, "Esslingen", "Esslingen/Neckar")) |> 
    mutate(city = str_replace(city, "Iena", "Jena")) |> 
    mutate(city = str_replace(city, "Muelheim an der Ruhr", "Muelheim a. d. Ruhr")) |> 
    mutate(city = str_replace(city, "Rottenburg ob der Tauber", "Rothenburg o. d. Tauber")) |> 
    mutate(city = str_replace(city, "Rothenburg am Neckar", "Rottenburg am Neckar"))
  return(bairoch_clean)
}

Main()

# Code below helps manually recode unmatched German cities:
# remaining <- bairoch |> 
#   filter(!(city %in% joined$match)) |> 
#   filter(country == "Germany")
# 
# remaining$city
#
# staedtebuch |>
#   filter(grepl("Rottenburg", name))
# 
# staedtebuch |>
#   filter(grepl("Mecklenburg", name_alt))

