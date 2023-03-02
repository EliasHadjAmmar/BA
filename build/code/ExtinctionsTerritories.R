# Input: the territories.csv data (downloaded from Harvard Dataverse)
# Output: list of extinctions.

# Note: see analysis/code/CheckExtinctionLists.Rmd for intuition

library(tidyverse)
setwd("~/GitHub/BA")


Main <- function(){
  territories <- ImportData()
  extinctions <- Extinctions(territories)
  extinctions <- AddYearsFromComments(extinctions)
  extinctions <- TidyOutput(extinctions)
  
  extinctions %>% write.csv("build/temp/ext_terrs.csv")
}

ImportData <- function(){
  territories <- read_csv("build/input/territories.csv") %>% 
    select(city_id, time_point, terr_id, observation, type_reign, 
           type_change, commentary_primary, commentary_secondary)
  return(territories)
}

Extinctions <- function(territories){
  after <- GetObsJustAfterExt(territories)
  
  after_dummies <- after %>% 
    mutate(after_ext = 1) %>% 
    select(observation, time_point, after_ext)
  
  obs_with_dummies <- left_join(
    territories, after_dummies, by=c("observation", "time_point")
    )
  
  extinctions <- obs_with_dummies %>% 
    group_by(city_id) %>% 
    mutate(
      extinction_of = lag(terr_id, order_by=time_point)) %>% 
    ungroup() %>% 
    filter(after_ext == 1) %>% 
    distinct(extinction_of, .keep_all = TRUE) # `extinction_of` is the data key
    
  return(extinctions)
}

GetObsJustAfterExt <- function(territories){
  after <- territories %>% 
    filter(type_change == 3) %>% # for every extinction observation,
    group_by(observation) %>% 
    mutate(
      min_year = min(time_point)) %>%  # keep only the first occurrence
    ungroup() %>% 
    filter(time_point == min_year) 
  return(after)
}

AddYearsFromComments <- function(extinctions){
  return(extinctions)
}

TidyOutput <- function(extinctions){
  # IMPORTANT: gives the observation from the new lineage back to the old, 
  # without changing the time_point.
  # I'm deciding here that it's not important to distinguish between
  # the before and after time_points, because they're inaccurate
  # and I'm going to regex the comments for the exact years anyways.
  extinctions %>% 
    rename(new_terr_id = terr_id) %>% 
    rename(terr_id = extinction_of) %>% 
    # select() %>% # uncomment once you have the regex'd year column
    return()
}

Main()