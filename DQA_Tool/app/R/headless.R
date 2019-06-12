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
  rv$dqa_assessment <- rv$mdr[source_system=="csv" & dqa_assessment == 1,][order(source_table_name),.(source_variable_name, 
                                                                                                      variable_name, 
                                                                                                      variable_type, 
                                                                                                      key,
                                                                                                      source_table_name)]
  # get list of dqa_vars for catgeorical and numerical analyses
  rv$dqa_vars <- rv$dqa_assessment[grepl("^dt\\.", key),]
  # numerical
  dqa_numerical <- rv$dqa_vars[variable_type %in% c("integer", "numerical", "date"),]
  rv$dqa_numerical <- sapply(dqa_numerical[,source_variable_name], function(x){
    dqa_numerical[source_variable_name==x, variable_name]
  }, simplify = F, USE.NAMES = T)
  
  # categorical
  dqa_categorical <- rv$dqa_vars[variable_type == "factor",]
  rv$dqa_categorical <- sapply(dqa_categorical[,source_variable_name], function(x){
    dqa_categorical[source_variable_name==x, variable_name]
  }, simplify = F, USE.NAMES = T)
  
  # get list of pl_vars for plausibility analyses
  rv$pl_vars <- rv$dqa_assessment[grepl("^pl\\.", key),]
  
  # get variables for type-transformations
  # get categorical variables
  rv$cat_vars <- rv$dqa_vars[variable_type == "factor", get("variable_name")]
  
  # get date variables
  rv$date_vars <- rv$dqa_vars[variable_type == "date", get("variable_name")]
  
  # get variable names, that need to be transformed (cleaning neccessary due to i2b2-prefixes)
  # this is yet hard-coded
  rv$trans_vars <- c("encounter_hospitalization_dischargeDisposition", "encounter_hospitalization_class",
                     "condition_code_coding_code", "procedure_code_coding_code", "encounter_hospitalization_admitSource",
                     "condition_category_encounter_diagnosis")
  
  
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