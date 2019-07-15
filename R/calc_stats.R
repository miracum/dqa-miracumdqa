# miRacumDQA - The MIRACUM consortium's data quality assessment tool.
# Copyright (C) 2019 MIRACUM - Medical Informatics in Research and Medicine
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

calcDescription <- function(desc_dat, rv, sourcesystem){
  if (nrow(desc_dat)>1){
    description <- list()
    description$source_data <- list(name = desc_dat[source_system==sourcesystem, name],
                                    description = desc_dat[source_system==sourcesystem, description],
                                    var_name = desc_dat[source_system==sourcesystem, source_variable_name],
                                    table_name = desc_dat[source_system==sourcesystem, source_table_name],
                                    fhir_name = desc_dat[source_system==sourcesystem, fhir])
    
    description$target_data <- list(var_name = desc_dat[source_system==rv$target_db, source_variable_name],
                                    table_name = desc_dat[source_system==rv$target_db, source_table_name],
                                    fhir_name = desc_dat[source_system==rv$target_db, fhir])
    return(description)
  } else {
    return(NULL)
  }
}

calcCounts <- function(cnt_dat, count_key, rv, sourcesystem, plausibility = FALSE){
  counts <- list()
  tryCatch({
    if (isFALSE(plausibility)){
      counts$source_data$cnt <- countUnique(rv$list_source[[cnt_dat[source_system==sourcesystem, source_table_name]]], count_key, sourcesystem, plausibility)
    } else {
      counts$source_data$cnt <- countUnique(rv$list_source[[cnt_dat[source_system==sourcesystem, key]]], count_key, sourcesystem, plausibility)
    }
    counts$source_data$type <- cnt_dat[source_system==sourcesystem, variable_type]
  }, error=function(e){
    cat("\nError occured when counting source_data\n")
    print(e)
    return(NULL)
  })
  
  # for target_data; our data is in rv$list_target$key
  tryCatch({
    counts$target_data$cnt <- countUnique(rv$list_target[[cnt_dat[source_system==rv$target_db, key]]], count_key, sourcesystem = rv$target_db, plausibility = plausibility)
    counts$target_data$type <- cnt_dat[source_system==rv$target_db, variable_type]
  }, error=function(e){
    cat("\nError occured when counting target_data\n")
    print(e)
    return(NULL)
  })
  
  return(counts)
}

calcCatStats <- function(stat_dat, stat_key, rv, sourcesystem, plausibility = FALSE){
  statistics <- list()
  
  tryCatch({
    if (isFALSE(plausibility)){
      # for source_data; our data is in rv$list_source$source_table_name
      statistics$source_data <- categoricalAnalysis(rv$list_source[[stat_dat[source_system==sourcesystem, source_table_name]]], stat_key)
    } else {
      statistics$source_data <- categoricalAnalysis(rv$list_source[[stat_dat[source_system==sourcesystem, key]]], stat_key)
    }
    statistics$target_data <- categoricalAnalysis(rv$list_target[[stat_dat[source_system==rv$target_db, key]]], stat_key)
    return(statistics)
  }, error=function(e){
    cat("\nError occured when calculating catStats\n")
    print(e)
    return(NULL)
  })
}

calcNumStats <- function(stat_dat, stat_key, rv, sourcesystem, plausibility = FALSE){
  statistics <- list()
  
  if (stat_dat[source_system==sourcesystem,variable_type!="date"]){
    tryCatch({
      if (isFALSE(plausibility)){
        # for source_data; our data is in rv$list_source$source_table_name
        statistics$source_data <- extensiveSummary(rv$list_source[[stat_dat[source_system==sourcesystem, source_table_name]]][, get(stat_key)])
      } else {
        statistics$source_data <- extensiveSummary(rv$list_source[[stat_dat[source_system==sourcesystem, key]]][, get(stat_key)])
      }
      statistics$target_data <- extensiveSummary(rv$list_target[[stat_dat[source_system==rv$target_db, key]]][, get(stat_key)])
      return(statistics)
    }, error=function(e){
      cat("\nError occured when calculating simple numStats\n")
      print(e)
      return(NULL)
    })
  } else {
    tryCatch({
      if (isFALSE(plausibility)){
        statistics$source_data <- simpleSummary(rv$list_source[[stat_dat[source_system==sourcesystem, source_table_name]]][, get(stat_key)])
      } else {
        statistics$source_data <- simpleSummary(rv$list_source[[stat_dat[source_system==sourcesystem, key]]][, get(stat_key)])
      }
      statistics$target_data <- simpleSummary(rv$list_target[[stat_dat[source_system==rv$target_db, key]]][, get(stat_key)])
      return(statistics)
    }, error=function(e){
      cat("\nError occured when calculating simple numStats\n")
      print(e)
      return(NULL)
    })
  }
}
