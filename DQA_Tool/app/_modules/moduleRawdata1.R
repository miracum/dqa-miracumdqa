# moduleRawdata1Server
moduleRawdata1Server <- function(input, output, session, rv, input_re){
  
  observe({
    if (length(rv$data_objects) > 0){
      # render select input here
      output$rawdata1_uiout <- renderUI({
        selectInput(session$ns("rawdata1_sel"), "Data object", rv$data_objects, multiple=FALSE, selectize=FALSE, size = 15)
      })
    }
  })
  
  observe({
    req(rv$target_getdata)
    if (isTRUE(rv$target_getdata)){
      # get data from database
      
      rv$list_target <- sapply(rv$target_keys, function(i){
        fireSQL(rv, i)
      }, simplify = F, USE.NAMES = T)
      rv$target_getdata <- FALSE
    }
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
  })
  
  
  observeEvent(input_re()[["moduleRawdata1-rawdata1_sel"]], {
    if (grepl("target", input_re()[["moduleRawdata1-rawdata1_sel"]])){
      selection <- rv$list_target[[input_re()[["moduleRawdata1-rawdata1_sel"]]]]
    } else {
      selection <- rv$list_source[[input_re()[["moduleRawdata1-rawdata1_sel"]]]]
    }
    output$rawdata1_table <- DT::renderDataTable({
      DT::datatable(selection, options = list(scrollX = TRUE, pageLength = 20))
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