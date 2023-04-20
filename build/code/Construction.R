# Input: city-year panel of construction from Princes and Townspeople.
# Output: city-year panel of custom aggregates of construction.

suppressPackageStartupMessages(library(tidyverse))

setwd("~/GitHub/BA")

Main <- function(){
  cons_raw <- read_csv("build/input/construction_all.csv", show_col_types = F) |> 
    rename(year = time_point)
  cons <- CountBuildings(cons_raw)
  cons_gaps <- AddGaps(cons)
  cons_clean <- TidyOutput(cons_gaps)
  cons_clean |> write_csv("build/temp/construction_new.csv")
}


CountBuildings <- function(cons_raw, exclude=NULL){
  # experiment with filter settings!
  cons <- cons_raw |> 
    filter(!building %in% exclude & uncertainty==0) |> 
    group_by(city_id, year) |> 
    summarise(construction = n())
  return(cons)
}


AddGaps <- function(cons){
  all_keys <- cons |> 
    group_by(city_id) |> 
    expand(full_seq(year, 1)) |> # change to 1 later
    rename(year = `full_seq(year, 1)`)
  
   with_gaps <- cons |> 
     right_join(all_keys, by=c("city_id", "year")) |> 
     replace_na(list(construction = 0)) |> 
     arrange(city_id, year)
   
   return(with_gaps)
}

TidyOutput <- function(cons){
  # change this when you get the full data
  clean <- cons |> 
    select(city_id, year, construction) |> 
    mutate(construction_any = as.numeric(construction > 0))

  return(clean)
}

# There are some impurities in the new data - specifically, some entries have comments
# as city ids and single-digit years. But they should fall away with the join in
# CombineCityData.R, I think.

test <- Main()