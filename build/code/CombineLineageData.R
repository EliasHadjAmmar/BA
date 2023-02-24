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
    select(terr_id, death_year, id) %>% 
    rename(extinction_year = death_year,
           last_ruler_id = id)
  
  lineages <- AddLineageNames(lineages, terr_codes)
  lineages <- AddExtinctionDummies(lineages, extinctions)
  lineages <- TidyOutput(lineages)
  
  lineages %>% write.csv("build/output/lineages.csv")
}

AddExtinctionDummies <- function(lineages, extinctions){
  lineages_with_ext_years <- inner_join(lineages, extinctions, by="terr_id")
  # In this inner join I lose 100,000 lineage-year observations (presumably 
  # lineages in the city data which do not show up in the ruler data.)
  
  lineages_with_dummies <- lineages_with_ext_years %>% 
    mutate(final_year = extinction_year - 1) %>% 
    # -1 because terr_ids are empty (no cities have them) in the actual extinction year
    mutate(extinction = if_else(year == final_year, 1, 0))
  
  return(lineages_with_dummies)
}

AddLineageNames <- function(lineages, terr_codes){
  lineages_with_names <- inner_join(lineages, terr_codes, by="terr_id")
  return(lineages_with_names)
}

TidyOutput <- function(lineages){
  lineages_final <- lineages %>% 
    select(terr_id, year, terr_name, final_year, extinction, count_cities)
  return(lineages_final)
}


Main()
