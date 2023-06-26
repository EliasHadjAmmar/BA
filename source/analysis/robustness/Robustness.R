#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(fixest) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")
source("source/utils/DataPrepSuite.R")
source("source/utils/PrepareBaselineData.R")
source("source/utils/PrepareWindowData.R")
source("source/utils/etableDefaults.R")

Main <- function(){
  
  # Read data
  t <- HandleCommandArgs(default_length = 50)
  read_path <- sprintf("drive/derived/cities_data_%iy.csv", t)
  build <- read_csv(read_path, show_col_types = F)
  
  # Select different samples and process data
  dat_baseline <- PrepareBaselineData(build,
                     max_switches = 2,
                     binarise_construction = T,
                     binarise_switches = T)
  
  dat_4switches <- PrepareBaselineData(build,
                     max_switches = 4,
                     binarise_construction = T,
                     binarise_switches = T)
  
  dat_allswitches <- PrepareBaselineData(build,
                     max_switches = 100,
                     binarise_construction = T,
                     binarise_switches = T)

  dat_window <- PrepareWindowData(build,
                     max_switches = 2,
                     years_post = 200,
                     binarise_construction = T,
                     binarise_switches = T)
  
  # Estimate different specifications
  mod_baseline <- fixest::feols(
    c_all ~ D + i(rule_conquest, D, ref=0) + i(rule_other, D, ref=0) + switches | city_id + period, 
    data = dat_baseline)
  
  mod_4switches <- fixest::feols(
    c_all ~ D + i(rule_conquest, D, ref=0) + i(rule_other, D, ref=0) + switches | city_id + period, 
    data = dat_4switches)
  
  mod_allswitches <- fixest::feols(
    c_all ~ D + i(rule_conquest, D, ref=0) + i(rule_other, D, ref=0) + switches | city_id + period, 
    data = dat_allswitches)
  
  mod_window <- fixest::feols(
    c_all ~ D + i(rule_conquest, D, ref=0) + i(rule_other, D, ref=0) + switches | city_id + period, 
    data = dat_window)
  
  # Produce regression table and export to LaTeX
  etableDefaults()
  
  note <- paste("Note: Table presents results of estimation equation
  \\eqref{eq:baseline}. Column (1) uses the baseline sample, Column (2) includes cities
  with up to 4 lifetime switches, Column (3) includes all cities regardless of the number
  of lifetime switches, and Column (4) uses a post-treatment indicator that is only active
  in the first 200 years after the treatment.", 
  PeriodInsert(t), "Observations are at the city-period level. Standard errors are 
  clustered at the city level.", SignifInsert(), sep = " ") |> 
    str_replace_all("\n ", "")
  
  header <- c("Baseline", "4 Switches", "All switches", "Window")
  
  tex_output <- etable(mod_baseline, mod_4switches, 
                       mod_allswitches, mod_window,
                       tex=TRUE,
                       title="Heterogeneous effects of switching: More robustness",
                       label = sprintf("tab:robustness_%iy", t),
                       postprocess.tex = PostProcessRobustness,
                       notes = note,
                       headers = header)
  
  filename <- sprintf("paper/output/regressions/robustness_%iy.tex", t)
  write(tex_output, file=filename)
  
  return(0)
}


PostProcessRobustness <- function(tex_output){
  # Post-processing the TeX string to make it neater
  # If the number of columns changes, the last two lines may show up again
  # because they specifically contain \multicolumn{5}
  tex_post <- tex_output |> 
    str_replace("Conquest \\$=\\$ 1", "Conquest") |> 
    str_replace("Other \\$=\\$ 1", "Other") |> 
    str_replace(fixed("\\multicolumn{5}{l}{\\emph{Clustered (City) standard-errors in parentheses}}\\\\"), "") |> 
    str_replace(fixed("\\multicolumn{5}{l}{\\emph{Signif. Codes: ***: 0.01, **: 0.05, *: 0.1}}\\\\"), "")
  return(tex_post)
}


Main()
