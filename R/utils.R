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

# transform some factor variables
transformFactor <- function(object, transform){

  object <- gsub("[[:alnum:]]*\\:", "", object)

  # quick and dirty workaround
  # TODO better would be to work with regex

  # Discharge
  if (transform == "encounter_hospitalization_dischargeDisposition"){
    keep_values <- c("059", "069", "079", "089", "099", "109", "119", "139", "179", "229", "239", "249", "259") # lt. (https://www.g-drg.de/Datenlieferung_gem._21_KHEntgG/Dokumente_zur_Datenlieferung/Datensatzbeschreibung)

    if (any(object %in% keep_values)){
      trans_out <- ifelse(object %in% keep_values, as.character(object), ifelse(!is.na(object), paste0(substr(object, 1, 2), "x"), object))
    } else {
      trans_out <- ifelse(!is.na(object), paste0(substr(object, 1, 2), "x"), object)
    }

    # Admission
  } else if (transform == "encounter_hospitalization_class"){
    trans_out <- ifelse(!is.na(object), paste0(substr(object, 1, 2), "xx"), object)

    # ICD
  } else if (transform == "condition_code_coding_code"){
    trans_out <- gsub("\\+|\\*|\\!|\\#", "", object)

    # all other variables that need to be transformed
  } else {
    trans_out <- object
  }

  return(factor(trans_out))
  invisible(gc())
}


kableTable <- function(data){
  if (" " %in% colnames(data)){
    return(knitr::kable(data, digits = 3, format = "latex", col.names = NULL) %>%
             kableExtra::kable_styling(full_width = F))
  } else {
    return(knitr::kable(data, digits = 3, format = "latex") %>%
             kableExtra::row_spec(0, bold=TRUE) %>%
             kableExtra::kable_styling(full_width = F))
  }
}

