# Input: Excel files of Allen's real wages.
# Output: a city-year panel of real wages in .csv format.

library(tidyverse)
library(readxl)

setwd("~/GitHub/BA")

Main <- function(){
  keys <- ImportKeys()
  excel_path <- "build/input/clean_crafts.xlsx"
  
  real_wages <- ProcessTable(excel_path, "realwages", keys)
  welfare_ratios <- ProcessTable(excel_path, "wratios", keys)
  
  combined <- CombineWageData(real_wages, welfare_ratios)
  combined %>% write.csv("build/temp/wages.csv")
}

ImportKeys <- function(){
  keys <- read.csv("build/input/CitiesWagesList.csv") %>% 
    select(name, city_id) %>% 
    rename(city = name) %>% 
    filter(!is.na(city_id))
  return(keys)
}

ProcessTable <- function(path, sheet, keys){
  wide <- read_excel(path, sheet = sheet)
  long <- WideToLong(wide, sheet)
  keyed <- JoinToCityID(long, keys)
  return(keyed)
}

WideToLong <- function(wide, varname){
  long <- wide %>% 
    pivot_longer(
      cols = !year,
      names_to = "city",
      values_to = varname
      )
  return(long)
}

JoinToCityID <- function(dat, keys){
  joined <- inner_join(dat, keys, by="city")
  return(joined)
}

CombineWageData <- function(wages, ratios){
  joined <- inner_join(wages, ratios, by=c("city_id", "year")) %>% 
    select(year, city_id, city.x, realwages, wratios) %>% 
    rename(city = city.x, real_wage = realwages, welfare_ratio = wratios)
  return(joined)
}

Main()
