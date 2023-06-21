FilterBySwitches <- function(build, max_switches){
  clean <- build |> 
    group_by(city_id) |> 
    mutate(lifetime_switches = sum(switches)) |> 
    filter(lifetime_switches <= max_switches)
  
  return(clean)
}


AddEAnother <- function(build){
  with_e_dummies <- build |> 
    group_by(city_id) |> 
    mutate(e_another = if_else(terr_id != lag(terr_id), 1, 0)) |> # lag, not lead
    drop_na(e_another)
  
  return(with_e_dummies)
}


AddLeadsLags <- function(with_e_dummies, years_pre, years_post){
  
  # Get treatment period(s) for each city
  timing <- with_e_dummies |> 
    filter(e_another == 1) |> 
    mutate(treat_time = period) |> 
    select(city_id, treat_time)
  
  # Join treatment periods to data and add TREAT
  with_timing <- with_e_dummies |> 
    left_join(timing, by="city_id", multiple = "all") |> # duplicate cities with multiple switches
    arrange(city_id, treat_time, period) |> 
    mutate(key = sprintf("id%i_t%i_s%i", city_id, period, treat_time)) |> # unique keys just in case
    mutate(treat = ifelse(is.na(treat_time), 0, 1)) # add TREAT dummy
  
  # Create time-to-treat variable
  with_leads_lags <- with_timing |> 
    mutate(time_to_treat = ifelse(treat == 1, period-treat_time, 0)) |> # create time-to-treat
    mutate(treat = ifelse(time_to_treat %in% -years_pre:years_post, treat, 0)) |> # set treat=0 if not in window
    mutate(time_to_treat = ifelse(treat==0, 0, time_to_treat)) # set redundant times-to-treat vals =0
  
  return(with_leads_lags)
}


AddTreatXPost <- function(with_e_dummies){
  
  # Get treatment period(s) for each city
  timing <- with_e_dummies |> 
    filter(e_another == 1) |> 
    mutate(treat_time = period) |> 
    select(city_id, treat_time)
  
  # Join treatment periods to data and add D (TREAT x POST)
  with_D <- with_e_dummies |> 
    left_join(timing, by="city_id", multiple = "all") |> # duplicate cities with multiple switches
    arrange(city_id, treat_time, period) |> 
    mutate(key = sprintf("id%i_t%i_s%i", city_id, period, treat_time)) |> # unique keys just in case
    mutate(D = case_when(
      is.na(treat_time) ~ 0,
      period < treat_time ~ 0,
      period >= treat_time ~ 1
    ))
  
  return(with_D)
}


ProcessTypeChange <- function(with_dummies){
  # `type_change` currently encodes how `terr_id` came into power.
  # `type_change` *should* encode what happened at `treat_time`.
  # Right now it varies on the city-period level.
  # I want it to vary on the city-treat_time (city-copy) level.

  treat_types <- with_dummies |>
    filter(period == treat_time) |>
    select(city_id, treat_time, rule_conquest, rule_succession, rule_other)

  with_types <- with_dummies |>
    select(-rule_conquest, -rule_succession, -rule_other) |> 
    left_join(treat_types, by=c("city_id", "treat_time"))
  
  # I may need to replace NAs in `treat_type` with 0, or anything really.
  # It doesn't matter because if `treat_type` is NA then `treat` = 0 and
  # therefore the interaction term drops out. It's just a question of 
  # whether fixest gets that.
  
  # I want to try replacing it with 1 - "Other" - because it seems to think
  # that NA is a separate thing you can use as a reference category.
  
  with_types <- with_types |> 
    replace_na(list(rule_conquest = 0, rule_succession = 0, rule_other = 0))
  
  return(with_types)
}


BinariseOutcomes <- function(build){
  clean <- build |> 
    mutate(across(starts_with("c_"), \(c) if_else(c > 0, 1, 0)))
  return(clean)
}

BinariseSwitches <- function(build){
  clean <- build |> 
    mutate(switches = if_else(switches > 0, 1, 0))
  return(clean)
}
