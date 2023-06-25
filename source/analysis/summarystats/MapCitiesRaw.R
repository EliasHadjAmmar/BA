library(tidyverse) |> suppressPackageStartupMessages()
library(sf)
library(tmap)

setwd("~/GitHub/BA")

source("source/utils/MapUtils.R")

Main <- function(){
  # Read data
  read_path <- "drive/derived/cities_switches.csv"
  build <- read_csv(read_path, show_col_types = F)
  locs <- read_csv("drive/raw/attributes/city_locations.csv", show_col_types = F) |> 
    select(city_id, region_id, name, nat)
  locs_spatial <- st_read("drive/raw/attributes/city_borders")
  
  # Compute no. of cities in each region
  region_stats <- GetRegionLevelInfo(build, locs) |> 
    arrange(region_id)
  
  # Make a spatial dataset of region polygons
  regions <- unique(locs_spatial$region_id) |> sort()
  
  polygons <- regions |> 
    purrr::map(\(id)(RegionIDtoUnion(id, locs_spatial))) |> 
    bind_rows()
  
  # Bind the city counts to the spatial region data
  stats_sf <- bind_cols(region_stats, polygons) |> st_as_sf()
  
  ### Create heatmap of city counts
  # Increase the bounding box of the spatial data to leave space for title
  bbox_new <- BiggerBoundingBox(stats_sf, scale_top = 0.1)
  
  # Increase the bounding box of the spatial data to leave space for title
  bbox_new <- BiggerBoundingBox(stats_sf, scale_top = 0.1)
  
  # Define breaks myself (so that I can use the same ones in MapAllCities.R)
  my.breaks <- c(0, 31, 61, 91, 121, 151, 200)
  
  # Create basic map
  map1 <- tm_shape(stats_sf, 
                   bbox = bbox_new)+
    tm_polygons(col="n_cities", 
                title="No. of cities",
                palette = "Greens",
                breaks = my.breaks,
                legend.reverse = TRUE) +
    tm_layout(title = "Spatial distribution of cities - Full set",
              title.size = 1.3,
              title.position = c("center", "top"),
              title.fontface = 2,
              legend.title.size = 1.3,
              legend.text.size = 1)
  
  # Add an unlabelled dot for each city in the build
  allpoints_sf <- locs_spatial |> 
    filter(city_id %in% unique(build$city_id))
  
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
    tm_text("name", size=1, 
            just="bottom", 
            ymod=0.35,
            fontface = 2)
  
  # Save map as PNG
  filename <- "paper/output/descriptive/map_cities_raw.png"
  tmap_save(map3, filename)
  
  return(0)
}


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

Main()
