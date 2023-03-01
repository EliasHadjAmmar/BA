# Input: lineage-year panel of rulers.
# Output: lineage-level data set of last ruler (max start_reign) with death_year.

library(tidyverse)

setwd("~/GitHub/BA")

Main <- function(){
  rulers <- ImportRulers()
  last_rulers <- GetLastRulersDeaths(rulers)
  extinctions <- RemoveDupes(last_rulers)
  extinctions %>% 
    write.csv("build/temp/last_rulers.csv")
}

ImportRulers <- function(){
  rulers <- read.csv("build/temp/rulers.csv")
  rulers <- rulers %>% 
    select(id, family, name, terr_id, birth_year, 
           death_year, start_reign, end_reign)
  return(rulers)
}

GetLastRulersDeaths <- function(rulers){
  # Slightly different results when you filter by max start_reign (one-year reigns).
  # Strictly speaking, what we care about is the death of the last family member,
  # not the death of the last ruler. They should be the same though.
  last_rulers <- rulers %>% 
    group_by(terr_id) %>% 
    mutate(last_death_year = max(death_year)) %>% 
    filter(death_year == last_death_year)
  return(last_rulers)
}

RemoveDupes <- function(last_rulers){
  # Turns the input into a long dataset at the lineage level.
  # Drops duplicate terr_ids and adds a dummy for affected lineages.
  # Needed because some terr_ids have two "last rulers", i.e. the two last family
  # members died in the same year. If we leave both in, this causes duplication
  # of lineage-year and city-year observations downstream.
  extinctions <- last_rulers %>% 
    group_by(terr_id) %>% 
    mutate(dupe_rulers = if_else(n() > 1, 1, 0)) %>%
    ungroup() %>% 
    distinct(terr_id, .keep_all=TRUE)
  return(extinctions)
}

Main()
