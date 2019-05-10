# moduleMDRServer
moduleMDRServer <- function(input, output, session, rv, input_re){
  
  # read mdr
  observe({
    req(rv$target_db)
    if (is.null(rv$mdr)){
      cat("\nRead MDR\n")
      rv$mdr <- fread("./_utilities/CSV/mdr.csv", header = T)
    }
  })
  
  # read keys depending on selection of datasource
  observe({
    req(rv$target_db)
    
    if (rv$target_db %in% rv$mdr[,unique(source_system)]){
      # get target keys from our mdr
      rv$target_keys <- rv$mdr[key!="undefined"][source_system==rv$target_db,unique(key)]
    } else {
      showModal(modalDialog(
        "No keys for target database found in MDR.", 
        title = "No keys found")
      )
    }
    
    # get source keys from our mdr
    rv$source_keys <- rv$mdr[key!="undefined"][source_system=="csv",unique(source_table_name)]
  })
  
  output$mdr_table <- DT::renderDataTable({
    DT::datatable(rv$mdr, options = list(scrollX = TRUE, pageLength = 20))
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
