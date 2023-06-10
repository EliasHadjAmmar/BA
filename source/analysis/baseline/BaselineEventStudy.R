# Do the most basic version of an event study.
# Use the same data as in baseline_did.R. That means:
# Drop all cities with more than one treatment.
# Drop all city-years with missing outcomes.

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(fixest))

setwd("~/GitHub/BA")

source("utils/BaselineSample.R")
source("utils/AggregateYears.R")

Main <- function(){

  build <- read_csv("analysis/input/build.csv", show_col_types = FALSE)
  bsample <- BaselineSample(build)
  
  YearlyES(bsample, t_lead=5, t_lag=10)
  PeriodES(bsample, t_lead=20, t_lag=40, spacing=5)
  
}


AddLeadsLags <- function(clean, t_lead, t_lag, tname="year"){
  timing <- clean |> 
    filter(treatment == 1) |> 
    mutate(treat_time = !!sym(tname)) |> 
    select(city_id, treat_time)
  
  clean_with_timing <- clean |> 
    left_join(timing, by="city_id") |> 
    mutate(treat = ifelse(is.na(treat_time), 0, 1))
  
  clean_with_window <- clean_with_timing |> 
    mutate(time_to_treat = ifelse(treat == 1, !!sym(tname)-treat_time, 0)) |> # create time-to-treat
    mutate(treat = ifelse(time_to_treat %in% -t_lead:t_lag, 1, 0)) |> # set treat=0 if not in window
    mutate(time_to_treat = ifelse(treat==0, 0, time_to_treat)) # set redundant times-to-treat vals =0
  
  return(clean_with_window)
}


YearlyES <- function(bsample, t_lead, t_lag){

  with_dummies <- AddLeadsLags(bsample, t_lead, t_lag, tname="year")
  
  mod <- fixest::feols(construction ~ i(time_to_treat, treat, ref = -1) |  
                            city_id + year, data = with_dummies)

  iplot(mod)
  
  
  # setFixest_dict(c(city_id = "City", year = "Year",
  #                  construction = "Construction events", D = "TREAT x POST"))
  # 
  # tex_output <- etable(mod, tex=TRUE)
  # write(tex_output, file="analysis/output/tables/baseline_did.tex")
}


PeriodES <- function(bsample, t_lead, t_lag, spacing){
  
  agg_sample <- AggregateYears(bsample, spacing)
  with_dummies <- AddLeadsLags(agg_sample, t_lead, t_lag, tname="period")
  
  mod <- fixest::feols(construction ~ i(time_to_treat, treat, ref = -spacing) |  
                         city_id + period, data = with_dummies)
  
  iplot(mod)
}


Main()


