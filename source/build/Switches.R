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
  # *start* of the period. This means lagging it once.
  
  # Since I still want `type_change` to encode how the state in `terr_id` came
  # into power, I need to lag it once, as well.
  
  # This means: 
  # - `terr_id` is that of the initial state in each year
  # - `switch` codes whether a switch took place during this year
  # - `rule_{type}` codes how the state in `terr_id` came into power (as before)

  cities_with_switch_dummies <- cities |> 
    arrange(city_id, year) |> 
    group_by(city_id) |> 
    mutate(
      terr_id = lag(terr_id),
      type_change = lag(type_change)) |>
    drop_na(terr_id, type_change) |> 
    mutate(switch = if_else(terr_id != lead(terr_id), 1, 0)) |>  # last year @ old territory
    drop_na(switch)
    
  CONQUEST_CATS <- c(4, 7) # "Conquest", "Acquisition by conflict"
  SUCCESSION_CATS <- c(3, 11) # "Extinction of lineage", "Inheritance", NOT "Marriage"
  OTHER_CATS <- 0:13 |> base::setdiff(CONQUEST_CATS) |> base::setdiff(SUCCESSION_CATS)
  
  cities_with_switch_types <- cities_with_switch_dummies |> 
    mutate(
      rule_conquest = if_else(type_change %in% CONQUEST_CATS, 1, 0),
      rule_succession = if_else(type_change %in% SUCCESSION_CATS, 1, 0),
      rule_other = if_else(type_change %in% OTHER_CATS, 1, 0)
      )
  
  write_csv(cities_with_switch_types, "drive/derived/cities_switches.csv")
  
  return(0)
}

Main()
