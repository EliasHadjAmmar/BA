#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")
source("source/analysis/summarystats/SummaryLib.R") # functions for analysis

Main <- function(){
  # Read data
  t <- HandleCommandArgs(default_length = 50)
  read_path <- sprintf("drive/derived/cities_data_%iy.csv", t)
  build <- read_csv(read_path, show_col_types = F)
  
  raw_build <- read_csv("drive/derived/cities_switches.csv",
                        show_col_types = F) |> 
    rename(
      period = year,
      switches = switch) |> 
    mutate(conflict = 0) # just for convenience
  
  # Read city locations data for region-level stats
  locs <- read_csv("drive/raw/attributes/city_locations.csv", show_col_types = F) |> 
    select(city_id, region_id, name, nat)
  
  dsets <- list("build" = build, "raw" = raw_build)
  dsets |> map(GetBuildLevelInfo)
  dsets |> map(GetCityLevelInfo)
  dsets |> map(GetRegionLevelInfo, locs)
}






