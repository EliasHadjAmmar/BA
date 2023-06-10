ProcessConflict <- function(conflict){
  
  events <- conflict |> 
    group_by(city_id, time_point) |> 
    summarise(conflict = 1) # most basic type of measure: conflict yes/no
  
  all_keys <- events |> 
    group_by(city_id) |> 
    expand(full_seq(time_point, 1)) |> # this is not clean but left join takes care of it eventually
    rename(time_point = `full_seq(time_point, 1)`)
  
  with_gaps <- all_keys |> 
    left_join(events, by=c("city_id", "time_point")) |> 
    arrange(city_id, time_point) |> 
    replace_na(list(conflict = 0))
  
  return(with_gaps)
}