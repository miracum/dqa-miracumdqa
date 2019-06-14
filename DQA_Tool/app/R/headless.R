# (c) 2019 Lorenz Kapsner
# headless initialization
headless_initialization <- function(sourcefiledir, utilsdir, target_db){
  
  rv <- list()
  
  # initialize sourcefiledir
  rv$sourcefiledir <- sourcefiledir
  rv$sql <- rv$sql <- fromJSON(paste0(utilsdir, "SQL/SQL_i2b2.JSON"))
  rv$target_db <- target_db
  
  # stuff from moduleMDR.R
  rv$mdr <- fread(paste0(utilsdir, "MDR/mdr.csv"), header = T)
  rv$target_keys <- rv$mdr[key!="undefined",][source_system==rv$target_db,unique(key)]
  rv$source_keys <- rv$mdr[key!="undefined",][source_system=="csv" & !grepl("^pl\\.", key), unique(source_table_name)]
  
  # when mdr is there, let's create some useful variables
  reactive_to_append <- createRVvars(rv$mdr, rv$target_db)
  # workaround, to keep "rv" an reactiveValues object
  # (rv <- c(rv, reactive_to_append)) does not work!
  for (i in names(reactive_to_append)){
    rv[[i]] <- reactive_to_append[[i]]
  }
  
  # read source_data
  rv$list_source <- sapply(rv$source_keys, function(i){
    loadCSV(rv, i, headless = T)
  }, simplify = F, USE.NAMES = T)
  
  # datatransformation source:
  for (i in rv$source_keys){
    
    # get column names
    col_names <- colnames(rv$list_source[[i]])
    
    # check, if column name in variables of interest
    # var_names of interest:
    var_names <- rv$mdr[source_table_name==i,][grepl("dt\\.", key),source_variable_name]
    
    for (j in col_names){
      if (j %in% var_names){
        vn <- rv$mdr[source_table_name==i,][grepl("dt\\.", key),][source_variable_name==j,variable_name]
        colnames(rv$list_source[[i]])[which(col_names==j)] <- vn
        
        # transform date_vars to dates
        if (vn %in% rv$date_vars){
          rv$list_source[[i]][,(vn):=as.Date(substr(as.character(get(vn)), 1, 8), format="%Y%m%d")]
        }
        
        if (vn %in% rv$trans_vars){
          rv$list_source[[i]][,(vn):=transformFactor(get(vn), vn)]
        }
        
        # transform cat_vars to factor
        if (vn %in% rv$cat_vars){
          rv$list_source[[i]][,(vn):=factor(get(vn))]
        }
      }
    }
  }
  
  # read source plausibilities after data transformation
  for (i in unique(names(rv$pl_vars))){
    if (grepl("_source", rv$pl_vars[[i]])){
      j <- rv$pl_vars[[i]]
      rv$list_source[[j]] <- loadSourcePlausibilities(j, rv, headless=TRUE)
    }
  }
  
  
  # TODO: yet to implement
  # datatransformation target:
  # for (i in rv$target_keys){
  #   
  #   # get column names
  #   col_names <- colnames(rv$list_target[[i]])
  #   
  #   # check, if column name in variables of interest
  #   for (j in col_names){
  #     
  #     if (j %in% rv$trans_vars){
  #       rv$list_target[[i]][,(j):=transformFactor(get(j), j)]
  #     }
  #     
  #     # transform cat_vars to factor
  #     if (j %in% rv$cat_vars){
  #       rv$list_target[[i]][,(j):=factor(get(j))]
  #     }
  #   }
  # }
  
  return(rv)
}