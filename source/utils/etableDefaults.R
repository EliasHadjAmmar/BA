etableDefaults <- function(){
  
  # uniform defaults (across all tables)
  setFixest_etable(
    se.below = FALSE,
    digits = 2,
    digits.stats = 4,
  )
  
  # set default dict
  setFixest_dict(c(city_id = "City", period = "Period",
                   c_all = "Construction", D = "Switching to another state",
                   treat_type = "Selection", switches = "Switching indicator"),
                 conflict = "Conflict")
  }