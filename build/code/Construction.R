# Input: city-year panel of construction from Princes and Townspeople.
# Output: city-year panel of custom aggregates of construction.
# Currently not functional.

library(tidyverse)

setwd("~/GitHub/BA")

Main <- function(){
  cons_raw <- read.csv("build/input/construction.csv") %>% 
    select(city_id, city_name, year_clear, building, buildgen, newbuild, uncertainty) %>% 
    rename(year = year_clear)
  cons <- CountBuildings(cons_raw)
  cons_gaps <- AddGaps(cons)
  cons_clean <- TidyOutput(cons_gaps)
  cons_clean %>% write.csv("build/temp/construction_new.csv")
}


CountBuildings <- function(cons_raw, exclude=NULL){
  # experiment with filter settings!
  cons <- cons_raw %>% 
    filter(!building %in% exclude & uncertainty==0) %>% 
    group_by(city_id, year) %>% 
    summarise(construction = n())
  return(cons)
}


AddGaps <- function(cons){
  all_keys <- cons %>% 
    group_by(city_id) %>% 
    expand(full_seq(year, 1)) %>% # change to 1 later
    rename(year = `full_seq(year, 1)`)
  
   with_gaps <- cons %>% 
     right_join(all_keys, by=c("city_id", "year")) %>% 
     replace_na(list(construction = 0)) %>% 
     arrange(city_id, year)
   
   return(with_gaps)
}

TidyOutput <- function(cons){
  # change this when you get the full data
  clean <- cons %>% 
    select(city_id, year, construction) %>% 
    mutate(construction_any = as.numeric(construction > 0))

  return(clean)
}

# Turns out that the publicly available construction data is coarsened.
# I have to ask Prof. Cantoni for the raw data before I can proceed 

test <- Main()