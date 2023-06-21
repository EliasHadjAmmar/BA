#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/build/lib/ProcessConstruction.R")
source("source/build/lib/ProcessConflict.R")
source("source/utils/HandleCommandArgs.R")

Main <- function(){
  
  t <- HandleCommandArgs(default_length=50) 
  
  switches <- read_csv("drive/derived/cities_switches.csv", show_col_types = F)
  construction_raw <- read_delim("drive/raw/base/construction_all_xl.csv", delim=";", show_col_types = F)
  conflict_raw <- read_csv("drive/raw/base/conflict_incidents.csv", show_col_types = F)
  
  switches_t <- AggregateSwitches(switches, t)
  construction_t <- AggregateConstruction(construction_raw, t)
  conflict_t <- AggregateConflict(conflict_raw, t)
  
  cities_data <- list(switches_t, conflict_t, construction_t) |> 
    reduce(left_join) |> 
    drop_na(c_all)
  
  
  filename <- sprintf("drive/derived/cities_data_%iy.csv", t)
  write_csv(cities_data, filename)
  
  return(0)
}


AggregateSwitches <- function(switches, t){
  
  aggregated_t <- switches |> 
    arrange(city_id, year) |> 
    mutate(period = year - year %% t) |> 
    group_by(city_id, period) |> 
    summarise(
      terr_id = first(terr_id), # set to owner at the start of the period
      switches = sum(switch),
      rule_conquest = first(rule_conquest), # we want to know about *this* owner
      rule_succession = first(rule_succession),
      rule_other = first(rule_other),
      duration = n() # some periods may be cut off in the data
    )
  
  return(aggregated_t)
}


AggregateConstruction <- function(construction_raw, t){
  
  clean <- CleanEvents(construction_raw, t)
  
  counts_yearly <- ProcessConstruction(clean)
  
  aggregated_t <- counts_yearly |> 
    mutate(period = time_point - time_point %% t) |> 
    select(-time_point) |> 
    group_by(city_id, period) |> 
    summarise(across(everything(), sum))
  
  return(aggregated_t)
}


AggregateConflict <- function(conflict_raw, t){
  
  clean <- CleanEvents(conflict_raw, t)
  
  events_yearly <- ProcessConflict(clean)
  
  aggregated_t <- events_yearly |> 
    mutate(period = time_point - time_point %% t) |> 
    select(-time_point) |> 
    group_by(city_id, period) |> 
    summarise(conflict = max(conflict))
  
  return(aggregated_t)
}


CleanEvents <- function(raw, t){
  # Drops observations that are too imprecise from conflict & construction.
  
  if (t < 50) {ACCEPTABLE_RANGE <- 0
  } else if (t %in% 50:99) {ACCEPTABLE_RANGE <- 3
  } else if (t >= 100) {ACCEPTABLE_RANGE <- 4
  }
  
  clean <- raw |> 
    drop_na(city_id, time_point) |> 
    filter(uncertainty == 0) |> 
    filter(range <= ACCEPTABLE_RANGE)
  
  return(clean)
}


Main()
