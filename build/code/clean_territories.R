library(tidyverse)

setwd("~/GitHub/BA/build")

main <- function() {
    territories <- read.csv("input/territories.csv")
    territories %>% write.csv("output/clean_data.csv")
}

main()

