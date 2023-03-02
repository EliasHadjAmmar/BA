# Input: build data and lineage-level list of extinctions
# Output: assignment of cities to groups in sub-experiments.
# list of cities with a huge amount of dummies.

library(tidyverse)
setwd("~/GitHub/BA")


Main <- function(){
  data <- read_csv("analysis/input/build.csv")
  extinctions <- read_csv("build/temp/last_rulers.csv")
  
  W <- 10
  
  subexps <- IdentifySubExps(extinctions, data, W)
  assignment <- AssignCitiesAll(subexps, data)
  
  assignment <- DropEmptySubExps(assignment, threshold=4)
  
  assignment %>% write.csv("analysis/temp/assignment.csv")
  #return(assignment)
}


IdentifySubExps <- function(extinctions, build, W){
  # returns extinctions with (2*)W years of data before/after,
  # and their sub-experiment and inclusion windows.
  
  subexps <- extinctions %>% 
    filter(between(death_year, min(build$year) + W, max(build$year) - W)) %>% 
    rename(treat_year = death_year) %>% 
    select(terr_id, treat_year) %>% 
    mutate(
      lower_inclusion_bound = treat_year - 2*W, # this is a choice
      upper_inclusion_bound = treat_year + W,
      exp_start = treat_year - W,
      exp_end = treat_year + W)
  return(subexps)
}

AssignCitiesSubExp <- function(d, build){
  # returns the city-year observations for sub-experiment d.
  incl_range <- d$lower_inclusion_bound:d$upper_inclusion_bound
  
  # find eligible cities (full available data) and ungroup back to city-year
  d_base_data <- build %>% 
    filter(year %in% incl_range) %>% 
    group_by(city_id) %>% 
    filter(n() == length(incl_range)) %>% 
    ungroup()
  
  # get treatment group
  d_treat_cities <- d_base_data %>% # this is all cities satisfying:
    group_by(city_id) %>% 
    filter(sum(treatment) == 1) %>% # 1) there must be exactly one treatment AND
    ungroup() %>% 
    filter(treatment == 1) %>% 
    filter(extinction_of == d$terr_id) %>% # 2) that one treatment is d
    mutate(d_treat = TRUE)
  
  # get control group
  d_control_cities <- d_base_data %>% # this is all cities satisfying:
    group_by(city_id) %>% 
    filter(sum(treatment) == 0) %>% # zero treatments in the inclusion period
    summarise(d_treat = FALSE)
  
  # get all cities in the experiment
  d_cities <- bind_rows(d_treat_cities, d_control_cities) %>% 
    select(city_id, d_treat)
    
  return(d_cities)
}

AssignCitiesAll <- function(subexps, build){
  all_cities <- build %>% 
    group_by(city_id) %>% 
    summarise()
  
  for (row in rownames(subexps)){
    d <- subexps[row,]
    varname <- paste("treat_", d$terr_id, sep="")
    
    d_assignment <- AssignCitiesSubExp(d, build) %>% 
      rename("{varname}" := d_treat)
    
    all_cities <- left_join(all_cities, d_assignment, key="city_id")
  }
  
  return(all_cities)
}  

DropEmptySubExps <- function(assignment, threshold=0){
  assignment %>% 
    select_if(colSums(., na.rm=TRUE) > threshold) %>% 
    return()
}

#subexps <- IdentifySubExps(extinctions, data, 10)
#test <- Main()

Main()
