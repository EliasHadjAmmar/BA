# Input: list of conflict incidents from Princes and Townspeople.
# Output: city-year panel of conflict. 
# I just want one super basic dummy: "was there conflict in this year?"

suppressPackageStartupMessages(library(tidyverse))

setwd("~/GitHub/BA")

conflict_raw <- read_csv("build/input/conflict_incidents.csv")

conflict <- conflict_raw |> 
  filter(uncertainty==0) |> 
  filter(range==0)
