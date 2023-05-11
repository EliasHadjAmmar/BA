BaselineSample <- function(build){
  
  # Drop observations with essential variables missing
  clean <- build |> 
    DropNACount("year") |>
    DropNACount("city_id") |> 
    DropNACount("construction") |> 
    DropNACount("treatment")
  
  # Drop cities that were treated more than once from the sample
  max1treat <- clean |>  
    group_by(city_id) |> 
    mutate(treatments_total = sum(treatment)) |> 
    filter(treatments_total < 2)
  
  n_dropped <- nrow(clean)-nrow(max1treat)
  cities_dropped <- n_distinct(clean$city_id)-n_distinct(max1treat$city_id)
  
  print(sprintf("Dropped %d observations with multiple treatments (%d cities)", 
                n_dropped, cities_dropped))
  
  # Remove superfluous columns
  clean <- max1treat |> 
    select(year, city_id, construction, treatment) |> 
    as.data.frame()
  
  return(clean)
}


DropNACount <- function(dat, varname){
  # Drops observations with the specified variable missing, 
  # and prints the number of observations that were dropped
  clean <- dat |> 
    drop_na(!!sym(varname))
  
  n_dropped <- nrow(dat)-nrow(clean)
  print(sprintf("Dropped %d observations with missing %s", n_dropped, varname))
  return(clean)
}