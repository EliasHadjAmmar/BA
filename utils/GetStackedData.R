GetStackedData <- function(assignment, build, extinctions, W){
  
  # create list of subexp names to map over
  subexps_list <- assignment |> select(-city_id) |> colnames()
  
  # get the dataset for each subexp and rowbind them all together
  stacked_data <- subexps_list |> 
    purrr::map(GetDataForOneSubExp, build, extinctions, W) |> 
    bind_rows()
  
  return(stacked_data)
}


GetDataForOneSubExp <- function(colname, build, extinctions, W){
  
  # obtain the terr_id corresponding to this subexp
  terr <- str_split_1(colname, "_")[2]
  
  # obtain the treat_year corresponding to this subexp
  treat_year <- extinctions |> 
    filter(terr_id == terr) |> 
    pull(death_year)
  
  # drop observations outside the experiment window
  data_in_window <- build |> 
    filter(between(year, treat_year-W, treat_year+W))
  
  # add treatment dummies and drop cities that are not in this subexp
  treat_col <- assignment |> 
    select(city_id, !!sym(colname)) |> 
    rename(TREAT = !!sym(colname))
  
  data_with_treat <- data_in_window |> 
    left_join(treat_col, by="city_id") |> 
    drop_na(TREAT)
  
  # add post dummies and interaction
  data_with_post <- data_with_treat |> 
    mutate(POST = if_else(year >= treat_year, 1, 0)) |> 
    mutate(D = if_else(TREAT * POST == 1, 1, 0))
  
  # add subexp info (for the stacked table)
  output <- data_with_post |> 
    mutate(subexp = terr, treat_year = treat_year)
  
  return(output)
}

