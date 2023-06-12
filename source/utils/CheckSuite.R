CheckEvent <- function(clean, range, terr="B3742", city_start="1"){
  # shows a slice of the data containing cities whose id starts with `city_start`
  # and which at some point belong to `terr`, and years in `range`.

  clean <- clean |> 
    mutate(lag_switches = lag(switches)) |> 
    drop_na(lag_switches)
  
  check <- clean |> 
    filter(startsWith(as.character(city_id), city_start) & period %in% range) |> 
    group_by(city_id) |> 
    filter(terr %in% terr_id) |> 
    select(city_id, period, terr_id, switches, e_another, lag_switches)
  
  return(check)
}


CheckBadSwitches <- function(clean, n = 0){
  # prints the number of 
  
  problems <- clean |> 
    filter(lag_switches %% 2 != 0 & e_another == 0)
  
  print(sprintf("%i problematic switches", nrow(problems)))
  
  if (nrow(problems) == 0){
    return()
  }
  
  if (n > 0){
    set.seed(0)
    problems <- problems |> 
      filter(city_id %in% sample(problems$city_id, n))
  }
  
  check <- clean |> PrepareData() |>
    filter(city_id %in% problems$city_id) |> 
    filter(period %in% min(problems$period):max(problems$period)) |>
    select(city_id, period, terr_id, switches, e_another, lag_switches)
  
  return(check)
}
