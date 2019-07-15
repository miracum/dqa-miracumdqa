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

# headless initialization
headless_initialization <- function(sourcefiledir, utilsdir, target_db){
  
  rv <- list()
  
  # initialize sourcefiledir
  rv$sourcefiledir <- sourcefiledir
  json <- readLines(paste0(utilsdir, "SQL/SQL_i2b2.JSON"))
  rv$sql <- jsonlite::fromJSON(json)
  rv$target_db <- target_db
  
  # stuff from moduleMDR.R
  rv$mdr <- data.table::fread(paste0(utilsdir, "MDR/mdr.csv"), header = T)
  rv$target_keys <- rv$mdr[get("key")!="undefined",][get("source_system")==rv$target_db,unique(get("key"))]
  rv$source_keys <- rv$mdr[get("key")!="undefined",][get("source_system")=="csv" & !grepl("^pl\\.", get("key")), unique(get("source_table_name"))]
  
  # when mdr is there, let's create some useful variables
  reactive_to_append <- createRVvars(rv$mdr, rv$target_db)
  # workaround, to keep "rv" an reactiveValues object
  # (rv <- c(rv, reactive_to_append)) does not work!
  for (i in names(reactive_to_append)){
    rv[[i]] <- reactive_to_append[[i]]
  }
  
  return(rv)
}

headless_loadSource <- function(rv, keys_to_test = NULL, headless = TRUE){
  
  outlist <- list()
  
  # read source_data
  if (is.null(keys_to_test)){
    # test all keys from mdr
    keys_to_test <- rv$source_keys
  }
  
  outlist <- sapply(keys_to_test, function(i){
    loadCSV(rv, i, headless)
  }, simplify = F, USE.NAMES = T)
  
  # datatransformation source:
  for (i in keys_to_test){
    
    # get column names
    col_names <- colnames(outlist[[i]])
    
    # check, if column name in variables of interest
    # var_names of interest:
    var_names <- rv$mdr[get("source_table_name")==i,][grepl("dt\\.", get("key")),get("source_variable_name")]
    
    for (j in col_names){
      if (j %in% var_names){
        vn <- rv$mdr[get("source_table_name")==i,][grepl("dt\\.", get("key")),][get("source_variable_name")==j,get("variable_name")]
        colnames(outlist[[i]])[which(col_names==j)] <- vn
        
        # transform date_vars to dates
        if (vn %in% rv$date_vars){
          outlist[[i]][,(vn):=as.Date(substr(as.character(get(vn)), 1, 8), format="%Y%m%d")]
        }
        
        if (vn %in% rv$trans_vars){
          outlist[[i]][,(vn):=transformFactor(get(vn), vn)]
        }
        
        # transform cat_vars to factor
        if (vn %in% rv$cat_vars){
          outlist[[i]][,(vn):=factor(get(vn))]
        }
      }
    }
  }
  
  return(outlist)
}

headless_loadPlausis <- function(rv, headless = TRUE){
  
  outlist <- list()
  
  # read source plausibilities after data transformation
  for (i in unique(names(rv$pl_vars))){
    if (grepl("_source", rv$pl_vars[[i]])){
      j <- rv$pl_vars[[i]]
      outlist[[j]] <- loadSourcePlausibilities(j, rv, headless = headless)
    }
  }
  
  return(outlist)
}
  

headless_loadTarget <- function(rv, keys_to_test = NULL, headless = TRUE){
  
  outlist <- list()
  
  # read target_data
  if (is.null(keys_to_test)){
    # test all keys from mdr
    keys_to_test <- rv$target_keys
  }
  
  outlist <- sapply(keys_to_test, function(i){
    fireSQL(rv, i, headless)
  }, simplify = F, USE.NAMES = T)
  
  
  for (i in keys_to_test){
    
    # get column names
    col_names <- colnames(outlist$list_target[[i]])
    
    # check, if column name in variables of interest
    for (j in col_names){
      
      if (j %in% rv$trans_vars){
        outlist[[i]][,(j):=transformFactor(get(j), j)]
      }
      
      # transform cat_vars to factor
      if (j %in% rv$cat_vars){
        outlist[[i]][,(j):=factor(get(j))]
      }
    }
  }
  
  return(outlist)
}