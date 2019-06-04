# by Lorenz Kapsner
# moduleMDRServer
moduleMDRServer <- function(input, output, session, rv, input_re){
  
  # read mdr
  observe({
    req(rv$target_db)
    if (is.null(rv$mdr)){
      cat("\nRead MDR\n")
      rv$mdr <- fread("./_utilities/MDR/mdr.csv", header = T)
    }
    
    if (rv$target_db %in% rv$mdr[,unique(source_system)]){
      # get target keys from our mdr
      rv$target_keys <- rv$mdr[key!="undefined"][source_system==rv$target_db,unique(key)]#[1:4] # uncomment this for debugging purposes
    } else {
      showModal(modalDialog(
        "No keys for target database found in MDR.", 
        title = "No keys found")
      )
    }
    
    # get source keys from our mdr
    rv$source_keys <- rv$mdr[key!="undefined"][source_system=="csv" & !grepl("^pl\\.", key), unique(source_table_name)]
  })
  
  # read variables of interest
  observe({
    req(rv$mdr)
    
    # get list of DQ-variables of interest
    rv$dqa_assessment <- rv$mdr[source_system=="csv" & dqa_assessment == 1,][order(source_table_name),.(source_variable_name, 
                                                                                                        variable_name, 
                                                                                                        variable_type, 
                                                                                                        key,
                                                                                                        source_table_name)]
    #print(rv$dqa_assessment)
    
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
  })
  
  output$mdr_table <- DT::renderDataTable({
    DT::datatable(rv$mdr, options = list(scrollX = TRUE, pageLength = 20, dom="ltip"))
  })
}


moduleMDRUI <- function(id){
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "DQ Metadatarepository",
        dataTableOutput(ns("mdr_table")),
        width = 12
      )
    )
  )
}
