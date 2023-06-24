#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(sf)
library(tmap)

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")
source("source/utils/MapUtils.R")

Main <- function(){
  # Read data
  t <- HandleCommandArgs(default_length = 1)
  read_path <- sprintf("drive/derived/cities_data_%iy.csv", t)
  build <- read_csv(read_path, show_col_types = F)
  
  raw_build <- read_csv("drive/derived/cities_switches.csv",
                        show_col_types = F) |> 
    rename(
      period = year,
      switches = switch) |> 
    mutate(conflict = 0) # just for convenience
  
  
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
  
  
  dsets <- list("build" = build, "raw" = raw_build)
  dsets |> map(GetBuildLevelInfo)
  dsets |> map(GetCityLevelInfo)
}


## Region level

locs <- read_csv("drive/raw/attributes/city_locations.csv", show_col_types = F) |> 
  select(city_id, region_id, name, nat)
locs_spatial <- st_read("drive/raw/attributes/city_locations")

GetRegionLevelInfo <- function(build, locs){
  # Link obsevations to regions
  locs_dat <- build |> 
    left_join(locs, by="city_id")
  
  stats <- locs_dat |> 
    group_by(region_id) |> 
    summarise(
      n_cities = n_distinct(city_id),
      n_terrs = n_distinct(terr_id)
    )
  
  return(stats)
}

dsets |> map(GetRegionLevelInfo, locs)

region_stats <- GetRegionLevelInfo(build, locs)

MapRegionCityCounts <- function(region_stats, locs_spatial){
  # Get a spatial outline (convex hull) of each region
  locs_spatial <- st_read("drive/raw/attributes/city_locations")
  
  regions <- unique(locs_spatial$region_id)
  
  polygons <- regions |> 
    purrr::map(\(id)(RegionIDtoPolygon(id, locs_spatial))) |> 
    bind_rows()
  
  # Bind the city counts to the spatial data
  stats_sf <- bind_cols(region_stats, polygons) |> st_as_sf()
  
  ### Create heatmap of city counts
  # Increase the bounding box of the spatial data to leave space for title
  bbox_new <- BiggerBoundingBox(stats_sf, scale_top = 0.1)
  
  map1 <- tm_shape(stats_sf, 
                   bbox = bbox_new)+
    tm_polygons(col="n_cities", 
                title="No. of cities",
                palette = "Blues",
                legend.reverse = TRUE) +
    tm_layout(title = "Spatial distribution of cities",
              title.size = 1.3,
              title.position = c("center", "top"),
              title.fontface = 2,
              legend.title.size = 1.3,
              legend.text.size = 1)
  
  # Add some city names as reference points
  citynames <- c("Muenchen", "Berlin", "Koenigsberg Pr.", "Koeln", 
                 "Hannover", "Breslau", "Wuerzburg", "Dresden",
                 "Kiel", "Stettin", "Kassel")
  
  points_sf <- locs_spatial |> 
    filter(name %in% citynames) |> 
    CleanNames()
  
  map2 <- map1 +
    tm_shape(points_sf)+
    tm_dots()+
    tm_text("name", size=1, 
            just="bottom", ymod=0.35,
            fontface = 1)
  return(map2)
  
}

map_basic <- MapRegionCityCounts(region_stats, locs_spatial)

# add unlabelled dots for other cities
allpoints_sf <- locs_spatial |> 
  filter(city_id %in% unique(build$city_id))

map3 <- map_basic + 
  tm_shape(allpoints_sf)+
  tm_dots(alpha = 0.5)


