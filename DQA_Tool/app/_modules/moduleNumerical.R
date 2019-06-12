# by Lorenz Kapsner
# moduleRawdata1Server
moduleNumericalServer <- function(input, output, session, rv, input_re){
  
  observe({
    # target_getdata is false, when data has loaded from database
    # source_getdata is false, when csv files have been imported
    if (isFALSE(rv$target_getdata) && isFALSE(rv$source_getdata)){
      
      # render select input here
      output$num_selection_uiout <- renderUI({
        selectInput(session$ns("numerical_sel"), "Select variable", rv$dqa_numerical, multiple=FALSE, selectize=FALSE, size = 10)
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
            desc_dat <- rv$mdr[dqa_assessment==1,][grepl("^dt\\.", key),][variable_name==rv$dqa_numerical[[i]],.(source_system, source_variable_name, source_table_name, fhir, description)]
            
            if (nrow(desc_dat)>1){
              rv$dqa_numerical_results$description[[rv$dqa_numerical[[i]]]] <- calcDescription(desc_dat, rv, sourcesystem = "csv")
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
            cnt_dat <- rv$mdr[dqa_assessment==1,][grepl("^dt\\.", key),][variable_name==rv$dqa_numerical[[i]],.(source_system, source_variable_name, source_table_name, variable_type, key)]
            
            rv$dqa_numerical_results$counts[[rv$dqa_numerical[[i]]]] <- calcCounts(cnt_dat, rv$dqa_numerical[[i]], rv, sourcesystem = "csv")
          }
        })
      }
      
      # if there are no statistics yet
      if (is.null(rv$dqa_numerical_results$statistics)){
        withProgress(message = "Calculating statistics of numerical variables", value = 0, {
          
          for (i in names(rv$dqa_numerical)){
            incProgress(1/length(rv$dqa_numerical), detail = paste("... calculating statistics of", i, "..."))
            # generate counts
            stat_dat <- rv$mdr[dqa_assessment==1,][grepl("^dt\\.", key),][variable_name==rv$dqa_numerical[[i]],.(source_system, source_variable_name, source_table_name, variable_type, key)]
            
            rv$dqa_numerical_results$statistics[[rv$dqa_numerical[[i]]]] <- calcNumStats(stat_dat, rv$dqa_numerical[[i]], rv, sourcesystem = "csv")
            
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
        
        output$num_description <- renderText({
          d <- desc_out$source_data$description
          # https://community.rstudio.com/t/rendering-markdown-text/11588
          out <- knitr::knit2html(text = d, fragment.only = TRUE)
          # output non-escaped HTML string 
          HTML(out)
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
        
        
        # render target statistics
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
      column(4,
             box(title = "Select variable",
                 uiOutput(ns("num_selection_uiout")),
                 width = 12
             ),
             box(title = "Description",
                 htmlOutput(ns("num_description")),
                 width = 12
             )
      ),
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
      )
    ),
    fluidRow(
      box(title="Statistics Source",
          tableOutput(ns("num_selection_source_table")),
          width=6
      ),
      box(title="Statistics Target",
          tableOutput(ns("num_selection_target_table")),
          width=6
      )
    )
  )
}