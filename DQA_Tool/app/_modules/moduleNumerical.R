# by Lorenz Kapsner
# moduleRawdata1Server
moduleNumericalServer <- function(input, output, session, rv, input_re){
  
  observe({
    if (isFALSE(rv$target_getdata) && isFALSE(rv$source_getdata)){
      
      # render select input here
      output$num_selection_uiout <- renderUI({
        selectInput(session$ns("numerical_sel"), "Select variable", rv$dqa_numerical, multiple=FALSE, selectize=FALSE, size = 5)
      })
      
      # calculate rv$dqa_numerical_results
      # list-object-structure:
      # rv$dqa_numerical_results
      ## description
      ### variable
      #### source_data
      #### target_data
      ## counts
      ### variable
      #### source_data
      #### target_data
      ## statistics
      ### variable
      #### source_data
      #### target_data
      # if there are no descriptions yet
      if (is.null(rv$dqa_numerical_results$description)){
        withProgress(message = "Populating descriptions of numerical variables", value = 0, {
          
          for (i in names(rv$dqa_numerical)){
            incProgress(1/length(rv$dqa_numerical), detail = paste("... working at description of", i, "..."))
            # generate descriptions
            desc_dat <- rv$mdr[dqa_assessment==1,][variable_name==rv$dqa_numerical[[i]],.(source_system, source_variable_name, source_table_name, fhir)]
            if (nrow(desc_dat)>1){
              rv$dqa_numerical_results$description[[rv$dqa_numerical[[i]]]]$source_data <- list(var_name = desc_dat[source_system=="csv", source_variable_name],
                                                                                                table_name = desc_dat[source_system=="csv", source_table_name],
                                                                                                fhir_name = desc_dat[source_system=="csv", fhir])
              
              rv$dqa_numerical_results$description[[rv$dqa_numerical[[i]]]]$target_data <- list(var_name = desc_dat[source_system==rv$target_db, source_variable_name],
                                                                                                table_name = desc_dat[source_system==rv$target_db, source_table_name],
                                                                                                fhir_name = desc_dat[source_system==rv$target_db, fhir])
            } else {
              cat("\nError occured during creating descriptions of source system\n")
            }
          }
        })
      }
      
      # if there are no counts yet
      if (is.null(rv$dqa_numerical_results$counts)){
        withProgress(message = "Calculating counts of numerical variables", value = 0, {
          
          for (i in names(rv$dqa_numerical)){
            incProgress(1/length(rv$dqa_numerical), detail = paste("... calculating counts of", i, "..."))
            # generate counts
            cnt_dat <- rv$mdr[dqa_assessment==1,][variable_name==rv$dqa_numerical[[i]],.(source_system, source_variable_name, source_table_name, variable_type, key)]
            # for source_data; our data is in rv$list_source$source_table_name
            tryCatch({
              rv$dqa_numerical_results$counts[[rv$dqa_numerical[[i]]]]$source_data$cnt <- countUnique(rv$list_source[[cnt_dat[source_system=="csv", source_table_name]]], rv$dqa_numerical[[i]])
              rv$dqa_numerical_results$counts[[rv$dqa_numerical[[i]]]]$source_data$type <- cnt_dat[source_system=="csv", variable_type]
            }, error=function(e){logjs(e)})
            
            # for target_data; our data is in rv$list_target$key
            tryCatch({
              rv$dqa_numerical_results$counts[[rv$dqa_numerical[[i]]]]$target_data$cnt <- countUnique(rv$list_target[[cnt_dat[source_system==rv$target_db, key]]], rv$dqa_numerical[[i]])
              rv$dqa_numerical_results$counts[[rv$dqa_numerical[[i]]]]$target_data$type <- cnt_dat[source_system==rv$target_db, variable_type]
            }, error=function(e){logjs(e)})
          }
        })
      }
      
      # if there are no statistics yet
      if (is.null(rv$dqa_numerical_results$statistics)){
        withProgress(message = "Calculating statistics of numerical variables", value = 0, {
          
          for (i in names(rv$dqa_numerical)){
            incProgress(1/length(rv$dqa_numerical), detail = paste("... calculating statistics of", i, "..."))
            # generate counts
            stat_dat <- rv$mdr[dqa_assessment==1,][variable_name==rv$dqa_numerical[[i]],.(source_system, source_variable_name, source_table_name, variable_type, key)]
            if (stat_dat[source_system=="csv",variable_type!="date"]){
              tryCatch({
                # for source_data; our data is in rv$list_source$source_table_name
                rv$dqa_numerical_results$statistics[[rv$dqa_numerical[[i]]]]$source_data <- extensiveSummary(rv$list_source[[stat_dat[source_system=="csv", source_table_name]]][, get(rv$dqa_numerical[[i]])])
                rv$dqa_numerical_results$statistics[[rv$dqa_numerical[[i]]]]$target_data <- extensiveSummary(rv$list_target[[stat_dat[source_system==rv$target_db, key]]][, get(rv$dqa_numerical[[i]])])
              }, error=function(e){logjs(e)})
            } else {
              tryCatch({
                rv$dqa_numerical_results$statistics[[rv$dqa_numerical[[i]]]]$source_data <- simpleSummary(rv$list_source[[stat_dat[source_system=="csv", source_table_name]]][, get(rv$dqa_numerical[[i]])])
                rv$dqa_numerical_results$statistics[[rv$dqa_numerical[[i]]]]$target_data <- simpleSummary(rv$list_target[[stat_dat[source_system==rv$target_db, key]]][, get(rv$dqa_numerical[[i]])])
              }, error=function(e){logjs(e)})
            }
            
            # for target_data; our data is in rv$list_target$key
          }
        })
      }
      
      # generate output tables
      observeEvent(input_re()[["moduleNumerical-numerical_sel"]], {
        # get description object
        desc_out <- rv$dqa_numerical_results$description[[input_re()[["moduleNumerical-numerical_sel"]]]]
        count_out <- rv$dqa_numerical_results$counts[[input_re()[["moduleNumerical-numerical_sel"]]]]
        stat_out <- rv$dqa_numerical_results$statistics[[input_re()[["moduleNumerical-numerical_sel"]]]]
        
        
        
        # render source description
        output$num_selection_description_source <- renderTable({
          o <- desc_out$source_data
          data.table(" " = c("Variable name:", "Source table:", "FHIR ressource:"),
                     " " = c(o$var_name, o$table_name, o$fhir))
          
        })
        # render target description
        output$num_selection_description_target <- renderTable({
          o <- desc_out$target_data
          data.table(" " = c("Variable name:", "Source table:", "FHIR ressource:"),
                     " " = c(o$var_name, o$table_name, o$fhir))
          
        })
        
        # render source counts
        output$num_selection_counts_source <- renderTable({
          tryCatch({
          o <- count_out$source_data$cnt[,.(variable, distinct, valids, missings)]
          data.table(" " = c("DQ-internal Variable Name:", "Variable type:", "Distinct values:", "Valid values:", "Missing values:"),
                     " " = c(o[,variable], count_out$source_data$type, o[,distinct], o[,valids], o[,missings]))
          }, error=function(e){logjs(e)})
        })
        # render target counts
        output$num_selection_counts_target <- renderTable({
          tryCatch({
          o <- count_out$target_data$cnt[,.(variable, distinct, valids, missings)]
          data.table(" " = c("DQ-internal Variable Name:", "Variable type:", "Distinct values:", "Valid values:", "Missing values:"),
                     " " = c(o[,variable], count_out$target_data$type, o[,distinct], o[,valids], o[,missings]))
          }, error=function(e){logjs(e)})
        })
        
        
        # render target counts
        output$num_selection_target_table <- renderTable({
          stat_out$target_data
        })
        # render source statistics
        output$num_selection_source_table <- renderTable({
          stat_out$source_data
        })
      })
    }
  })
}

