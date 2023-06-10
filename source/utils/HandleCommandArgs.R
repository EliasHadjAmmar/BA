ReadCorrectBuild <- function(default_t){
  # Wrapper around HandleCommandArgs that directly returns the right build.
  # Basically saves 3 lines of code in each analysis script.
  
  t <- HandleCommandArgs(default_t)
  read_path <- sprintf("drive/derived/cities_data_%iy.csv", t)
  build <- read_csv(read_path)
  
  return(build)
}


HandleCommandArgs <- function(default_length){
  # This is so I don't need 3 scripts to output 3 datasets with different spacing.
  
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) > 1){
    stop("Can only pass one argument (period length)\n")
  }
  if (!is_empty(args) && is.na(as.integer(args))) {
    stop("Argument must be an integer (period length)\n")
  }
  
  t <- ifelse(!is_empty(args), as.integer(args)[1], default_length)
  return(t)
}