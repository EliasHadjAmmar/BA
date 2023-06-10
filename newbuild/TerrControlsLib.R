TerrControls <- function(cities_data){
  city_counts <- cities_data |> 
    group_by(terr_id, period) |> 
    summarise(cities_total = n())
  
  city_diffs <- city_counts |> 
    arrange(terr_id, period) |> 
    group_by(terr_id) |> 
    mutate(cities_gained = cities_total - lag(cities_total))
  
  return(city_diffs)
}

