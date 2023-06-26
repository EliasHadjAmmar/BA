#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(fixest) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")
source("source/utils/DataPrepSuite.R")
source("source/utils/PrepareBaselineData.R")
source("source/utils/etableDefaults.R")

Main <- function(){
  
  # Read data
  t <- HandleCommandArgs(default_length = 50)
  read_path <- sprintf("drive/derived/cities_data_%iy.csv", t)
  build <- read_csv(read_path, show_col_types = F)
  
  # Select sample and process data (exact steps documented below)
  dat <- PrepareBaselineData(build,
                     max_switches = 2,
                     binarise_construction = T,
                     binarise_switches = T)
  
  dat_noconflict <- dat |> 
    drop_na(conflict)
  
  # Estimate Equation (2) with different sets of controls
  mod_baseline <- fixest::feols(
    c_all ~ D + i(rule_conquest, D, ref=0) + i(rule_other, D, ref=0) + switches | city_id + period, 
    data = dat)
  
  mod_noswitches <- fixest::feols( # neither
    c_all ~ D + i(rule_conquest, D, ref=0) + i(rule_other, D, ref=0) | city_id + period, 
    data = dat)
  
  mod_conflict <- fixest::feols( # both
    c_all ~ D + i(rule_conquest, D, ref=0) + i(rule_other, D, ref=0) + switches + conflict | city_id + period, 
    data = dat)
  
  mod_conf_nosw <- fixest::feols( # only conflict
    c_all ~ D + i(rule_conquest, D, ref=0) + i(rule_other, D, ref=0) + conflict | city_id + period, 
    data = dat)
  
  mod_conf_check <- fixest::feols(
    c_all ~ D + i(rule_conquest, D, ref=0) + i(rule_other, D, ref=0) + switches | city_id + period, 
    data = dat_noconflict)
  
  # Produce regression table and export to LaTeX
  etableDefaults()
  
  note <- paste("Note: Table presents results of estimation equation
  \\eqref{eq:baseline} but using different control variables. Columns (3)-(5) drop
  observations with missing data on conflict incidents from the sample.", PeriodInsert(t), 
  "Observations are at the city-period level. The dependent variable is an 
  indicator that takes the value 1 if any construction activity was recorded. 
  Standard errors are clustered at the city level.", SignifInsert(), sep = " ") |> 
    str_replace_all("\n ", "")
  
  tex_output <- etable(mod_baseline, mod_noswitches,
                       mod_conflict, mod_conf_nosw,
                       mod_conf_check,
                       tex=TRUE,
                       title="Heterogeneous effects of switching: Robustness",
                       label = sprintf("tab:controls_%iy", t),
                       postprocess.tex = PostProcessBaseline,
                       notes = note
                       )
  
  filename <- sprintf("paper/output/regressions/controls_%iy.tex", t)
  write(tex_output, file=filename)
  
  return(0)
}


PostProcessBaseline <- function(tex_output){
  # Post-processing the TeX string to make it neater
  # If the number of columns changes, the last two lines may show up again
  # because they specifically contain \multicolumn{5}
  tex_post <- tex_output |> 
    str_replace("Conquest \\$=\\$ 1", "Conquest") |> 
    str_replace("Other \\$=\\$ 1", "Other") |> 
    str_replace(fixed("\\multicolumn{6}{l}{\\emph{Clustered (City) standard-errors in parentheses}}\\\\"), "") |> 
    str_replace(fixed("\\multicolumn{6}{l}{\\emph{Signif. Codes: ***: 0.01, **: 0.05, *: 0.1}}\\\\"), "")
  return(tex_post)
}


Main()
