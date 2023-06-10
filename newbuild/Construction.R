# Input: list of construction events from Princes and Townspeople.
# Output: city-year panel of custom aggregates of construction.

suppressPackageStartupMessages(library(tidyverse))

setwd("~/GitHub/BA")


Main <- function(){
  
  # Note: the construction_all.csv file I got from Prof. Cantoni couldn't be read properly,
  # with values being parsed into the wrong column for 3,230 rows. I was able to fix this
  # by reading the file into an Excel sheet and exporting it back to .csv.
  construction_raw <- read_delim("build/input/construction_all_xl.csv", delim = ";", show_col_types = F)
  
  # Drop events with uncertain years (10678 obs, 39.7% of total)
  construction <- construction_raw |> 
    filter(uncertainty == 0) |> 
    filter(range == 0) |> 
    rename(year = time_point) # |> 
  # filter(newbuild == 1) # to exclude repairs
  
  together <- ConstructionTable(construction)
  
  write_csv(together, "newbuild/temp/construction_new.csv")
 
 
 
 return(0)
}

ConstructionTable <- function(construction){
  
  # Define types of buildings included in each category
  ALL_CATS <- 1:16
  STATE_CATS <- c(4, 10, 11, 12) # Administrative, Military, Palace, Castle
  PRIVATE_CATS <- c(6, 7, 9) # Economic, Mall, Private
  PUBLIC_CATS <- c(8, 13, 14, 15, 16) # Infrastructure, Social, Education, Culture, Other
  
  # Count buildings in each category
  counts_all <- CountBuildings(construction, "c_all", ALL_CATS)
  counts_state <- CountBuildings(construction, "c_state", STATE_CATS)
  counts_private <- CountBuildings(construction, "c_private", PRIVATE_CATS)
  counts_public <- CountBuildings(construction, "c_public", PUBLIC_CATS)
  
  # Join into one table and replace NAs (from missing join keys) with 0
  together <- list(counts_all, counts_state, counts_private, counts_public) |> 
    reduce(full_join) |> 
    mutate(across(everything(), \(col) replace_na(col, 0)))
  
  return(together)
}


CountBuildings <- function(construction, name, include_cats){
  
  # Count each event
  counts <- construction |> 
    filter(building %in% include_cats) |>
    group_by(city_id, year) |> 
    summarise({{name}} := n())
  
  # Expand to include years with no events
  all_keys <- counts |> 
    group_by(city_id) |> 
    expand(full_seq(year, 1)) |>
    rename(year = `full_seq(year, 1)`)
  
  with_gaps <- all_keys |> 
    left_join(counts, by=c("city_id", "year")) |> 
    arrange(city_id, year)
  
  return(with_gaps)
}


Main()