#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(fixest) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")
source("source/utils/PrepareData.R")

t <- HandleCommandArgs(default_length = 50)
read_path <- sprintf("drive/derived/cities_data_%iy.csv", t)
build <- read_csv(read_path, show_col_types = F)

selected <- FilterBySwitches(build, max_switches = 2)
with_e_dummies <- AddEAnother(selected)
with_leads_lags <- AddLeadsLags(with_e_dummies, years_pre = 100, years_post = 200)
binarised <- with_leads_lags |> BinariseSwitching() |> BinariseOutcomes()

# Replicate their analysis
# for t=50, outcome c_all, max_switches=2 and binarisation it looks good!!!

mod <- fixest::feols(
  c_all ~ i(time_to_treat, treat, ref = -t) + switches_bin | city_id + period, 
  data = binarised)

iplot(mod)

# Effect disappears if you control for conflict -> state power = less predation?

mod_conflict <- fixest::feols(
  c_all ~ i(time_to_treat, treat, ref = -t) + switches_bin + conflict | city_id + period, 
  data = binarised)

iplot(mod_conflict)

