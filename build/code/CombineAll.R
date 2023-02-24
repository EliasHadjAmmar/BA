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

cities <- read.csv("build/output/cities.csv")
lineages <- read.csv("build/output/lineages.csv")

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

TidyOutput <- function(table){
  final <- table %>% 
    select(city_id, year, city, terr_id, territory, final_year, extinction, 
           count_cities, count_diff, real_wage, welfare_ratio)
  return(final)
}

test <- CombineTables(cities, lineages) %>% AddSizeDiffs() %>% TidyOutput()
