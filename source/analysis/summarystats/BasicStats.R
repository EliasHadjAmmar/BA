#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")
source("source/utils/DataPrepSuite.R")
source("source/utils/PrepareBaselineData.R")

# Read data
t <- HandleCommandArgs(default_length = 1)
read_path <- sprintf("drive/derived/cities_data_%iy.csv", t)
build <- read_csv(read_path, show_col_types = F)

raw_build <- read_csv("drive/derived/cities_switches.csv",
                      show_col_types = F) |> 
  rename(
    period = year,
    switches = switch) |> 
  mutate(conflict = 0) # just for convenience


GetBuildLevelInfo <- function(build){
  build |> 
    summarise(
      min_year = min(period),
      max_year = max(period),
      avg_year = mean(period),
      med_year = median(period),
      n_cities = n_distinct(city_id),
      n_terrs = n_distinct(terr_id)
    )
}

GetCityLevelInfo <- function(build){
  build |> 
    group_by(city_id) |> 
    summarise(
      duration = max(period) - min(period),
      switches = sum(switches),
      conflict = sum(conflict),
      across(starts_with("c_"), sum)) |> 
    summarise(
      across(-c(city_id), \(col)(mean(col, na.rm=T)))
    )
}


dsets <- list("build" = build, "raw" = raw_build)
dsets |> map(GetBuildLevelInfo)
dsets |> map(GetCityLevelInfo)