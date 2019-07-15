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

# read hard coded source plausibilities
loadSourcePlausibilities <- function(plausi, rv, headless=FALSE){
  
  if (plausi == "pl.item02_source"){
    # item02
    outlist <- merge(rv$list_source[["ICD.CSV"]][grepl("O[0-9]", condition_code_coding_code),.(condition_encounter_identifier_value, condition_code_coding_code)],
                     rv$list_source[["FALL.CSV"]][,.(encounter_identifier_value, patient_gender, patient_identifier_value)],
                     by.x = "condition_encounter_identifier_value",
                     by.y = "encounter_identifier_value",
                     all.x = TRUE)
    
    
  } else if (plausi == "pl.item03_source"){
    
    # item03
    outlist <- merge(rv$list_source[["ICD.CSV"]][grepl("C5[1-8]", condition_code_coding_code),.(condition_encounter_identifier_value, condition_code_coding_code)],
                     rv$list_source[["FALL.CSV"]][,.(encounter_identifier_value, patient_gender, patient_identifier_value)],
                     by.x = "condition_encounter_identifier_value",
                     by.y = "encounter_identifier_value",
                     all.x = TRUE)
    
  } else if (plausi == "pl.item04_source"){
    # item04
    outlist <- merge(rv$list_source[["ICD.CSV"]][grepl("C6[0-3]", condition_code_coding_code),.(condition_encounter_identifier_value, condition_code_coding_code)],
                     rv$list_source[["FALL.CSV"]][,.(encounter_identifier_value, patient_gender, patient_identifier_value)],
                     by.x = "condition_encounter_identifier_value",
                     by.y = "encounter_identifier_value",
                     all.x = TRUE)
    
  } else if (plausi == "pl.item05_source"){
    # item05
    outlist <- rv$list_source[["FALL.CSV"]][grepl("05xx", encounter_hospitalization_class),.(encounter_identifier_value,
                                                                           patient_gender,
                                                                           patient_identifier_value,
                                                                           encounter_hospitalization_class)]
  }
  if (isFALSE(headless)){
    rv$data_objects[[plausi]] <- plausi
  }
  return(outlist)
}


calcPlausiDescription <- function(desc_dat, rv, sourcesystem){
  if (nrow(desc_dat)>1){
    description <- list()
    description$source_data <- list(name = desc_dat[source_system==sourcesystem, name],
                                    description = desc_dat[source_system==sourcesystem, description],
                                    var_name = desc_dat[source_system==sourcesystem, source_variable_name],
                                    table_name = desc_dat[source_system==sourcesystem, source_table_name],
                                    sql_from = desc_dat[source_system==sourcesystem, sql_from],
                                    sql_join_table = desc_dat[source_system==sourcesystem, sql_join_table],
                                    sql_join_type = desc_dat[source_system==sourcesystem, sql_join_type],
                                    sql_join_on = desc_dat[source_system==sourcesystem, sql_join_on],
                                    sql_where = desc_dat[source_system==sourcesystem, sql_where])
    
    description$target_data <- list(var_name = desc_dat[source_system==rv$target_db, source_variable_name],
                                    table_name = desc_dat[source_system==rv$target_db, source_table_name],
                                    sql_from = desc_dat[source_system==rv$target_db, sql_from],
                                    sql_join_table = desc_dat[source_system==rv$target_db, sql_join_table],
                                    sql_join_type = desc_dat[source_system==rv$target_db, sql_join_type],
                                    sql_join_on = desc_dat[source_system==rv$target_db, sql_join_on],
                                    sql_where = desc_dat[source_system==rv$target_db, sql_where])
    return(description)
  } else {
    return(NULL)
  }
}
