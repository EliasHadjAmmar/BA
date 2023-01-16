library(tidyverse)

setwd("~/GitHub/BA")


ImportTerritories <- function(){
  territories <- read.csv("build/input/territories.csv")
  territories <- territories %>% 
     select(city_id, terr_id, sovereign_number, time_point, observation, point_id, 
          type_reign, type_change, city_status, foreign_rule)
  return(territories)
}

ExtinctionObservationsTiming <- function(territories){
  observations <- territories %>% 
    filter(type_change == 3) %>% 
    group_by(observation) %>% 
    summarise(first_year = min(time_point))
  return(observations)
}

