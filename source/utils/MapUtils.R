RegionIDtoPolygon <- function(id, locs){
  # Returns the convex hull of the set of cities in each region
  
  region_df <- locs |> filter(region_id == id)
  nc <- st_centroid(region_df)
  ch <- st_convex_hull(st_union(nc))
  ch_as_sf <- st_sf(ch)
  return(ch_as_sf)
}


CleanNames <- function(locs){
  # Fixes spelling of city names.
  clean <- locs |> 
    mutate(name = str_replace_all(name, "ue", "ü")) |> 
    mutate(name = str_replace_all(name, "oe", "ö")) |> 
    mutate(name = str_replace(name, " Pr.", ""))
  return(clean)
}


BiggerBoundingBox <- function(map_data, scale_top){
  # From stackoverflow
  bbox_new <- st_bbox(map_data) # current bounding box
  
  xrange <- bbox_new$xmax - bbox_new$xmin # range of x values
  yrange <- bbox_new$ymax - bbox_new$ymin # range of y values
  
  # bbox_new[1] <- bbox_new[1] - (0.25 * xrange) # xmin - left
  # bbox_new[3] <- bbox_new[3] + (0.25 * xrange) # xmax - right
  # bbox_new[2] <- bbox_new[2] - (0.25 * yrange) # ymin - bottom
  bbox_new[4] <- bbox_new[4] + (scale_top * yrange) # ymax - top
  
  bbox_new <- bbox_new |>   # take the bounding box ...
    st_as_sfc() # ... and make it a sf polygon
  
  return(bbox_new)
}
