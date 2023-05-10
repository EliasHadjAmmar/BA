# Do the most basic version of a diff-in-diff first.
# Drop all cities with more than one treatment.
# Drop all city-years with missing outcomes.
# See what happens.

library(tidyverse)
library(fixest)

setwd("~/GitHub/BA")

Main <- function(){
  build <- read_csv("analysis/input/build.csv", show_col_types = FALSE)
  clean <- CleanData(build)
  with_timing <- AddTreatDummies(clean)
  
  
  mod <- fixest::feols(construction ~ D | city_id + year, with_timing)
  
  setFixest_dict(c(city_id = "City", year = "Year",
                   construction = "Construction events", D = "TREAT x POST"))
  
  tex_output <- etable(mod, tex=TRUE)
  write(tex_output, file="analysis/output/tables/baseline_did.tex")
}


CleanData <- function(build){
  clean <- build |> 
    DropNACount("year") |> 
    DropNACount("city_id") |> 
    DropNACount("construction") |> 
    DropNACount("treatment")

  
  max1treat <- clean |> 
    group_by(city_id) |> 
    mutate(treatments_total = sum(treatment)) |> 
    filter(treatments_total < 2)
  
  n_dropped <- nrow(clean)-nrow(max1treat)
  cities_dropped <- n_distinct(clean$city_id)-n_distinct(max1treat$city_id)
  
  print(sprintf("Dropped %d observations with multiple treatments (%d cities)", 
                n_dropped, cities_dropped))
  
  clean <- max1treat |> 
    select(year, city_id, construction, treatment) |> 
    as.data.frame()
  
  return(clean)
}


DropNACount <- function(dat, varname){
  clean <- dat |> 
    drop_na(!!sym(varname))
  
  n_dropped <- nrow(dat)-nrow(clean)
  print(sprintf("Dropped %d observations with missing %s", n_dropped, varname))
  return(clean)
}


AddTreatDummies <- function(clean){
  timing <- clean |> 
    filter(treatment == 1) |> 
    mutate(treat_year = year) |> 
    select(city_id, treat_year)
  
  clean_with_timing <- clean |> 
    left_join(timing, by="city_id") |> 
    mutate(D = case_when(
      is.na(treat_year) ~ 0,
      year < treat_year ~ 0,
      year >= treat_year ~ 1
    ))
}


Main()
