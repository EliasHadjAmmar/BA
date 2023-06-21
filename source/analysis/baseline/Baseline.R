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
  
  # Estimate my baseline interaction equation
  mod_basic <- fixest::feols(
    c_all ~ i(rule_conquest, D, ref=0) + i(rule_other, D, ref=0) + D + switches | city_id + period, 
    data = dat)
  
  mod_conflict <- fixest::feols(
    c_all ~ i(rule_conquest, D, ref=0) + i(rule_other, D, ref=0) + D + switches + conflict | city_id + period, 
    data = dat)
  
  # Produce regression table and export to LaTeX
  etableDefaults()
  tex_output <- etable(mod_basic, mod_conflict, tex=TRUE,
                       title="Test Title",
                       label = sprintf("tab:baseline_%iy", t),
                       postprocess.tex = PostProcessBaseline)
  
  filename <- sprintf("paper/output/regressions/baseline_%iy.tex", t)
  write(tex_output, file=filename)
  
  return(0)
}


PrepareData <- function(build, max_switches,
                        binarise_construction, binarise_switches){
  
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


PostProcessBaseline <- function(tex_output){
  # Post-processing the TeX string to make it neater
  tex_post <- tex_output |> 
    str_replace("Conquest \\$=\\$ 1", "Conquest") |> 
    str_replace("Other \\$=\\$ 1", "Other")
  return(tex_post)
}


Main()
