# Input: city-year panel of ruling lineage.
# Output: lineage-year panel of no. of cities held.

library(tidyverse)
library(haven)

setwd("~/GitHub/BA")

Main <- function(){
  cities <- ImportCities()
  terr_sizes <- CountCities(cities)
  terr_sizes %>% 
    write.csv("build/temp/terr_sizes.csv")
}


ImportCities <- function(){
  cities <- read_dta("build/input/cities_families_1300_1918.dta")
  cities <- cities %>% 
    select(city_id, year, terr_id, foreign_rule)
  return(cities)
}

CountCities <- function(cities){
  terr_sizes <- cities %>% 
    group_by(terr_id, year) %>% 
    summarise(count_cities = n())
  return(terr_sizes)
}

Main()



