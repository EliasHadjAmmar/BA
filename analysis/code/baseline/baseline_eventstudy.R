# Do the most basic version of an event study.
# Use the same data as in baseline_did.R. That means:
# Drop all cities with more than one treatment.
# Drop all city-years with missing outcomes.

library(tidyverse)
library(fixest)

setwd("~/GitHub/BA")

source("analysis/code/lib/SampleSelection.R")

Main <- function(){
  
  NLEADS <- 10
  NLAGS <- 15
  
  build <- read_csv("analysis/input/build.csv", show_col_types = FALSE)
  clean <- BaselineSample(build)
  with_window <- AddLeadsLags(clean, NLEADS, NLAGS)
  
  
  mod <- fixest::feols(construction ~ i(time_to_treat, treat, ref = -1) |  
                            city_id + year, data = with_window)
  
  iplot(mod)
  
  
  # setFixest_dict(c(city_id = "City", year = "Year",
  #                  construction = "Construction events", D = "TREAT x POST"))
  # 
  # tex_output <- etable(mod, tex=TRUE)
  # write(tex_output, file="analysis/output/tables/baseline_did.tex")
}

AddLeadsLags <- function(clean, nleads, nlags){
  timing <- clean |> 
    filter(treatment == 1) |> 
    mutate(treat_year = year) |> 
    select(city_id, treat_year)
  
  clean_with_timing <- clean |> 
    left_join(timing, by="city_id") |> 
    mutate(treat = ifelse(is.na(treat_year), 0, 1))
  
  clean_with_window <- clean_with_timing |> 
    mutate(time_to_treat = ifelse(treat == 1, year-treat_year, 0)) |> # create time-to-treat
    mutate(treat = ifelse(time_to_treat %in% -nleads:nlags, 1, 0)) |> # set treat=0 if not in window
    mutate(time_to_treat = ifelse(treat==0, 0, time_to_treat)) # set redundant times-to-treat vals =0
  
  return(clean_with_window)
}


Main()


