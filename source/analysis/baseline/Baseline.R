#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(fixest) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")

build1 <- ReadCorrectBuild(default_t = 1)
build10 <- ReadCorrectBuild(default_t = 10)
build50 <- ReadCorrectBuild(default_t = 50) # uses command args if given

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
    mutate(e_another = if_else(terr_id != lead(terr_id), 1, 0)) |> 
    drop_na(e_another, lag_switches) 
  return(clean)
}

# I've discovered an issue here that e_another can be 0 if switches == 1. Apparently.
# I'm trying to find out what went wrong.

CheckB3742 <- function(build, range){
  # shows the structure of switching dummies for the cities that
  # switch to B3742 in 1603.
  
  clean <- PrepareData(build)
  
  check <- clean |> 
    filter(startsWith(as.character(city_id), "1") & period %in% range) |> 
    group_by(city_id) |> 
    filter("B3742" %in% terr_id) |> 
    select(city_id, period, terr_id, switches, e_another, lag_switches)
  
  return(check)
}

# The difference between check1 and the rest illustrates the problem.
check1 <- CheckB3742(build1, 1598:1608)
check10 <- CheckB3742(build10, 1560:1640)
check50 <- CheckB3742(build50, 1450:1700)




# clean50 |>
#   filter(lag_switches > 0 & e_another == 0) |> view()


