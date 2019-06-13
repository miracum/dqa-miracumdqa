# (c) 2019 Lorenz Kapsner
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
      rv$target_keys <- rv$mdr[key!="undefined",][source_system==rv$target_db,unique(key)]#[1:4] # uncomment this for debugging purposes
    } else {
      showModal(modalDialog(
        "No keys for target database found in MDR.", 
        title = "No keys found")
      )
    }
    
    # get source keys from our mdr
    rv$source_keys <- rv$mdr[key!="undefined",][source_system=="csv" & !grepl("^pl\\.", key), unique(source_table_name)]
  })
  
  # read variables of interest
  observe({
    req(rv$mdr)
    
    # when mdr is there, let's create some useful variables
    reactive_to_append <- createRVvars(rv$mdr)
    # workaround, to keep "rv" an reactiveValues object
    # (rv <- c(rv, reactive_to_append)) does not work!
    for (i in names(reactive_to_append)){
      rv[[i]] <- reactive_to_append[[i]]
    }
    cat("\nIs rv reactive?", is.reactivevalues(rv), "\n\n")
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
