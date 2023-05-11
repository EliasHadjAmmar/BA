suppressPackageStartupMessages(library(tidyverse))

setwd("~/GitHub/BA")

source("utils/DropNACount.R")

Main <- function(){
  build_full <- read_csv("build/output/build_full.csv", show_col_types = FALSE)
  build <- build_full |> 
    select(city_id, year, terr_id, construction, treatment, extinction_of, 
           count_cities, count_diff, pop1875) |> 
    DropNACount("construction") |> 
    DropNACount("treatment")
  
  build |> write_csv("build/output/build.csv")
}

Main()


  