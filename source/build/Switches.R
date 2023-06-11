# Input: yearly territorial histories of cities.
# Output: same, but with dummies for switching years, conquests, and successions.

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(haven))

setwd("~/GitHub/BA")

Main <- function(){
  cities <- read_dta("drive/raw/base/cities_families_1300_1918.dta")
  cities <- cities |> 
    select(city_id, year, terr_id, type_change)
  
  # NOTE: in the Princes and Townspeople data `terr_id` in the year of a switch
  # is recorded at the *end* of the period (i.e. the new owner). To use the empirical
  # framework of Schönholzer and Weese (2022) I have to recode it to the owner at the
  # *start* of the period. 
  
  # This means: 
  # - `terr_id` is that of the initial ruler in each year
  # - `switch` codes whether a switch took place during this year

  cities_with_switch_dummies <- cities |> 
    arrange(city_id, year) |> 
    group_by(city_id) |> 
    mutate(terr_id = lag(terr_id)) |>
    drop_na(terr_id) |> 
    mutate(switch = if_else(terr_id != lead(terr_id), 1, 0)) |>  # last year @ old territory
    drop_na(switch)
    
  # I do not lag `type_change` because the year in which the switch takes place
  # has the `type_change` of the new owner's rule (i.e. how the new owner came to power),
  # which is what I want.
  
  # I do get the trailing ones, though, which I'm not sure what I'll do with in the regression.
  
  CONQUEST_CATS <- c(4, 7) # "Conquest", "Acquisition by conflict"
  SUCCESSION_CATS <- c(3, 11) # "Extinction of lineage", "Inheritance", NOT "Marriage"
  
  cities_with_switch_types <- cities_with_switch_dummies |> 
    mutate(
      conquest = if_else(type_change %in% CONQUEST_CATS, 1, 0),
      succession = if_else(type_change %in% SUCCESSION_CATS, 1, 0)
      ) |> 
    select(-type_change)
  
  write_csv(cities_with_switch_types, "drive/derived/cities_switches.csv")
  
  return(0)
}

Main()
