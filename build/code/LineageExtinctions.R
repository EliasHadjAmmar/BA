# Input: lineage-year panel of rulers.
# Output: lineage-level data set of last ruler (max start_reign) with death_year.

library(tidyverse)

setwd("~/GitHub/BA")

Main <- function(){
  rulers <- ImportRulers()
  last_rulers <- GetLastRulersDeaths(rulers)
  last_rulers %>% 
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

Main()
