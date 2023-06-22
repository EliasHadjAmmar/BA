#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(vtable) |> suppressPackageStartupMessages()
library(gtsummary)

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")

# Read data
t <- HandleCommandArgs(default_length = 50)
read_path <- sprintf("drive/derived/cities_data_%iy.csv", t)
build <- read_csv(read_path, show_col_types = F)

vtable::sumtable(build)
gtsummary::tbl_summary(build)
