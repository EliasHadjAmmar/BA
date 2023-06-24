#!/usr/bin/env Rscript --vanilla

library(tidyverse) |> suppressPackageStartupMessages()
library(sf) |> suppressPackageStartupMessages()
library(tmap) |> suppressPackageStartupMessages()

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")
source("source/utils/DataPrepSuite.R")
source("source/utils/PrepareBaselineData.R")
source("source/utils/MapUtils.R")

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
  
  na_shares <- GetNAShares(dat, locs) |> 
    mutate(remaining = 1-share)
  
  
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
    tm_polygons(col="remaining", 
                title="Share remaining",
                palette = "Reds",
                legend.reverse = TRUE) +
    tm_layout(title = "Sample composition after controlling for conflict",
              title.size = 1.3,
              title.position = c("center", "top"),
              title.fontface = 2,
              legend.title.size = 1.3,
              legend.text.size = 1)
  
  
  # Add an unlabelled dot for each city in the build
  allpoints_sf <- locs_spatial |> 
    filter(city_id %in% unique(dat$city_id))
  
  map2 <- map1 + 
    tm_shape(allpoints_sf)+
    tm_dots(alpha = 0.3)
  
  # Add some city names as reference points
  citynames <- c("Muenchen", "Berlin", "Koenigsberg Pr.", "Koeln", 
                 "Hannover", "Breslau", "Wuerzburg", "Dresden",
                 "Kiel", "Stettin", "Kassel")
  
  points_sf <- locs_spatial |> 
    filter(name %in% citynames) |> 
    CleanNames()
  
  map3 <- map2 +
    tm_shape(points_sf)+
    tm_dots()+
    tm_text("name", size=1, just="bottom", ymod=0.35
    )
  
  # Save map as PNG
  filename <- sprintf("paper/output/descriptive/map_conflict_NA_%iy.png", t)
  tmap_save(map3, filename)
  
  return(0)
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


Main()