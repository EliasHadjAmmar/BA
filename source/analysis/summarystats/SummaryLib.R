GetBuildLevelInfo <- function(build){
  build |> 
    summarise(
      min_year = min(period),
      max_year = max(period),
      med_year = median(period),
      n_cities = n_distinct(city_id),
      n_terrs = n_distinct(terr_id),
      n_obs = n()
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
      across(-c(city_id), list("mean" = \(col)(mean(col, na.rm=T)), 
                               "median" = \(col)(median(col, na.rm=T))
                               )
             )
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

UnifyStats <- function(stats, names_col){
  stats |> 
    bind_rows() |> 
    add_column(list("build" = names_col), .after = 0) |> 
    add_column(c(1, 50, 50), .after = 1)
}
