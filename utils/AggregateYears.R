AggregateYears <- function(build, spacing){
  # The steps are:
  # - map years to periods.
  # - group yearly observations by period and map yearly values to period values.
  #   - for construction, use the group mean (better than sum bc of truncated periods!).
  #   - for treatment, use the group maximum.
  # After that, you can compute time_to_treat just like before, with years -> periods.
  aggregated <- build |> 
    mutate(period = year - year %% spacing) |>
    group_by(city_id, period) |> 
    summarise(
      construction = mean(construction, na.rm = T),
      treatment = max(treatment)
    )
  
  return(aggregated)
}

AggregateStacked <- function(stacked_data, spacing){
  aggregated <- stacked_data |> 
    mutate(
      period = year - year %% spacing, 
      treat_period = treat_year - treat_year %% spacing) |> 
    group_by(city_id, period, subexp) |> 
    mutate(construction = mean(construction, na.rm = T)) |> 
    select(city_id, period, construction, TREAT, subexp, treat_period) |> 
    distinct()
  
  return(aggregated)
}
