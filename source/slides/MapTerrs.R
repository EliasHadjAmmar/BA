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
  
  # Create map
  CleanTerrsMap(1700, terrs, locs_spatial)
  
  # Create and save maps at different years
  time_points <- c(1300, 1500, 1800, 1917)
  
  for (t in time_points) {
    map1 <- CleanTerrsMap(t, terrs, locs_spatial)
    filename <- sprintf("paper/output/slides/map_terrs_%i.png", t)
    tmap_save(map1, filename)
  }
  
  return(0)
}


BasicTerrsMap <- function(t, terrs, locs_spatial){
  
  terrs_oneyear <- GetGeodataOneYear(t, terrs, locs_spatial)
  terrs_t_sf <- GetPolygonData(terrs_oneyear)
  
  # INSERT SINGLETON HANDLING STEPS HERE
  # 
  # 
  
  ### Create heatmap of city counts
  # Increase the bounding box of the spatial data to leave space for title
  bbox_new <- BiggerBoundingBox(terrs_t_sf, scale_top = 0.1)
  
  # Create basic map
  map1 <- tm_shape(terrs_t_sf, 
                   bbox = bbox_new)+
    tm_polygons(col="terr_id", 
                title="Territory")+
    tm_layout(title = sprintf("Territories in %i", t),
              title.size = 1.3,
              title.position = c("center", "top"),
              title.fontface = 2,
              legend.show = F)
  return(map1)
}


CleanTerrsMap <- function(t, terrs, locs_spatial){
  
  # Create basic map
  map1 <- BasicTerrsMap(t, terrs, locs_spatial)
  
  # Add some city names as reference points (if they exist at t)
  citynames <- c("Muenchen", "Berlin", "Koenigsberg Pr.", "Koeln", 
                 "Hannover", "Breslau", "Wuerzburg", "Dresden",
                 "Kiel", "Stettin", "Kassel")
  
  points_sf <- GetGeodataOneYear(t, terrs, locs_spatial) |> 
    filter(name %in% citynames) |> 
    CleanNames()
  
  map2 <- map1 +
    tm_shape(points_sf)+
    tm_dots()+
    tm_text("name", size=1, 
            just="bottom", 
            ymod=0.35,
            fontface = 2)
  
  return(map2)
}




Main()
