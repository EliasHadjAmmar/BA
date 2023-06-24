GetBuildLevelInfo <- function(build){
  build |> 
    summarise(
      min_year = min(period),
      max_year = max(period),
      avg_year = mean(period),
      med_year = median(period),
      n_cities = n_distinct(city_id),
      n_terrs = n_distinct(terr_id)
    )
}

GetCityLevelInfo <- function(build){
  build |> 
    group_by(city_id) |> 
    summarise(
      duration = max(period) - min(period),
      switches = sum(switches),
      conflict = sum(conflict),
      across(starts_with("c_"), sum)) |> 
    summarise(
      across(-c(city_id), \(col)(mean(col, na.rm=T)))
    )
}

GetRegionLevelInfo <- function(build, locs){
  # Link obsevations to regions
  locs_dat <- build |> 
    left_join(locs, by="city_id")
  
  # Compute stats
  stats <- locs_dat |> 
    group_by(region_id) |> 
    summarise(
      n_cities = n_distinct(city_id),
      n_terrs = n_distinct(terr_id)) |> 
    summarise(
      across(-c(region_id), mean)
    )
  return(stats)
}