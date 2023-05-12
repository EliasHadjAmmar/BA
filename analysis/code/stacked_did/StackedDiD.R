# The point of this script is to add the necessary dummies to the build for regression.
# If we start out with a simple stacked DiD, then that's one TREAT dummy for each d,
# and one POST dummy for each d.

# How do I get that?

# I think joining to the build is messy, and it may not even work, because the IU slides
# say that in a stacked design one city may show up multiple times.

# Alternative: get the data set for each sub-experiment, and then bind_rows() them.


library(tidyverse) |> suppressPackageStartupMessages()
library(fixest) |> suppressPackageStartupMessages()

source("utils/GetStackedData.R")

setwd("~/GitHub/BA")

Main <- function(){
  build <- read_csv("analysis/input/build.csv", show_col_types = F)
  extinctions <- read_csv("analysis/input/extinctions.csv", show_col_types = F)
  assignment <- read_csv("analysis/temp/assignment.csv", show_col_types = F)

  W <- 10
  
  stacked_data <- GetStackedData(assignment, build, extinctions, W)

  mod <- fixest::feols(construction ~ D | city_id^subexp + year^subexp, stacked_data)
  
  setFixest_dict(c(city_id = "City", year = "Year", subexp = "Extinction",
                   construction = "Construction events", D = "TREAT x POST"))
  
  tex_output <- etable(mod, tex = TRUE)
  write(tex_output, file="analysis/output/tables/stacked_did.tex")
}


Main()
