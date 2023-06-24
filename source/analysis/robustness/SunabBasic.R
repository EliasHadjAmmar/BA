#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(fixest) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")
source("source/utils/DataPrepSuite.R")
source("source/utils/etableDefaults.R")

Main <- function(){
  
  # Read data
  t <- HandleCommandArgs(default_length = 50)
  read_path <- sprintf("drive/derived/cities_data_%iy.csv", t)
  build <- read_csv(read_path, show_col_types = F)
  
  # Select sample and process data (exact steps documented below)
  dat <- PrepareData(build,
                     max_switches = 2,
                     binarise_construction = T,
                     binarise_switches = T)
  
  mod <- fixest::feols(
    c_all ~ sunab(treat_time, period) + switches | city_id + period, 
    data = dat
  )
  
  summary(mod, agg="att")

  iplot(mod)  
}


PrepareData <- function(build, max_switches,
                        binarise_construction, binarise_switches){
  # Copied from baseline/Baseline.R
  
  
  # Filter out cities with too many lifetime switches
  selected <- FilterBySwitches(build, max_switches)
  
  # Identify across-period switches
  with_e_dummies <- AddEAnother(selected)
  
  # Add TREAT x POST dummies D
  with_D <- AddTreatXPost(with_e_dummies)
  
  # Binarise construction outcomes, if specified
  if (binarise_construction) { with_D <- with_D |> BinariseOutcomes() }
  
  # Binarise no. of switches (control), if specified
  if (binarise_switches) { with_D <- with_D |> BinariseSwitches() }
  
  # Process type change into treatment type
  with_types <- ProcessTypeChange(with_D)
  
  # Rearrange columns (for readability)
  clean <- with_types |> select(
    city_id, treat_time, period, terr_id, switches, e_another, D, 
    rule_conquest, rule_succession, rule_other,
    conflict, c_all, c_state, c_private, c_public
  )
  
  return(clean)
}


Main()