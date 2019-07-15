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

# report
renderResults <- function(results){
  
  # get names
  obj_names <- names(results[["description"]])
  
  # loop over objects
  for (i in obj_names){
    desc_out <- results$description[[i]]
    count_out <- results$counts[[i]]
    stat_out <- results$statistics[[i]]
    
    # title of variable
    cat(paste0("\n## ", desc_out$source_data$name, "  \n"))
    # description of variable
    cat(paste0("\n", desc_out$source_data$description, "  \n"))
    
    # representation in the source system
    cat("\n### Repräsentation im Quellsystem  \n")
    renderRepresentation(desc_out, "source_data")
    
    # overview
    cat("\n **Übersicht:**  \n")
    renderCounts(count_out, "source_data")
    
    # statistics
    cat("\n **Ergebnisse:**  \n")
    print(kableTable(stat_out$source_data))
    
    
    # representation in the target system
    cat("\n### Repräsentation im Zielsystem  \n")
    renderRepresentation(desc_out, "target_data")
    
    # overview
    cat("\n **Übersicht:**  \n")
    renderCounts(count_out, "target_data")
    
    # statistics
    cat("\n **Ergebnisse:**  \n")
    print(kableTable(stat_out$target_data))
  }
}

renderRepresentation <- function(desc_out, source){
  # source either "source_data" or "target_data"
  cat(paste0("\n- Variable: ", desc_out[[source]]$var_name, "  \n"))
  cat(paste0("- Tabelle: ", desc_out[[source]]$table_name, "  \n  \n"))
}

renderCounts <- function(count_out, source){
  # source either "source_data" or "target_data"
  cat(paste0("\n- Variablename: ", count_out[[source]]$cnt$variable, "  \n"))
  cat(paste0("\n- Variablentyp: ", count_out[[source]]$type, "  \n  \n"))
  cat(paste0("    + Merkmalsausprägungen: ", count_out[[source]]$cnt$distinct, "  \n"))
  cat(paste0("    + Gültige Werte: ", count_out[[source]]$cnt$valids, "  \n"))
  cat(paste0("    + Fehlende Werte: ", count_out[[source]]$cnt$missings, "  \n  \n"))
}


renderPlausis <- function(results){
  
  # get names
  obj_names <- names(results[["description"]])
  
  # loop over objects
  for (i in obj_names){
    desc_out <- results$description[[i]]
    count_out <- results$counts[[i]]
    stat_out <- results$statistics[[i]]
    
    # title of variable
    cat(paste0("\n## ", desc_out$source_data$name, "  \n"))
    # description of variable
    cat(paste0("\n", desc_out$source_data$description, "  \n"))
    
    # representation in the source system
    cat("\n### Repräsentation im Quellsystem  \n")
    renderPlausiRepresentation(desc_out, "source_data")
    
    # overview
    cat("\n **Übersicht:**  \n")
    renderCounts(count_out, "source_data")
    
    # statistics
    cat("\n **Ergebnisse:**  \n")
    print(kableTable(stat_out$source_data))
    
    # representation in the target system
    cat("\n### Repräsentation im Zielsystem  \n")
    renderPlausiRepresentation(desc_out, "target_data")
    
    # overview
    cat("\n **Übersicht:**  \n")
    renderCounts(count_out, "target_data")
    
    # statistics
    cat("\n **Ergebnisse:**  \n")
    print(kableTable(stat_out$target_data))
  }
}

renderPlausiRepresentation <- function(desc_out, source){
  # source either "source_data" or "target_data"
  cat(paste0("\n- Variable: ", desc_out[[source]]$var_name, "  \n"))
  cat(paste0("- Tabelle: ", desc_out[[source]]$table_name, "  \n"))
  cat(paste0("- FROM (SQL): ", desc_out[[source]]$sql_from, "  \n"))
  cat(paste0("- JOIN TABLE (SQL): ", desc_out[[source]]$sql_join_table, "  \n"))
  cat(paste0("- JOIN TYPE (SQL): ", desc_out[[source]]$sql_join_type, "  \n"))
  cat(paste0("- JOIN ON (SQL): ", desc_out[[source]]$sql_join_on, "  \n"))
  cat(paste0("- WHERE (SQL): ", desc_out[[source]]$sql_where, "  \n  \n"))
}
