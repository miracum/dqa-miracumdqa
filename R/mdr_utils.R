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

# create variables from mdr
createRVvars <- function(mdr, target_db){
  
  outlist <- list()
  
  # get list of DQ-variables of interest
  outlist$dqa_assessment <- mdr[get("source_system")=="csv" & get("dqa_assessment") == 1,][order(get("source_table_name")),c("name",
                                                                                                        "source_variable_name", 
                                                                                                        "variable_name", 
                                                                                                        "variable_type", 
                                                                                                        "key",
                                                                                                        "source_table_name"), with=F]
  
  # get list of dqa_vars for catgeorical and numerical analyses
  outlist$dqa_vars <- outlist$dqa_assessment[grepl("^dt\\.", get("key")),]
  
  # variable_list
  variable_list <- outlist$dqa_vars[order(get("name"))]
  outlist$variable_list <- sapply(variable_list[,get("name")], function(x){
    variable_list[get("name")==x, get("variable_name")]
  }, simplify = F, USE.NAMES = T)
  
  # get list of pl_vars for plausibility analyses
  pl_vars <- mdr[grepl("^pl\\.", get("key")) & get("dqa_assessment") == 1,][order(get("source_table_name")),c("name",
                                                                                         "source_system",
                                                                                         "source_variable_name", 
                                                                                         "variable_name", 
                                                                                         "variable_type", 
                                                                                         "key",
                                                                                         "source_table_name"), with=F]
  outlist$pl_vars <- sapply(unique(pl_vars[,get("name")]), function(x){
    pl_vars[get("name")==x & get("source_system")=="csv", get("key")]
  }, simplify = F, USE.NAMES = T)
  
  outlist$pl_vars <- c(outlist$pl_vars,
                       sapply(unique(pl_vars[,get("name")]), function(x){
                         pl_vars[get("name")==x & get("source_system")==target_db, get("key")]
                       }, simplify = F, USE.NAMES = T))
  
  outlist$pl_vars_filter <- sapply(unique(pl_vars[,get("name")]), function(x){
    gsub("_source|_target", "", outlist$pl_vars[unique(names(outlist$pl_vars))][[x]])
  }, simplify = F, USE.NAMES = T)
  
  
  # get variables for type-transformations
  # get categorical variables
  outlist$cat_vars <- outlist$dqa_vars[get("variable_type") == "factor", get("variable_name")]
  
  # get date variables
  outlist$date_vars <- outlist$dqa_vars[get("variable_type") == "date", get("variable_name")]
  
  # get variable names, that need to be transformed (cleaning neccessary due to i2b2-prefixes)
  # this is yet hard-coded
  outlist$trans_vars <- c("encounter_hospitalization_dischargeDisposition", "encounter_hospitalization_class",
                          "condition_code_coding_code", "procedure_code_coding_code", "encounter_hospitalization_admitSource",
                          "condition_category_encounter_diagnosis")
  
  return(outlist)
}
