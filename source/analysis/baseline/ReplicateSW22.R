#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(fixest) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")
source("source/utils/DataPrepSuite.R")
source("source/utils/etableDefaults.R")

Main <- function(){
  
  # Read data
  t <- HandleCommandArgs(default_length = 50)
  read_path <- sprintf("drive/derived/cities_data_%iy.csv", t)
  build <- read_csv(read_path, show_col_types = F)
  
  # Select sample, add event study dummies, and binarise counts
  dat <- PrepareData(build,
                     max_switches = 2,
                     years_pre = 100,
                     years_post = 200,
                     binarise_construction = T,
                     binarise_switches = T)
  
  # Estimate (3) from Schoenholzer and Weese (2022), p. 12
  mod_all <- fixest::feols(
    c_all ~ i(time_to_treat, treat, ref = -t) + switches | city_id + period, 
    data = dat)
  
  mod_state <- fixest::feols(
    c_state ~ i(time_to_treat, treat, ref = -t) + switches | city_id + period, 
    data = dat)
  
  mod_priv <- fixest::feols(
    c_private ~ i(time_to_treat, treat, ref = -t) + switches | city_id + period, 
    data = dat)
  
  mod_pub <- fixest::feols(
    c_public ~ i(time_to_treat, treat, ref = -t) + switches | city_id + period, 
    data = dat)
  
  # Produce regression table and export to LaTeX
  etableDefaults()
  
  note <- paste("Note: Table presents results of estimation equation
  \\eqref{eq:sw22}.", PeriodInsert(t), "Observations are at the city-period 
  level. Dependent variables are indicators that take the value 1 if 
  construction activity of the respective type was recorded. Standard errors are 
  clustered at the city level.", SignifInsert(), sep = " ") |> 
    str_replace_all("\n ", "")
  
  tex_output <- etable(mod_all, mod_state, 
                       mod_priv, mod_pub,
                       tex=TRUE,
                       title="Dynamic effects of switching",
                       label = sprintf("tab:SW22_replication_%iy", t),
                       postprocess.tex = PostProcessSW22,
                       notes = note)
  
  filename <- sprintf("paper/output/regressions/SW22_replication_%iy.tex", t)
  write(tex_output, file=filename)
  
  
  # Produce replication of Fig. 5 and save as PNG
  filename <- sprintf("paper/output/regressions/SW22_replication_%iy.png", t)
  png(filename=filename, width = 800, height = 800, pointsize = 20)
  iplot(mod_all)
  dev.off()
  
  return(0)
}


PrepareData <- function(build, max_switches, years_pre, years_post, 
                        binarise_construction, binarise_switches){
  
  # Filter out cities with too many lifetime switches
  selected <- FilterBySwitches(build, max_switches)
  
  # Identify across-period switches
  with_e_dummies <- AddEAnother(selected)
  
  # Add event study dummies
  with_leads_lags <- AddLeadsLags(with_e_dummies, years_pre, years_post)
  
  # Binarise construction outcomes, if specified
  if (binarise_construction) { with_leads_lags <- with_leads_lags |> BinariseOutcomes() }
  
  # Binarise no. of switches (control), if specified
  if (binarise_switches) { with_leads_lags <- with_leads_lags |> BinariseSwitches() }
  
  # Rearrange columns (for readability)
  clean <- with_leads_lags |> select(
      city_id, treat_time, period, terr_id, switches, e_another, treat, time_to_treat, 
      conflict, c_all, c_state, c_private, c_public
      )

  return(clean)
}


PostProcessSW22 <- function(tex_output){
  # Post-processing the TeX string to make it neater
  # If the number of columns changes, the last two lines may show up again
  # because they specifically contain \multicolumn{5}
  tex_post <- tex_output |> 
    str_replace(fixed("\\multicolumn{5}{l}{\\emph{Clustered (City) standard-errors in parentheses}}\\\\"), "") |> 
    str_replace(fixed("\\multicolumn{5}{l}{\\emph{Signif. Codes: ***: 0.01, **: 0.05, *: 0.1}}\\\\"), "")
  return(tex_post)
}


Main()
