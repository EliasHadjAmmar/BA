#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(fixest) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")

build1 <- ReadCorrectBuild(default_t = 1)
build10 <- ReadCorrectBuild(default_t = 10)
build50 <- ReadCorrectBuild(default_t = 50) # uses command args if given
build100 <- ReadCorrectBuild(default_t = 100)

# How do I get switches that do / do not result in a permanent change?
# How about this:
# - get all [permanent] changes from the terr column alone (1 if terr != lead(terr))
# - this should be it!

PrepareData <- function(build){
  
  clean <- build |> 
    group_by(city_id) |> 
    mutate(lifetime_switches = sum(switches)) |> 
    filter(lifetime_switches <= 2) |>  # drops 50% of observations
    mutate(lag_switches = lag(switches)) |> 
    mutate(e_another = if_else(terr_id != lag(terr_id), 1, 0)) |> # lag, not lead
    drop_na(e_another, lag_switches) 
  return(clean)
}

# I've discovered an issue here that e_another can be 0 if lag_switches == 1. Apparently.
# I'm trying to find out what went wrong.

CheckBadSwitches <- function(build, n = 0){
  
  problems <- build |> PrepareData() |> 
    filter(lag_switches > 0 & e_another == 0)
  
  print(sprintf("%i problematic switches", nrow(problems)))
  
  if (n > 0){
    set.seed(0)
    problems <- problems |> 
      filter(city_id %in% sample(problems$city_id, n))
  }
    
  check <- build |> PrepareData() |>
    filter(city_id %in% problems$city_id) |> 
    filter(period %in% min(problems$period):max(problems$period)) |>
    select(city_id, period, terr_id, switches, e_another)

  return(check)
}


checkproblems <- CheckBadSwitches(build10, n=3)
checkS581 <- CheckEvent(build1, 1600:1620, terr="S581", city_start="200")



CheckEvent <- function(build, range, terr="B3742", city_start="1"){
  # shows the structure of switching dummies for the cities that
  # switch to terr in 1603.
  
  clean <- PrepareData(build)
  
  check <- clean |> 
    filter(startsWith(as.character(city_id), city_start) & period %in% range) |> 
    group_by(city_id) |> 
    filter(terr %in% terr_id) |> 
    select(city_id, period, terr_id, switches, e_another, lag_switches)
  
  return(check)
}
