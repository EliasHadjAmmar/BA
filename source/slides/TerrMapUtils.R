TerrIDtoUnion <- function(id, locs_spatial){
  locs_spatial |> 
    filter(terr_id == id) |> 
    st_union() |> 
    st_sf()
}


GetPolygonData<- function(terrs_oneyear){
  
  # Make a spatial dataset of region polygons
  terrs_t <- unique(terrs_oneyear$terr_id) |> sort() |> `names<-`("terr_id")
  
  polygons <- terrs_t |> 
    purrr::map(\(id)(TerrIDtoUnion(id, terrs_oneyear))) |> 
    bind_rows()
  
  # Bind the cities to region polygons
  terrs_t_sf <- bind_cols(terrs_t, polygons) |> 
    rename(terr_id = ...1)
  
  # Add info on city counts (to later recode singleton terrs)
  with_city_counts <- terrs_oneyear |> 
    group_by(terr_id) |> 
    summarise(n_cities = n_distinct(city_id)) |> 
    left_join(terrs_t_sf, by="terr_id") |> 
    st_as_sf()
  
  return(with_city_counts)
}


GetGeodataOneYear <- function(t, terrs, locs_spatial){
  terrs_oneyear <- terrs |> 
    filter(year == t) |> 
    select(city_id, terr_id) |> 
    left_join(locs_spatial, by="city_id") |> 
    st_as_sf()
  
  return(terrs_oneyear)
}
