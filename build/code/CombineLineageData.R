# Inputs:
# - lineage-year panel of size.
# - lineage level list of extinction year.

# Output: lineage-year panel of 
# - extinction dummy
# - size (no. of cities)
# - name for convenience

library(tidyverse)
library(haven)

setwd("~/GitHub/BA")

Main <- function(){
  lineages <- read.csv("build/temp/terr_sizes.csv")
  terr_codes <- read.csv("build/input/territory_codes.csv")
  extinctions <- read.csv("build/temp/last_rulers.csv") %>% 
    select(terr_id, death_year)
  
  lineages <- AddLineageNames(lineages, terr_codes)
  lineages <- AddExtinctionDummies(lineages, extinctions)
  lineages <- TidyOutput(lineages)
  
  lineages %>% write.csv("build/output/lineages.csv")
}

AddLineageNames <- function(lineages, terr_codes){
  lineages_with_names <- inner_join(lineages, terr_codes, by="terr_id")
  return(lineages_with_names)
}

AddExtinctionDummies <- function(lineages, extinctions){
  lineages_joined <- inner_join(lineages, extinctions, by="terr_id")
  # In this inner join I lose 100,000 lineage-year observations
  
  lineages_with_dummies <- lineages_joined %>% 
    mutate(final_full_year = death_year-1) %>% 
    # -1 because terr_ids are empty (no cities have them) in the actual extinction year
    mutate(extinction = if_else(year == final_full_year, 1, 0))
  return(lineages_with_dummies)
}

TidyOutput <- function(lineages){
  lineages_final <- lineages %>% 
    select(terr_id, year, terr_name, final_full_year, extinction, count_cities) %>% 
    rename(territory = terr_name)
  return(lineages_final)
}


Main()
