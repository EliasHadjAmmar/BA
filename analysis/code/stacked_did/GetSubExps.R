# Input: build data and lineage-level list of extinctions
# Output: assignment of cities to groups in sub-experiments.
# list of cities with a huge amount of dummies.

library(tidyverse)
library(furrr)

setwd("~/GitHub/BA")
plan(multisession, workers=4)


Main <- function(){
  build <- read_csv("analysis/input/build.csv", show_col_types = F)
  extinctions <- read_csv("analysis/input/extinctions.csv", show_col_types = F)
  
  W <- 10
  
  subexps <- IdentifySubExps(extinctions, build, W)
  assignment <- AssignToAllSubExps(build, subexps)
  
  assignment <- DropEmptySubExps(assignment, threshold=10)
  
  assignment %>% write.csv("analysis/temp/assignment.csv")
  #return(assignment)
}


IdentifySubExps <- function(extinctions, build, W){
  # returns extinctions with (2*)W years of data before/after,
  # and their sub-experiment and inclusion windows.
  
  subexps <- extinctions %>% 
    filter(between(death_year, min(build$year) + W, max(build$year) - W)) %>% 
    rename(treat_year = death_year) %>% # not clear whether this needs to be +1!
    select(terr_id, treat_year) %>% 
    mutate(
      lower_inclusion_bound = treat_year - 2*W, # this is a choice
      upper_inclusion_bound = treat_year + W,
      exp_start = treat_year - W,
      exp_end = treat_year + W)
  return(subexps)
}


AssignToAllSubExps <- function(build, subexps){
  # this environment gets exported to all the workers
  
  subexps.list <- subexps |> # get list of rows of subexps
    select(-treat_year, -exp_start, -exp_end) |> 
    {\(.) split(., seq(nrow(.)))}()
  
  assignment <- subexps.list |> 
    furrr::future_map(\(d) AssignCitiesSubExp(d, build), .progress=TRUE) |> 
    reduce(left_join, by = "city_id")
  
  return(assignment)
}


AssignCitiesSubExp <- function(d, build){
  # returns the assignment of cities to treat, control, or exclude for subexp d.
  
  # get city-year observations from build for sub-experiment d
  incl_window <- d$lower_inclusion_bound:d$upper_inclusion_bound
  
  # find eligible cities (data for full window) and ungroup back to city-year
  d_base_data <- build %>% 
    filter(year %in% incl_window) %>% 
    group_by(city_id) %>% 
    filter(n() == length(incl_window)) %>% 
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
  
  # get vector of all city_ids that are in the experiment
  d_cities <- bind_rows(d_treat_cities, d_control_cities) %>% 
    select(city_id, d_treat)
  
  # make output vector that can be cbound to others later
  varname <- paste("treat_", d$terr_id, sep="")
  all_cities <- build$city_id |> unique() |> as_tibble_col(column_name="city_id")
  d_assignment <- left_join(all_cities, d_cities, by="city_id") |> # expands to all city_ids
    rename("{varname}" := d_treat)
    
  return(d_assignment)
}


DropEmptySubExps <- function(assignment, threshold=0){
  # drops sub-experiments where the treatment group is too small
  assignment %>% 
    select_if(colSums(., na.rm=TRUE) > threshold) %>% 
    return()
}


Main()
