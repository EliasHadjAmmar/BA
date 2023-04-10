# Input: list of people.
# Output: territory-year panel of rulers.


suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(haven))

setwd("~/GitHub/BA")

Main <- function(){
  people <- read_dta("build/input/families_rulers_imputed.dta")
  
  rulers <- FilterRulers(people)
  rulers |> 
    mutate(death_year = death_year+1, end_reign = end_reign+1) |> 
    write_csv("build/temp/rulers.csv")
}


FilterRulers <- function(people){
  people$terr_id <- na_if(people$terr_id, '')
  rulers <- people |> 
    filter(!is.na(terr_id))
  return(rulers)
}

Main()
