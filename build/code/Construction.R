# Input: city-year panel of construction from Princes and Townspeople.
# Output: city-year panel of custom aggregates of construction.
# Currently not functional.

library(tidyverse)
library(haven)

setwd("~/GitHub/BA")

Main <- function(){
  return()
}

ImportConstruction <- function(){
  construction <- read.csv("build/input/construction.csv")
  return(construction)
}


# Turns out that the publicly available construction data is coarsened.
# I have to ask Prof. Cantoni for the raw data before I can proceed 

# Or make fake data.

FakeConstructionData <- function(dat){
  set.seed(1234)
}