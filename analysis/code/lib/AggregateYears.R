# I want to go from yearly data to five-yearly (or k-yearly) data, to
# try and get more signal from the event study.

# The steps are:
# - map years to periods.
# - group yearly observations by period and map yearly values to period values.
#   - for construction, use the group mean (better than sum bc of truncated periods!).
#   - for treatment, use the group maximum.

# After that, you can compute time_to_treat the same way as before.

# Issues:
# - I have to drop NAs at some point; otherwise mean and max won't compute
# - Options:
#   - drop NA construction and treatment years from build
#   - honestly, I should drop NA treatment years as part of build.
#   - and I should make a version of build with no NA construction, too.
#   - drop NA construction and treatment periods after aggregation

# The cleanest way would be to handle this at the build stage.
# The final build.csv file should have 
# - no NA treatment
# - no NA construction
# - no obviously superfluous columns
# There should be a separate build_full.csv file that has 
# - no NA treatment, BUT
# - can have missing construction
# - has all columns

AggregateYears <- function(build, period_length){
  
  period_length <- 5
  aggregated <- build |> 
    mutate(period = year - year %% period_length) |>
    group_by(city_id, period) |> 
    drop
    summarise(
      construction = mean(construction, na.rm = T),
      treatment = max(treatment)
    )
}