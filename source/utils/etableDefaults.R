etableDefaults <- function(){
  
  # uniform defaults (across all tables)
  setFixest_etable(
    se.below = TRUE,
    digits = 2,
    digits.stats = 4
  )
  
  # set default dict
  setFixest_dict(c(city_id = "City", period = "Period",
                   c_all = "All construction", 
                   c_state = "State",
                   c_private = "Private",
                   c_public = "Public goods",
                   D = "Switch to another state",
                   rule_conquest = "Conquest", rule_succession = "Succession",
                   rule_other = "Other", switches = "Switching indicator",
                   conflict = "Conflict",
                   time_to_treat = "Period",
                   treat = "Treat"))
}

PeriodInsert <- function(t){
  # Utility to insert in notes below regression tables
  period_insert <- sprintf("Yearly data was aggregated into periods of %i years.", t)
  if (t == 1) { period_insert <- "Time periods have a length of 1 year." }
  return(period_insert)
}

SignifInsert <- function(){
  # Utility to insert in notes below regression tables
  insert <- "*, **, and *** denote significance on the 10 percent, 5 percent, and 1 percent 
  level, respectively."
  return(insert)
}
