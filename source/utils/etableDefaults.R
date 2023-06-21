etableDefaults <- function(){
  
  # uniform defaults (across all tables)
  setFixest_etable(
    se.below = FALSE,
    digits = 2,
    digits.stats = 4,
  )
  
  # set default dict
  setFixest_dict(c(city_id = "City", period = "Period",
                   c_all = "Construction", D = "Switch to another state",
                   rule_conquest = "Conquest", rule_succession = "Succession",
                   rule_other = "Other", switches = "Switching indicator",
                   conflict = "Conflict"))
}