ProcessConstruction <- function(construction){
  
  # Define types of buildings included in each category
  ALL_CATS <- 1:16
  STATE_CATS <- c(4, 10, 11, 12) # Administrative, Military, Palace, Castle
  PRIVATE_CATS <- c(6, 7, 9) # Economic, Mall, Private
  PUBLIC_CATS <- c(8, 13, 14, 15, 16) # Infrastructure, Social, Education, Culture, Other
  
  # Count buildings in each category
  counts_all <- CountBuildings(construction, "c_all", ALL_CATS)
  counts_state <- CountBuildings(construction, "c_state", STATE_CATS)
  counts_private <- CountBuildings(construction, "c_private", PRIVATE_CATS)
  counts_public <- CountBuildings(construction, "c_public", PUBLIC_CATS)
  
  # Join into one table and replace NAs (from missing join keys) with 0
  together <- list(counts_all, counts_state, counts_private, counts_public) |> 
    reduce(full_join) |> 
    mutate(across(everything(), \(col) replace_na(col, 0)))
  
  return(together)
}


CountBuildings <- function(construction, name, include_cats){
  
  # Count each event
  counts <- construction |> 
    filter(building %in% include_cats) |>
    group_by(city_id, time_point) |> 
    summarise({{name}} := n())
  
  # Expand to include years with no events
  all_keys <- counts |> 
    group_by(city_id) |> 
    expand(full_seq(time_point, 1)) |> # this is not clean but left join takes care of it eventually
    rename(time_point = `full_seq(time_point, 1)`)
  
  with_gaps <- all_keys |> 
    left_join(counts, by=c("city_id", "time_point")) |> 
    arrange(city_id, time_point)
  
  return(with_gaps)
}
