# (c) 2019 Lorenz Kapsner
# quick checks
quickETLChecks <- function(results){
  
  # get names
  obj_names <- names(results[["description"]])
  
  # initialize output table
  out <- data.table("Variable" = character(0),
                    "Check Distincts" = character(0),
                    "Check Valids" = character(0))
  
  
  for (i in obj_names){
    check_distinct <- ifelse(results[["counts"]][[i]]$source_data$cnt$distinct == results[["counts"]][[i]]$target_data$cnt$distinct,
                             "passed", "failed")
    check_valids <- ifelse(results[["counts"]][[i]]$source_data$cnt$valids == results[["counts"]][[i]]$target_data$cnt$valids,
                           "passed", "failed")
    out <- rbind(out, data.table("Variable" = i,
                                 "Check Distincts" = check_distinct,
                                 "Check Valids" = check_valids))
  }
  return(out)
} 
