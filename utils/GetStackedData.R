GetStackedData <- function(assignment, build, extinctions, W){
  
  # create list of individual subexp assignments to map over
  subexps_list <- assignment |> 
    select(-city_id)
  
  # get the observations for each subexp and rowbind them all together
  stacked_data <- subexps_list |> 
    purrr::imap(\(col, name) GetDataForOneSubExp(col, name, build, extinctions, W)) |> 
    bind_rows()
  
  return(stacked_data)
}

# subexps_list |> imap(GetDforOne, build)
# 
# GetDforOne <- function(col, name, build){
#   out <- list(name=name, col=col)
#   return(out)
# }


GetDataForOneSubExp <- function(subexp_col, colname, build, extinctions, W){
  
  # obtain the terr_id corresponding to this subexp
  terr <- str_split_1(colname, "_")[2]
  
  # obtain the treat_year corresponding to this subexp from the extinctions list
  treat_year <- extinctions |> 
    filter(terr_id == terr) |> 
    pull(death_year)
  
  # drop observations outside the experiment window from the build
  data_in_window <- build |> 
    filter(between(year, treat_year-W, treat_year+W))
  
  # add treatment dummies and drop cities that are not in this subexp
  keys_with_treat <- build |> 
    select(city_id) |> 
    unique() |> 
    mutate(TREAT = subexp_col)
  
  data_with_treat <- data_in_window |> 
    left_join(keys_with_treat, by="city_id") |> 
    drop_na(TREAT)
  
  # add post dummies and interaction
  data_with_post <- data_with_treat |> 
    mutate(POST = if_else(year >= treat_year, 1, 0)) |> 
    mutate(D = if_else(TREAT * POST == 1, 1, 0))
  
  # add subexp identifiers (for the stacked table)
  output <- data_with_post |> 
    mutate(subexp = terr, treat_year = treat_year)
  
  return(output)
}
