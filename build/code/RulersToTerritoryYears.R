library(tidyverse)
library(haven)

setwd("~/GitHub/BA")

Main <- function(){
  rulers <- ImportRulers()
  rulers_lite <- SelectVariables(rulers)
  
  
}

ImportRulers <- function(){
  rulers <- read.csv("build/temp/rulers.csv")
  return(rulers)
}

SelectVariables <- function(rulers){
  rulers_lite <- rulers %>% 
    select(id, terr_id, start_reign, end_reign)
  return(rulers_lite)
}

ImportCities <- function(){
  cities <- read_dta("build/input/cities_families_1300_1918.dta")
  return(cities)
}

LineageYearObs <- function(cities){
  # Remember, we want to know: Who was head of territory j in year t?
  # The cities data contain many cities for each lineage-year. I don't need that here.
  # I want unique lineage-year observations to which I can assign a ruler.
  result <- cities %>% 
    select(terr_id, year) %>% 
    unique()
  return(result)
}

CurrentRuler <- function(lineage, year, rulers=rulers_lite){
  # We want this to return
  # - the unique ruler of that year and lineage if there is only one
  # - the ruler who was in power at the end of the year if there are more
  # end_reign is the year in which the ruler lost power.
  result <- rulers_lite %>%
    filter(terr_id == lineage, year >= start_reign, year < end_reign)
  return(result$id)
}

MapToRulers <- function(lineage_years){
  # Using rulers_lite as first arg should improve performance
  result <- lineage_years %>% 
    mutate(ruler_id = purrr::map2(terr_id, year, CurrentRuler))
  return(result)
}

rulers_lite <- ImportRulers() %>% SelectVariables()
CurrentRuler("A260", 1667)

lineage_years <- LineageYearObs(ImportCities())
with_rulers <- MapToRulers(lineage_years)


# Finished after 17 minutes! And didn't work. Ideas to speed this up: 
# - do this step last, and only after you've filtered out NA outcome years
# - rather than map, just join the rulers to the lineage_years table directly
#   and then R can optimise / vectorise more efficiently because it doesn't 
#   have to navigate two nested tibbles
