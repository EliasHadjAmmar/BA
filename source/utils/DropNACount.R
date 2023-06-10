DropNACount <- function(dat, varname){
  # Drops observations with the specified variable missing, 
  # and prints the number of observations that were dropped
  clean <- dat |> 
    drop_na(!!sym(varname))
  
  n_dropped <- nrow(dat)-nrow(clean)
  print(sprintf("Dropped %d observations with missing %s", n_dropped, varname))
  return(clean)
}