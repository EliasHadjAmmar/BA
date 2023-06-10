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
