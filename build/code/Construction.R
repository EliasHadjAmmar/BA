# Input: city-year panel of construction from Princes and Townspeople.
# Output: city-year panel of custom aggregates of construction.

suppressPackageStartupMessages(library(tidyverse))

setwd("~/GitHub/BA")

Main <- function(){
  
  # Note: the construction_all.csv file I got from Prof. Cantoni couldn't be read properly,
  # with values being parsed into the wrong column for 3,230 rows. I was able to fix this
  # by reading the file into an Excel sheet and exporting it back to .csv.
  cons_raw <- read_delim("build/input/construction_all_xl.csv", delim = ";", show_col_types = F) |> 
    rename(year = time_point)
  
  cons <- CountBuildings(cons_raw)
  cons_gaps <- AddGaps(cons)
  
  cons_clean <- TidyOutput(cons_gaps)
  cons_clean |> write_csv("build/temp/construction_new.csv")
  
}


CountBuildings <- function(cons_raw, exclude=NULL){
  # experiment with filter settings!
  cons <- cons_raw |> 
    filter(!building %in% exclude & uncertainty==0) |> # only precise years
    group_by(city_id, year) |> 
    summarise(construction = n())
  return(cons)
}


AddGaps <- function(cons){
  all_keys <- cons |> 
    group_by(city_id) |> 
    expand(full_seq(year, 1)) |>
    rename(year = `full_seq(year, 1)`)
  
   with_gaps <- all_keys |> 
     left_join(cons, by=c("city_id", "year")) |> 
     replace_na(list(construction = 0)) |> 
     arrange(city_id, year)
   
   return(with_gaps)
}


TidyOutput <- function(cons){
  clean <- cons |> 
    select(city_id, year, construction) |> 
    mutate(construction_any = as.numeric(construction > 0))

  return(clean)
}


Main()