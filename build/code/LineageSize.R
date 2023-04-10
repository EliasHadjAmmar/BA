# Input: city-year panel of ruling lineage.
# Output: lineage-year panel of no. of cities held.

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(haven))

setwd("~/GitHub/BA")

Main <- function(){
  cities <- read_dta("build/input/cities_families_1300_1918.dta") |> 
    select(city_id, year, terr_id, foreign_rule)
  
  terr_sizes <- CountCities(cities)
  terr_sizes %>% 
    write_csv("build/temp/terr_sizes.csv")
}

CountCities <- function(cities){
  terr_sizes <- cities %>% 
    group_by(terr_id, year) %>% 
    summarise(count_cities = n())
  return(terr_sizes)
}

Main()



