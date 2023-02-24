# Input: 
# - city-year panel of lineage.
# - city-year panel of construction.
# Output: tidy city-year panel of lineage and construction.
# Note: until I get yearly construction data, this only outputs 
# the tidy panel of lineage without construction, for CombineAll.R.

library(tidyverse)
library(haven)

setwd("~/GitHub/BA")

Main <- function(){
  cities <- read_dta("build/input/cities_families_1300_1918.dta") %>% 
    select(city_id, year, terr_id)
  # wages <- read.csv("build/temp/wages.csv")
  # construction <- read.csv("build/temp/construction_clean.csv")
  
  
  cities <- AddConstruction(cities, 0)
  cities <- AddWages(cities, 0)
  
  cities %>% write_csv("build/output/cities.csv")
}

AddConstruction <- function(cities, construction){
  return(cities)
}

AddWages <- function(cities, wages){
  return(cities)
}