moduleNumericalUI <- function(id){
  ns <- NS(id)
  
  tagList(
    fluidRow(
      column(3,
             box(title = "Select variable",
                 uiOutput(ns("num_selection_uiout")),
                 width = 12
             )
      )
    ),
    fluidRow(
      column(8,
             box(title="Results Source Data",
                 width = 12,
                 fluidRow(
                   column(6,
                          h5(tags$b("Source Format")),
                          tableOutput(ns("num_selection_description_source"))
                   ),
                   column(6,
                          h5(tags$b("Variable Description")),
                          tableOutput(ns("num_selection_counts_source"))
                   )
                 )
             ),
             box(title="Results Target Data",
                 width = 12,
                 fluidRow(
                   column(6,
                          h5(tags$b("Source Format")),
                          tableOutput(ns("num_selection_description_target"))
                   ),
                   column(6,
                          h5(tags$b("Variable Description")),
                          tableOutput(ns("num_selection_counts_target"))
                   )
                 )
             )
      ),
      column(4,
             box(title="Statistics",
                 width=12,
                 column(6,
                        h5(tags$b("Source")),
                        tableOutput(ns("num_selection_source_table"))
                 ),
                 column(6,
                        h5(tags$b("Target")),
                        tableOutput(ns("num_selection_target_table"))
                 )
             )
      )
    )
  )
}