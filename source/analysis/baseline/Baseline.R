#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(fixest) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")
source("source/utils/DataPrepSuite.R")

Main <- function(){
  
  t <- HandleCommandArgs(default_length = 50)
  read_path <- sprintf("drive/derived/cities_data_%iy.csv", t)
  build <- read_csv(read_path, show_col_types = F)
  
  dat <- PrepareData(build,
                     max_switches = 2,
                     binarise_construction = T,
                     binarise_switches = T)
  
  mod <- fixest::feols(
    c_all ~ i(treat_type, D, ref=2) + D + switches | city_id + period, 
    data = dat)
  
  setFixest_dict(c(city_id = "City", period = "Period",
                   c_all = "All construction (binary)", D = "TREAT x POST",
                   treat_type = "Type", switches = "Switch"))
  
  # etable(mod)
  tex_output <- etable(mod, tex=TRUE)
  write(tex_output, file="analysis/output/tables/baseline_did.tex")
  
  
}


PrepareData <- function(build, max_switches,
                        binarise_construction, binarise_switches){
  
  # Filter out cities with too many lifetime switches
  selected <- FilterBySwitches(build, max_switches)
  
  # Identify across-period switches
  with_e_dummies <- AddEAnother(selected)
  
  # Add TREAT x POST dummies
  with_D <- AddTreatXPost(with_e_dummies)
  
  # Binarise construction outcomes, if specified
  if (binarise_construction) { with_D <- with_D |> BinariseOutcomes() }
  
  # Binarise no. of switches (control), if specified
  if (binarise_switches) { with_D <- with_D |> BinariseSwitches() }
  
  # Process type change into treatment type
  with_types <- ProcessTypeChange(with_D)
  
  # Rearrange columns (for readability)
  clean <- with_types |> select(
    city_id, treat_time, period, terr_id, switches, e_another, D, treat_type,
    conflict, c_all, c_state, c_private, c_public
  )
  
  return(clean)
}


Main()
