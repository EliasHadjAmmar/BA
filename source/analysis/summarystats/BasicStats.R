#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(kableExtra) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")
source("source/utils/DataPrepSuite.R")
source("source/utils/PrepareBaselineData.R")
source("source/analysis/summarystats/SummaryLib.R") # functions for analysis
source("source/utils/PopBuild.R")


Main <- function(){
  # Read 50-year build
  t <- HandleCommandArgs(default_length = 50)
  read_path <- sprintf("drive/derived/cities_data_%iy.csv", t)
  build <- read_csv(read_path, show_col_types = F)
  
  # Read raw build (without aggregation and dropping NA c_all)
  raw_build <- read_csv("drive/derived/cities_switches.csv",
                        show_col_types = F) |> 
    rename(
      period = year,
      switches = switch) |> 
    mutate(conflict = 0) # just for convenience
  
  # Produce baseline sample
  sample <- PrepareBaselineData(build, max_switches=2,
                                binarise_construction = F, binarise_switches = F) |> 
    ungroup() # removing grouping is important
  
  
  # Read pop build
  pop_build <- AssemblePopBuild()
  
  # Read city locations data for region-level stats
  locs <- read_csv("drive/raw/attributes/city_locations.csv", show_col_types = F) |> 
    select(city_id, region_id, name, nat)
  
  # Compute summary statistisc
  dsets <- list("raw" = raw_build, "build" = build, "sample" = sample)
  build_stats <- dsets |> map(GetBuildLevelInfo) |> UnifyStats(names(dsets))
  city_stats <- dsets |> map(GetCityLevelInfo) |> UnifyStats(names(dsets))
  region_stats <- dsets |> map(GetRegionLevelInfo, locs) |> UnifyStats(names(dsets))
}

# 
# kbl(build_stats, format="latex",
#     col.names = c("Build", "Aggregation", "Min. period","Max. period", "Median period","No. of cities", "No. of states", "N"),
#     align="r") |> 
#   kable_paper()

pop_build |> drop_na(population) |> GetBuildLevelInfo()

