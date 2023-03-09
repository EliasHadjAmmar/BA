# Input: 
# - city-year panel of lineage.
# - city-year panels of outcomes
# Output: tidy city-year panel of lineage and outcomes.
# Note: to drop cities with missing outcomes, use inner joins.

library(tidyverse)
library(haven)

setwd("~/GitHub/BA")

Main <- function(){
  cities <- read_dta("build/input/cities_families_1300_1918.dta") %>% 
    select(city_id, year, terr_id)
  wages <- read.csv("build/temp/wages.csv")
  construction <- read.csv("build/temp/construction_new.csv")
  
  
  cities <- AddConstruction(cities, construction)
  cities <- AddWages(cities, wages)
  cities <- TidyOutput(cities)
  
  cities %>% write_csv("build/output/cities.csv")
}

AddConstruction <- function(cities, construction){
  # For now, just adds construction at the given time_points.
  # Will change this later.
  joined <- left_join(cities, construction, by=c("city_id", "year"))
  
  return(joined)
}

AddWages <- function(cities, wages){
  joined <- left_join(cities, wages, by=c("city_id", "year"))
  return(joined)
}

TidyOutput <- function(cities){
  final <- cities %>% 
    select(city_id, year, city, terr_id, real_wage, welfare_ratio, buildings)
  return(final)
}

Main()

