BaselineSample <- function(build){

  # Drop cities that were treated more than once from the sample
  max1treat <- build |>  
    group_by(city_id) |> 
    mutate(treatments_total = sum(treatment)) |> 
    filter(treatments_total < 2)
  
  n_dropped <- nrow(build)-nrow(max1treat)
  cities_dropped <- n_distinct(build$city_id)-n_distinct(max1treat$city_id)
  
  print(sprintf("Dropped %d observations with multiple treatments (%d cities)", 
                n_dropped, cities_dropped))
  
  # Remove superfluous columns
  clean <- max1treat |> 
    select(year, city_id, construction, treatment, count_cities, count_diff) |> 
    as.data.frame()
  
  return(clean)
}