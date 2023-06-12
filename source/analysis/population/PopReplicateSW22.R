library(tidyverse) |> suppressPackageStartupMessages()
library(fixest) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/utils/DataPrepSuite.R")
source("source/utils/PopBuild.R")

Main <- function(){
  
  # Read data
  build <- AssemblePopBuild()
  
  # Select sample, add event study dummies, and binarise counts
  dat <- PrepareData(build,
                     max_switches = 2,
                     years_pre = 100,
                     years_post = 200,
                     binarise_switches = T)
  
  # Estimate (3) from Schoenholzer and Weese (2022), p. 12
  mod <- fixest::feols(
    population ~ i(time_to_treat, treat, ref = -100) + switches | city_id + period, 
    data = dat)

  
  # Produce replication of Fig. 5 and save as PNG
  filename <- "paper/output/regressions/SW22_replication_pop.png"
  png(filename=filename, width = 800, height = 800, pointsize = 20)
  iplot(mod)   
  dev.off()
  
  return(0)
}


PrepareData <- function(build, max_switches, years_pre, years_post, 
                        binarise_switches){
  
  # Filter out cities with too many lifetime switches
  selected <- FilterBySwitches(build, max_switches)
  
  # Identify across-period switches
  with_e_dummies <- AddEAnother(selected)
  
  # Add event study dummies
  with_leads_lags <- AddLeadsLags(with_e_dummies, years_pre, years_post)
  
  # Binarise no. of switches (control), if specified
  if (binarise_switches) { with_leads_lags <- with_leads_lags |> BinariseSwitches() }
  
  # Rearrange columns (for readability)
  clean <- with_leads_lags |> select(
      city_id, treat_time, period, terr_id, switches, e_another, treat, time_to_treat, 
      type_change, conflict, population
      )

  return(clean)
}


Main()
