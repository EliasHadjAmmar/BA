library(tidyverse)
library(haven)

setwd("~/GitHub/BA")

Main <- function(){
  people <- ImportPeople()
  rulers <- FilterRulers(people)
  rulers %>% 
    mutate(death_year = death_year+1, end_reign = end_reign+1) %>% 
    write.csv("build/temp/rulers.csv")
}

ImportPeople <- function(){
  people <- read_dta("build/input/families_rulers_imputed.dta")
  return(people)
}

FilterRulers <- function(people){
  people$terr_id <- na_if(people$terr_id, '')
  rulers <- people %>% 
    filter(!is.na(terr_id))
  return(rulers)
}

Main()
