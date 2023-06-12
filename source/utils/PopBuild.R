AssemblePopBuild <- function(){

  # Working directory must be BA for these imports to work
  build100 <- read_csv("drive/derived/cities_data_100y.csv", show_col_types = F)
  build50 <- read_csv("drive/derived/cities_data_50y.csv", show_col_types = F)
  
  city_pop <- read_csv("drive/derived/population.csv", show_col_types = F) |> 
    rename(period = year) |> 
    select(city_id, period, population)
  
  # Time structure of the Bairoch (1988) data consists of 50-year and 100-year periods
  first_half <- build100 |> filter(period <= 1600)
  second_half <- build50 |> filter(period >= 1700)
  
  # Put two halves together and join with population data
  full_build <- first_half |> 
    bind_rows(second_half) |> 
    arrange(city_id, period) |> # not strictly necessary
    left_join(city_pop, by=c("city_id", "period"))
  
  # 
  
}
