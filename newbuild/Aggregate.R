#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("newbuild/LibConstruction.R")

Main <- function(){
  
  t <- HandleCommandArgs(default_length=50) 
  
  switches <- read_csv("newbuild/temp/cities_switches.csv", show_col_types = F)
  construction <- read_delim("build/input/construction_all_xl.csv", delim=";", show_col_types = F)
  
  
  switches_t <- AggregateSwitches(switches, t)
  construction_t <- AggregateConstruction(construction, t)
  
  
  return(0)
}


AggregateConstruction <- function(construction, t){
  
  if (t < 50) {ACCEPTABLE_RANGE <- 0
    } else if (t %in% 50:99) {ACCEPTABLE_RANGE <- 3
    } else if (t >= 100) {ACCEPTABLE_RANGE <- 4
      }
  
  construction_clean <- construction |> 
    filter(uncertainty == 0) |> 
    filter(range <= ACCEPTABLE_RANGE)
  
  counts_yearly <- ConstructionTable(construction_clean)
  
  aggregated_t <- counts_yearly |> 
    mutate(period = time_point - time_point %% t) |> 
    select(-time_point) |> 
    group_by(city_id, period) |> 
    summarise(across(everything(), sum))
  
  return(aggregated_t)
}


AggregateSwitches <- function(switches, t){
  
  aggregated_t <- switches |> 
    arrange(city_id, year) |> 
    mutate(period = year - year %% t) |> 
    group_by(city_id, period) |> 
    summarise(
      first_terr_id = first(terr_id), # set to owner at the start of the period
      switches = sum(switch),
      conquest = last(conquest), # we want the info about the *final* switch
      succession = last(succession),
      duration = n() # some periods may be cut off in the data
    )
  
  return(aggregated_t)
}


HandleCommandArgs <- function(default_length){
  # This is so I don't need 3 scripts to output 3 datasets with different spacing.
  
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) > 1){
    stop("Can only pass one argument (period length)\n")
  }
  if (!is_empty(args) && is.na(as.integer(args))) {
    stop("Argument must be an integer (period length)\n")
  }
  
  t <- ifelse(!is_empty(args), as.integer(args)[1], default_length)
  return(t)
}
