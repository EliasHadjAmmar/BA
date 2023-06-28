library(tidyverse) |> suppressPackageStartupMessages()
library(sf)
library(tmap)
library(haven)

setwd("~/GitHub/BA")

source("source/utils/MapUtils.R")
source("source/slides/TerrMapUtils.R")

Main <- function(){
  # Read data
  read_path <- "drive/raw/base/cities_families_1300_1918.dta"
  terrs <- read_stata(read_path)
  locs <- read_csv("drive/raw/attributes/city_locations.csv", show_col_types = F) |> 
    select(city_id, region_id, name, nat)
  locs_spatial <- st_read("drive/raw/attributes/city_borders")
  
  
  BasicTerrsMapOneYear(1700, terrs, locs_spatial)
  
  # Get snapshot of city ownership in 1500
  dat1500_sf <- GetGeodataOneYear(1500, terrs, locs_spatial)
  
  
  # Make a spatial dataset of region polygons
  terrs1500 <- unique(dat1500_sf$terr_id) |> sort() |> `names<-`("terr_id")
  
  polygons <- terrs1500 |> 
    purrr::map(\(id)(TerrIDtoUnion(id, dat1500_sf))) |> 
    bind_rows()
  
  # Bind the cities to region polygons (how about a spatial join?)
  terrs1500_sf <- bind_cols(terrs1500, polygons) |> 
    rename(terr_id = ...1) |> 
    st_as_sf()
  
  ### Create heatmap of city counts
  # Increase the bounding box of the spatial data to leave space for title
  bbox_new <- BiggerBoundingBox(terrs1500_sf, scale_top = 0.1)
  
  # Create basic map
  map1 <- tm_shape(terrs1500_sf, 
                   bbox = bbox_new)+
    tm_polygons(col="terr_id", 
                title="No. of cities") +
    tm_layout(title = "Spatial distribution of cities - Full set",
              title.size = 1.3,
              title.position = c("center", "top"),
              title.fontface = 2,
              legend.title.size = 1.3,
              legend.text.size = 1)
  
  map1
  
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

BasicTerrsMapOneYear <- function(t, terrs, locs_spatial){
  
  # Get snapshot of city ownership in year t
  dat_t_sf <- GetGeodataOneYear(t, terrs, locs_spatial)
  
  # Make a spatial dataset of region polygons
  terrs_t <- unique(dat_t_sf$terr_id) |> sort() |> `names<-`("terr_id")
  
  polygons <- terrs_t |> 
    purrr::map(\(id)(TerrIDtoUnion(id, dat_t_sf))) |> 
    bind_rows()
  
  # Bind the cities to region polygons (how about a spatial join?)
  terrs_t_sf <- bind_cols(terrs_t, polygons) |> 
    rename(terr_id = ...1) |> 
    st_as_sf()
  
  ### Create heatmap of city counts
  # Increase the bounding box of the spatial data to leave space for title
  bbox_new <- BiggerBoundingBox(terrs_t_sf, scale_top = 0.1)
  
  # Create basic map
  map1 <- tm_shape(terrs_t_sf, 
                   bbox = bbox_new)+
    tm_polygons(col="terr_id", 
                title="Territory")
  return(map1)
}




dat1500_sf <- GetGeodataOneYear(1500, terrs, locs_spatial)
BasicTerrsMapOneYear(1300, terrs, locs_spatial)
BasicTerrsMapOneYear(1600, terrs, locs_spatial)
BasicTerrsMapOneYear(1800, terrs, locs_spatial)
BasicTerrsMapOneYear(1917, terrs, locs_spatial)

Main()
