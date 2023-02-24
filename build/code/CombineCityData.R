# Input: 
# - city-year panel of lineage.
# - city-year panels of outcomes
# Output: tidy city-year panel of lineage and outcomes.
# Note: until I get yearly construction data, this outputs the smaller wage panel.

library(tidyverse)
library(haven)

setwd("~/GitHub/BA")

Main <- function(){
  cities <- read_dta("build/input/cities_families_1300_1918.dta") %>% 
    select(city_id, year, terr_id)
  wages <- read.csv("build/temp/wages.csv")
  # construction <- read.csv("build/temp/construction_new.csv")
  
  
  cities <- AddConstruction(cities, 0)
  cities <- AddWages(cities, wages)
  cities <- TidyOutput(cities)
  
  cities %>% write_csv("build/output/cities.csv")
}

AddConstruction <- function(cities, construction){
  return(cities)
}

AddWages <- function(cities, wages){
  joined <- inner_join(cities, wages, by=c("city_id", "year"))
  return(joined)
}

TidyOutput <- function(cities){
  final <- cities %>% 
    select(city_id, year, city, terr_id, real_wage, welfare_ratio)
  return(final)
}

Main()

