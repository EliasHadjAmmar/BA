# Input: 
# - city-year panel of lineage.
# - city-year panels of outcomes
# Output: tidy city-year panel of lineage and outcomes.
# Note: to drop cities with missing outcomes, use inner joins.

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(haven))

setwd("~/GitHub/BA")

Main <- function(){
  cities <- read_dta("build/input/cities_families_1300_1918.dta") |> 
    select(city_id, year, terr_id)
  citycodes <- read_csv("build/input/city_locations.csv", show_col_types = F) |> 
    select(city_id, name)
  cities1875 <- read_csv("build/temp/cities1875.csv", show_col_types = F) |> 
    select(city_id, pop1875)
  wages <- read_csv("build/temp/wages.csv", show_col_types = F)
  cons <- read_csv("build/temp/construction_new.csv", show_col_types = F)
  
  cities <- cities |> left_join(citycodes, by="city_id")
  cities <- cities |> left_join(cities1875, by="city_id")
  cities <- AddConstruction(cities, cons)
  cities <- AddWages(cities, wages)
  cities <- TidyOutput(cities)
  
  cities |> write_csv("build/output/cities.csv")
}

AddConstruction <- function(cities, cons){
  # For now, just adds construction at the given time_points.
  # Will change this later.
  joined <- left_join(cities, cons, by=c("city_id", "year"))
  
  return(joined)
}

AddWages <- function(cities, wages){
  joined <- left_join(cities, wages, by=c("city_id", "year"))
  return(joined)
}

TidyOutput <- function(cities){
  final <- cities |> 
    select(city_id, year, name, terr_id, real_wage, welfare_ratio, construction, pop1875) |> 
    rename(city = name)
  return(final)
}

Main()

