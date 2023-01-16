library(tidyverse)
library(haven)

setwd("~/GitHub/BA")

Main <- function(){
  rulers <- ImportRulers()
  rulers_lite <<- SelectVariables(rulers) # global is necessary I tried everything
  cities <- ImportCities()
  lineage_years <- LineageYearObs(cities)
  
  rulers_linked <- MapToRulers(lineage_years) # takes 17 minutes
  WriteSeparateCSV(rulers_linked)
  
  return(0)
}

TestOnSubset <- function(size){
  rulers <- ImportRulers()
  rulers_lite <<- SelectVariables(rulers) # same as above
  cities <- ImportCities()
  lineage_years <- LineageYearObs(cities)
  
  testdata <- slice_sample(lineage_years, n=size)
  sample_linked <- MapToRulers(testdata)
  WriteSeparateCSV(sample_linked)
  #return(sample_linked)
  return(0)
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

CurrentRuler <- function(lineage, year){
  # We want this to return
  # - the unique ruler of that year and lineage if there is only one
  # - the ruler who was in power at the end of the year if there are more
  # end_reign is the year in which the ruler lost power.
  # We use this in a map2() call in MapToRulers().
  result <- rulers_lite %>% # problematic global here
    filter(terr_id == lineage, year >= start_reign, year < end_reign) %>% 
    select(id) %>% 
    pluck(1)
  return(result)
}

MapToRulers <- function(lineage_years){
  # room for performance improvements
  result <- lineage_years %>% 
    mutate(ruler_id = purrr::map2(terr_id, year, CurrentRuler)) %>% 
    mutate(matches = map_int(ruler_id, length))
  return(result)
}

WriteSeparateCSV <- function(rulers_linked){
  rulers_linked %>% 
    filter(matches == 1) %>% 
    mutate(id = as.character(ruler_id)) %>% 
    select(terr_id, year, id, matches) %>% 
    write.csv("build/temp/rulers_linked.csv")
  
  rulers_linked %>% 
    filter(matches != 1) %>% 
    select(-ruler_id) %>% 
    write.csv("build/temp/rulers_not_linked.csv")
}

TestOnSubset(20)

# In its current state, I do match some rulers to territory-years. Many others
# have terr_id equal to integer(0), though. That's an empty vector. This means
# that there was nothing left after filtering for ruler_id and reign.
# How can that be?


