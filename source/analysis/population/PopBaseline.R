library(tidyverse) |> suppressPackageStartupMessages()
library(fixest) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/utils/DataPrepSuite.R")
source("source/utils/PopBuild.R")

Main <- function(){
  
  # Read data
  build <- AssemblePopBuild()
  
  # Select sample and process data (exact steps documented below)
  dat <- PrepareData(build,
                     max_switches = 2,
                     binarise_switches = T)
  
  # Estimate my baseline interaction equation
  mod <- fixest::feols(
    population ~ i(treat_type, D, ref=2) + D + switches | city_id + period, 
    data = dat)
  
  # Produce regression table and export to LaTeX
  setFixest_dict(c(city_id = "City", period = "Period", population = "Population",
                   D = "TREAT x POST", treat_type = "Type", switches = "Switch"))
  
  tex_output <- etable(mod, tex=TRUE)
  
  filename <- "paper/output/regressions/baseline_pop.tex"
  write(tex_output, file=filename)
  
  return(0)
}


PrepareData <- function(build, max_switches, binarise_switches){
  
  # Filter out cities with too many lifetime switches
  selected <- FilterBySwitches(build, max_switches)
  
  # Identify across-period switches
  with_e_dummies <- AddEAnother(selected)
  
  # Add TREAT x POST dummies
  with_D <- AddTreatXPost(with_e_dummies)
  
  # Binarise no. of switches (control), if specified
  if (binarise_switches) { with_D <- with_D |> BinariseSwitches() }
  
  # Process type change into treatment type
  with_types <- ProcessTypeChange(with_D)
  
  # Rearrange columns (for readability)
  clean <- with_types |> select(
    city_id, treat_time, period, terr_id, switches, e_another, D, treat_type,
    conflict, population
  )
  
  return(clean)
}


Main()
