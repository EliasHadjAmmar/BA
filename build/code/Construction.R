# Input: city-year panel of construction from Princes and Townspeople.
# Output: city-year panel of custom aggregates of construction.
# Currently not functional.

library(tidyverse)

setwd("~/GitHub/BA")

Main <- function(){
  cons_raw <- read.csv("build/input/construction.csv")
  cons <- CountBuildings(cons_raw)
  cons_gaps <- AddGaps(cons)
  cons_clean <- TidyOutput(cons_gaps)
  cons_clean %>% write.csv("build/temp/construction_new.csv")
}


CountBuildings <- function(cons_raw){
  # experiment with filter settings!
  cons <- cons_raw %>% 
    filter(building %in% c(5:9, 13:16) & uncertainty==0) %>% 
    group_by(city_id, time_point) %>% 
    summarise(construction = n())
  
  return(cons)
}

AddGaps <- function(cons){
  all_keys <- cons %>% 
    group_by(city_id) %>% 
    expand(full_seq(time_point, 25)) %>% # change to 1 later
    rename(time_point = `full_seq(time_point, 25)`)
  
   with_gaps <- cons %>% 
     right_join(all_keys, by=c("city_id", "time_point")) %>% 
     replace_na(list(construction = 0)) %>% 
     arrange(city_id, time_point)
   
   return(with_gaps)
}

TidyOutput <- function(cons){
  # change this when you get the full data
  clean <- cons %>% 
    rename(year = time_point) %>% 
    select(city_id, year, construction)

  return(clean)
}

# Turns out that the publicly available construction data is coarsened.
# I have to ask Prof. Cantoni for the raw data before I can proceed 

Main()