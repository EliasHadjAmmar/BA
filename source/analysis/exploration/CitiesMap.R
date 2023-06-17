library(tidyverse)
library(sf)
library(mapview)
library(rnaturalearth)
library(tmap)

setwd("~/GitHub/BA")

source("source/utils/HandleCommandArgs.R")



# Read data
t <- HandleCommandArgs(default_length = 50)
read_path <- sprintf("drive/derived/cities_data_%iy.csv", t)
build <- read_csv(read_path, show_col_types = F)
map_points <- st_read("drive/raw/attributes/city_locations")
worldmap <- ne_countries(scale = 'small', 
                         type = 'map_units',
                         continent = 'europe',
                         returnclass = 'sf')
worldmap.fix <- eu_map |>  
  st_crop(c(xmin= 3, ymin = 45, xmax = 25.5, ymax = 56))



# worldmap.fix <- st_make_valid(worldmap)
st_is_valid(worldmap, reason=T)


worldmap <- worldmap |> 
  st_transform(crs=st_crs(map_points)) #|> 
  #st_set_crs(st_crs(map_eu))
map_joined <- st_join(map_eu, map_points)

build_with_locations <- build |> 
  group_by(city_id) |> 
  summarise(lifetime_c_all = sum(c_all)) |> 
  filter(lifetime_c_all > 20) |> 
  left_join(shapefile, by="city_id") |> 
  st_as_sf()

set_st_crs <- st_crs(shapefile)
shapefile
eu_map

mapView(map_points)



tm_shape(worldmap)+
  tm_polygons()
