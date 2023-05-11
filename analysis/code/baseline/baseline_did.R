# Do the most basic version of a diff-in-diff first.
# Drop all cities with more than one treatment.
# Drop all city-years with missing outcomes.
# See what happens.

library(tidyverse)
library(fixest)

setwd("~/GitHub/BA")

source("analysis/code/lib/SampleSelection.R")

Main <- function(){
  build <- read_csv("analysis/input/build.csv", show_col_types = FALSE)
  clean <- BaselineSample(build)
  with_timing <- AddTreatDummies(clean)
  
  
  mod <- fixest::feols(construction ~ D | city_id + year, with_timing)
  
  setFixest_dict(c(city_id = "City", year = "Year",
                   construction = "Construction events", D = "TREAT x POST"))
  
  tex_output <- etable(mod, tex=TRUE)
  write(tex_output, file="analysis/output/tables/baseline_did.tex")
}


AddTreatDummies <- function(clean){
  timing <- clean |> 
    filter(treatment == 1) |> 
    mutate(treat_year = year) |> 
    select(city_id, treat_year)
  
  clean_with_timing <- clean |> 
    left_join(timing, by="city_id") |> 
    mutate(D = case_when(
      is.na(treat_year) ~ 0,
      year < treat_year ~ 0,
      year >= treat_year ~ 1
    ))
}


Main()
