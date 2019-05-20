# by Lorenz Kapsner
# moduleRawdata1Server
moduleRawdata1Server <- function(input, output, session, rv, input_re){
  
  observe({
    if (length(rv$data_objects) > 0){
      # render select input here
      output$rawdata1_uiout <- renderUI({
        selectInput(session$ns("rawdata1_sel"), "Select data object", rv$data_objects, multiple=FALSE, selectize=FALSE, size = 15)
      })
    }
  })
  
  observe({
    req(rv$target_getdata)
    if (isTRUE(rv$target_getdata)){
      # get data from database
      
      rv$list_target <- sapply(rv$target_keys, function(i){
        logjs(paste("Getting", i, "from database."))
        fireSQL(rv, i)
      }, simplify = F, USE.NAMES = T)
      rv$target_getdata <- FALSE
    }
    
    # if (isFALSE(rv$target_getdata)){
    #   # transform date_vars to dates
    #   for (i in rv$target_keys){
    #     # get column names
    #     col_names <- colnames(rv$list_target[[i]])
    #     # get date variables
    #     date_vars <- rv$dqa_vars[variable_type == "date", get("variable_name")]
    #     
    #     # check, if column name in variables of interest
    #     for (j in col_names){
    #       # transform date_vars to dates
    #       if (j %in% date_vars){
    #         rv$list_target[[i]][,(j):=as.Date(substr(as.character(get(j)), 1, 8), format="%Y%m%d")]
    #       }
    #     }
    #   }
    # }
  })
  
  observe({
    req(rv$source_getdata)
    if (isTRUE(rv$source_getdata)){
      # get data from csv files
      cat("\nReading from csv\n")
      
      rv$list_source <- sapply(rv$source_keys, function(i){
        loadCSV(rv, i)
      }, simplify = F, USE.NAMES = T)
      rv$source_getdata <- FALSE
    }
    
    if (isFALSE(rv$source_getdata)){
      
      withProgress(message = "Transform variables to date type", value = 0, {
        # rename colnames of source data and transform to dates
        for (i in rv$source_keys){
          incProgress(1/length(rv$source_keys), detail = paste("... transforming to date:", i, "..."))
          
          # get column names
          col_names <- colnames(rv$list_source[[i]])
          # get date variables
          date_vars <- rv$dqa_vars[variable_type == "date", get("variable_name")]
          
          # check, if column name in variables of interest
          for (j in col_names){
            # var_names of interest:
            var_names <- rv$mdr[source_table_name==i,][grepl("dt\\.", key),source_variable_name]
            if (j %in% var_names){
              vn <- rv$mdr[source_table_name==i,][grepl("dt\\.", key),][source_variable_name==j,variable_name]
              colnames(rv$list_source[[i]])[which(col_names==j)] <- vn
              
              # transform date_vars to dates
              if (vn %in% date_vars){
                rv$list_source[[i]][,(vn):=as.Date(substr(as.character(get(vn)), 1, 8), format="%Y%m%d")]
              }
            }
          }
        }
      })
    }
  })
  
  
  observeEvent(input_re()[["moduleRawdata1-rawdata1_sel"]], {
    if (grepl("target", input_re()[["moduleRawdata1-rawdata1_sel"]])){
      selection <- rv$list_target[[input_re()[["moduleRawdata1-rawdata1_sel"]]]]
    } else {
      selection <- rv$list_source[[input_re()[["moduleRawdata1-rawdata1_sel"]]]]
    }
    output$rawdata1_table <- DT::renderDataTable({
      DT::datatable(selection, options = list(scrollX = TRUE, pageLength = 20, dom="ltip"))
    })
  })
}

moduleRawdata1UI <- function(id){
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(title = "Select data",
          uiOutput(ns("rawdata1_uiout")),
          width = 4
      ),
      box(
        title = "Review raw data",
        dataTableOutput(ns("rawdata1_table")),
        width = 8
      )
    )
  )
}