AggregateYears <- function(build, intervals){
  # The steps are:
  # - map years to periods.
  # - group yearly observations by period and map yearly values to period values.
  #   - for construction, use the group mean (better than sum bc of truncated periods!).
  #   - for treatment, use the group maximum.
  # After that, you can compute time_to_treat just like before, with years -> periods.
  aggregated <- build |> 
    mutate(period = year - year %% intervals) |>
    group_by(city_id, period) |> 
    summarise(
      construction = mean(construction, na.rm = T),
      treatment = max(treatment)
    )
  
  return(aggregated)
}