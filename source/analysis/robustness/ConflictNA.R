#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(sf)
library(tmap)
library(viridis)

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")
source("source/utils/DataPrepSuite.R")
source("source/utils/PrepareBaselineData.R")


Main <- function(){
  # Read data
  t <- HandleCommandArgs(default_length = 50)
  read_path <- sprintf("drive/derived/cities_data_%iy.csv", t)
  build <- read_csv(read_path, show_col_types = F)
  
  # Prepare data (baseline)
  dat <- PrepareBaselineData(build,
                      max_switches = 2,
                      binarise_construction = T,
                      binarise_switches = T)
  
  
  # Link obsevations to regions and obtain NA share for each region
  locs <- read_csv("drive/raw/attributes/city_locations.csv", show_col_types = F) |> 
    select(city_id, region_id, name, nat)
  
  na_shares <- GetNAShares(dat, locs)
  
  
  # Get a spatial outline (convex hull) of each region
  locs_spatial <- st_read("drive/raw/attributes/city_locations")
  
  regions <- unique(locs_spatial$region_id)
  
  polygons <- regions |> 
    purrr::map(\(id)(RegionIDtoPolygon(id, locs_spatial))) |> 
    bind_rows()
  
  # Bind the NA shares to the spatial data
  na_shares_sf <- bind_cols(na_shares, polygons) |> st_as_sf()
  
  ### Create heatmap of NA shares
  # Increase the bounding box of the spatial data to leave space for title
  bbox_new <- BiggerBoundingBox(na_shares_sf, scale_top = 0.1)
  
  map1 <- tm_shape(na_shares_sf, 
                   bbox = bbox_new)+
    tm_polygons(col="share", 
                title="Share missing",
                palette = "Reds")+
    tm_layout(title = "Sample composition after controlling for conflict",
              title.size = 1,
              title.position = c("center", "TOP"),
              title.fontface = 2,
              frame = FALSE)
  
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
    tm_text("name", size=0.8, just="bottom", ymod=0.35
    )
  
  # Save map as PNG
  filename <- sprintf("paper/output/descriptive/map_conflict_NA_%iy.png", t)
  png(filename=filename, width = 800, height = 800, pointsize = 20)
  map2
  dev.off()
}


GetNAShares <- function(dat, locs){
  # Creates a region-level table with the share of observations in each region
  # that have a missing value for conflict.
  
  locs_dat <- dat |> 
    left_join(locs, by="city_id") |> 
    mutate(conflict_na = is.na(conflict))
  
  sum_dat <- locs_dat |> 
    group_by(region_id, conflict_na) |> 
    summarise(n = n()) |> 
    mutate(share = n / sum(n)) |> 
    filter(conflict_na == TRUE)
  
  return(sum_dat)
}


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


Main()