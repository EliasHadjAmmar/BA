#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(fixest) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")

Main <- function(){
  
  t <- HandleCommandArgs(default_length=50) 
  
  read_path <- sprintf("drive/derived/cities_data_%iy.csv", t)
  build <- read_csv(read_path)
  
  # analysis here
  
  return(0)
}


Analyse <- function(build){
  
  # or here
  
}