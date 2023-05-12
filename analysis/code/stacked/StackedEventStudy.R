library(tidyverse) |> suppressPackageStartupMessages()
library(fixest) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("utils/GetAssignment.R")
source("utils/GetStackedData.R")
source("utils/AggregateYears.R")

Main <- function(){
  build <- read_csv("analysis/input/build.csv", show_col_types = F)
  extinctions <- read_csv("analysis/input/extinctions.csv", show_col_types = F)
  
  W <- 20
  
  assignment <- GetAssignment(build, extinctions, W, threshold=10)
  stacked_data <- GetStackedData(assignment, build, extinctions, W)
  
  YearlyES(stacked_data)
  PeriodES(stacked_data, spacing=5)
  
}


YearlyES <- function(stacked_data){
  
  with_dummies <- stacked_data |> 
    mutate(time_to_treat = year - treat_year) |> 
    mutate(time_to_treat = ifelse(TREAT==FALSE, 0, time_to_treat))
  
  mod <- fixest::feols(construction ~ i(time_to_treat, TREAT, ref = -1) |  
                         city_id^subexp + year^subexp, data = with_dummies)
  
  iplot(mod)  
}


PeriodES <- function(stacked_data, spacing){
  agg_data <- AggregateStacked(stacked_data, spacing)
  with_dummies <- agg_data |> 
    mutate(time_to_treat = period - treat_period) |> 
    mutate(time_to_treat = ifelse(TREAT==FALSE, 0, time_to_treat))
  
  mod <- fixest::feols(construction ~ i(time_to_treat, TREAT, ref = -spacing) |  
                         city_id^subexp + period^subexp, data = with_dummies)
  
  iplot(mod)  
}
  
  
Main()