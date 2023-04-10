# Inputs:
# - lineage panel
# - city panel
# Output: city-year panel of
# - ruling lineage
# - ruling lineage's extinction dummy
# - size of ruling lineage
# - size change from last year
# - construction

library(tidyverse)

setwd("~/GitHub/BA")

Main <- function(){
  cities <- read.csv("build/output/cities.csv")
  lineages <- read.csv("build/output/lineages.csv")
  
  build <- CombineTables(cities, lineages)
  build <- AddSizeDiffs(build)
  build <- PushExtinctions1Year(build)
  build <- TidyOutput(build)
  
  build %>% write.csv("build/output/build.csv")
}



CombineTables <- function(cities, lineages){
  joined <- inner_join(cities, lineages, by=c("terr_id", "year")) 
  return(joined)
}

AddSizeDiffs <- function(table){
  diffed <- table %>% 
    group_by(city_id) %>% 
    mutate(count_diff = count_cities - lag(count_cities)) %>% 
    ungroup()
  return(diffed)
}

PushExtinctions1Year <- function(table){
  # reasoning: the extinction dummy shows up in the last year of the 
  # dying lineage. That was necessary because the extinction list was 
  # easier to join to the old lineage than to the lineage that takes its 
  # place.
  # But I want a treatment dummy to show up in the same year as the
  # count_diff, i.e. in the first year under the new lineage.
  pushed <- table %>% 
    group_by(city_id) %>% 
    mutate(treatment = lag(extinction)) %>% # there's no way to avoid leading NA because I don't know the previous terr_id of those observations
    mutate(extinction_of = if_else(treatment==1, lag(terr_id), "")) %>% 
    ungroup()
  return(pushed)
}

TidyOutput <- function(table){
  final <- table %>% 
    select(city_id, year, city, terr_id, territory, final_full_year, extinction, 
           treatment, extinction_of, count_cities, count_diff, pop1875,
           construction, real_wage, welfare_ratio)
  return(final)
}

Main()
