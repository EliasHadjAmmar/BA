# Input: yearly territorial histories of cities.
# Output: same, but with dummies for switching years, conquests, and successions.

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(haven))

setwd("~/GitHub/BA")

Main <- function(){
  cities <- read_dta("drive/raw/base/cities_families_1300_1918.dta")
  cities <- cities |> 
    select(city_id, year, terr_id, type_change)

  CONQUEST_CATS <- c(4, 7) # "Conquest", "Acquisition by conflict"
  SUCCESSION_CATS <- c(3, 11) # "Extinction of lineage", "Inheritance", NOT "Marriage"
  
  cities_with_switch_dummies <- cities |> 
    group_by(city_id, terr_id) |> 
    mutate(switch = if_else(year == min(year), 1, 0)) |> # first year @ new territory
    mutate(
      conquest = if_else(type_change %in% CONQUEST_CATS, 1, 0),
      succession = if_else(type_change %in% SUCCESSION_CATS, 1, 0)
      ) |> 
    ungroup() |> 
    group_by(city_id) |> 
    mutate(switch = if_else(year == min(year), 0, switch)) |> # foundation != switch
    select(-type_change)
  
  write_csv(cities_with_switch_dummies, "drive/derived/cities_switches.csv")
  
  return(0)
}

Main()
