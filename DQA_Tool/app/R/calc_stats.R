calcDescription <- function(desc_dat, key, rv, sourcesystem){
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
