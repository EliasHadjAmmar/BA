# Inputs: extinction list from rulers, and extinction list from territories.
# Output: the final extinction list that gets turned into sub-experiments.

library(tidyverse)
setwd("~/GitHub/BA")

Main <- function(){
  ext_rulers <- read_csv("build/temp/last_rulers.csv")
  ext_terrs <- read_csv("build/temp/ext_terrs.csv")
  
  final_list <- CombineBoth(ext_rulers, ext_terrs)
  
  final_list %>% write.csv("build/output/extinctions.csv")
}

CombineBoth <- function(ext_rulers, ext_terrs){
  # Empty for now
  return(ext_rulers)
}

Main()