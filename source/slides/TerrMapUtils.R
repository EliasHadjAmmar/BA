TerrIDtoUnion <- function(id, locs_spatial){
  locs_spatial |> 
    filter(terr_id == id) |> 
    st_union() |> 
    st_sf()
}


GetGeodataOneYear <- function(t, terrs, locs_spatial){
  terrs_oneyear <- terrs |> 
    filter(year == t) |> 
    mutate(terr_id = if_else(city_status != 0, "00_FREE", terr_id)) |> 
    select(city_id, terr_id, city_status) |> 
    left_join(locs_spatial, by="city_id") |> 
    st_as_sf()
  
  return(terrs_oneyear)
}