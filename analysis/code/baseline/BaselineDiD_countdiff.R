suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(fixest))

setwd("~/GitHub/BA")

source("utils/BaselineSample.R")

Main <- function(){
  build <- read_csv("analysis/input/build.csv", show_col_types = FALSE)
  clean <- BaselineSample(build)
  with_timing <- AddTreatDummies(clean)
  
  
  mod <- fixest::feols(construction ~ D | city_id + year, with_timing)
  
  setFixest_dict(c(city_id = "City", year = "Year",
                   construction = "Construction events", D = "Size change x POST"))
  
  #summary(mod)
  
  tex_output <- etable(mod, tex=TRUE)
  write(tex_output, file="analysis/output/tables/baseline_did_size.tex")
}


AddTreatDummies <- function(clean){
  timing <- clean |> 
    filter(treatment == 1) |> 
    mutate(treat_year = year) |> 
    select(city_id, treat_year, count_diff) |> 
    rename(treat_intensity = count_diff)
  
  clean_with_timing <- clean |> 
    left_join(timing, by="city_id") |> 
    mutate(D = case_when(
      is.na(treat_year) ~ 0,
      year < treat_year ~ 0,
      year >= treat_year ~ treat_intensity
    ))
}


Main()
