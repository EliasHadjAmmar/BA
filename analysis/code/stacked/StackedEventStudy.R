#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(fixest) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("utils/GetAssignment.R")
source("utils/GetStackedData.R")
source("utils/AggregateYears.R")

Main <- function(){
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) > 1){
    stop("Can only pass one argument (spacing)\n")
  }
  if (!is_empty(args) && is.na(as.integer(args))) {
    stop("Argument must be an integer (spacing)\n")
  }

  spacing <- ifelse(!is_empty(args), as.integer(args)[1], 5)
  
  build <- read_csv("analysis/input/build.csv", show_col_types = F)
  extinctions <- read_csv("analysis/input/extinctions.csv", show_col_types = F)
  
  W <- 20
  
  assignment <- GetAssignment(build, extinctions, W, threshold=10)
  stacked_data <- GetStackedData(assignment, build, extinctions, W)
  
  filename <- sprintf("analysis/output/figures/stacked_es_%iW_%ispacing.png", W, spacing)
  
  png(filename=filename)
  PeriodES(stacked_data, spacing)
  dev.off()
  
}

YearlyES <- function(stacked_data){
  # Same output as PeriodES(..., spacing=1)
  
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