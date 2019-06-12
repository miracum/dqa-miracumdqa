calcDescription <- function(desc_dat, rv, sourcesystem){
  if (nrow(desc_dat)>1){
    description <- list()
    description$source_data <- list(var_name = desc_dat[source_system==sourcesystem, source_variable_name],
                                    table_name = desc_dat[source_system==sourcesystem, source_table_name],
                                    fhir_name = desc_dat[source_system==sourcesystem, fhir],
                                    description = desc_dat[source_system==sourcesystem, description])
    
    description$target_data <- list(var_name = desc_dat[source_system==rv$target_db, source_variable_name],
                                    table_name = desc_dat[source_system==rv$target_db, source_table_name],
                                    fhir_name = desc_dat[source_system==rv$target_db, fhir])
    return(description)
  } else {
    return(NULL)
  }
}

calcCounts <- function(cnt_dat, count_key, rv, sourcesystem){
  counts <- list()
  tryCatch({
    counts$source_data$cnt <- countUnique(rv$list_source[[cnt_dat[source_system==sourcesystem, source_table_name]]], count_key, sourcesystem)
    counts$source_data$type <- cnt_dat[source_system==sourcesystem, variable_type]
  }, error=function(e){
    cat("\nError occured when counting source_data\n")
    print(e)
    return(NULL)
  })
  
  # for target_data; our data is in rv$list_target$key
  tryCatch({
    counts$target_data$cnt <- countUnique(rv$list_target[[cnt_dat[source_system==rv$target_db, key]]], count_key)
    counts$target_data$type <- cnt_dat[source_system==rv$target_db, variable_type]
  }, error=function(e){
    cat("\nError occured when counting target_data\n")
    print(e)
    return(NULL)
  })
  
  return(counts)
}

calcCatStats <- function(stat_dat, stat_key, rv, sourcesystem){
  statistics <- list()
  
  tryCatch({
    # for source_data; our data is in rv$list_source$source_table_name
    statistics$source_data <- categoricalAnalysis(rv$list_source[[stat_dat[source_system==sourcesystem, source_table_name]]], stat_key)
    statistics$target_data <- categoricalAnalysis(rv$list_target[[stat_dat[source_system==rv$target_db, key]]], stat_key)
    return(statistics)
  }, error=function(e){
    cat("\nError occured when calculating catStats\n")
    print(e)
    return(NULL)
  })
}

calcNumStats <- function(stat_dat, stat_key, rv, sourcesystem){
  statistics <- list()
  
  if (stat_dat[source_system==sourcesystem,variable_type!="date"]){
    tryCatch({
      # for source_data; our data is in rv$list_source$source_table_name
      statistics$source_data <- extensiveSummary(rv$list_source[[stat_dat[source_system==sourcesystem, source_table_name]]][, get(stat_key)])
      statistics$target_data <- extensiveSummary(rv$list_target[[stat_dat[source_system==rv$target_db, key]]][, get(stat_key)])
      return(statistics)
    }, error=function(e){
      cat("\nError occured when calculating simple numStats\n")
      print(e)
      return(NULL)
    })
  } else {
    tryCatch({
      statistics$source_data <- simpleSummary(rv$list_source[[stat_dat[source_system==sourcesystem, source_table_name]]][, get(stat_key)])
      statistics$target_data <- simpleSummary(rv$list_target[[stat_dat[source_system==rv$target_db, key]]][, get(stat_key)])
      return(statistics)
    }, error=function(e){
      cat("\nError occured when calculating simple numStats\n")
      print(e)
      return(NULL)
    })
  }
}
