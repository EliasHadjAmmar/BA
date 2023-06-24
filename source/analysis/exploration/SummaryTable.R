#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(vtable) |> suppressPackageStartupMessages()
library(gtsummary)
library(panelr)

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")

# Read data
t <- HandleCommandArgs(default_length = 50)
read_path <- sprintf("drive/derived/cities_data_%iy.csv", t)
build <- read_csv(read_path, show_col_types = F)

# Convert switch type dummies into one categorial variable
dat <- build |> 
  pivot_longer(cols = c("rule_conquest", "rule_succession", "rule_other"),
               names_prefix = "rule_") |> 
  filter(value == 1) |> 
  select(-value) |> 
  rename(switch_type = name) |> 
  mutate(switch_type = as_factor(switch_type))

# Join städtebuch regions to build
locs <- read_csv("drive/raw/attributes/city_locations.csv", show_col_types = F) |> 
  select(city_id, region_id, name, nat)

locs_dat <- dat |> left_join(locs, by="city_id") |> 
  mutate(across(c(region_id, terr_id, city_id), as_factor))


table2 <- tbl_summary(
    locs_dat,
    missing = "no", # don't list missing data separately,
    include = c(),
    statistic = list(
      region_id ~ "{n} / {N} ({p}%)"
    )
  ) 

#|> 
  add_n() %>% # add column with total number of non-missing observations
  modify_header(label = "**Variable**") %>% # update the column header
  bold_labels()

table2
