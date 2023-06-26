PrepareWindowData <- function(build, max_switches, years_post,
                        binarise_construction, binarise_switches){
  
  max_switches <- 2
  years_post <- 200
  
  # Filter out cities with too many lifetime switches
  selected <- FilterBySwitches(build, max_switches)
  
  # Identify across-period switches
  with_e_dummies <- AddEAnother(selected)
  
  # Add TREAT x POST dummies D
  with_D <- AddTreatXPost(with_e_dummies)
  
  # Binarise construction outcomes, if specified
  if (binarise_construction) { with_D <- with_D |> BinariseOutcomes() }
  
  # Binarise no. of switches (control), if specified
  if (binarise_switches) { with_D <- with_D |> BinariseSwitches() }
  
  # Process type change into treatment type
  with_types <- ProcessTypeChange(with_D)
  
  # Set D to 0 if treatment was more than 200 years ago
  with_window <- with_types |>
    mutate(D = case_when(
      period <= treat_time + years_post ~ D,
      period > treat_time + years_post ~ 0
    )) |> 
    replace_na(list(D = 0))
  
  # Rearrange columns (for readability)
  clean <- with_window |> select(
    city_id, treat_time, period, terr_id, switches, e_another, D, 
    rule_conquest, rule_succession, rule_other,
    conflict, c_all, c_state, c_private, c_public
  )
  
  return(clean)
}