#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(fixest) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")

Main <- function(){
  
  build <- ReadCorrectBuild(default_t = 50) # uses command args if given
  
  # analysis here
  
  return(0)
}


Analyse <- function(build){
  
  # or here
  
}