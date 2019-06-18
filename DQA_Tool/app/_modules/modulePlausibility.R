# (c) 2019 Lorenz Kapsner
# moduleVisualizationsServer
modulePlausibilityServer <- function(input, output, session, rv, input_re){
  observe({
    if (isFALSE(rv$target_getdata) && isFALSE(rv$source_getdata)){
      
      # render select input here
      output$pl_selection_uiout <- renderUI({
        selectInput(session$ns("plausibility_sel"), "Select plausibility item", rv$pl_vars_filter, multiple=FALSE, selectize=FALSE, size = 10)
      })
      
      # calculate rv$dqa_plausibility_results
      # list-object-structure:
      # rv$dqa_plausibility_results
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
      if (is.null(rv$dqa_plausibility_results$description)){
        withProgress(message = "Populating descriptions of plausibility checks", value = 0, {
          
          for (i in names(rv$pl_vars_filter)){
            incProgress(1/length(rv$pl_vars_filter), detail = paste("... working at description of", i, "..."))
            # generate descriptions
            desc_dat <- rv$mdr[dqa_assessment==1,][grepl("^pl\\.", key),][name==i,.(name, source_system, source_variable_name, source_table_name, description, sql_from, sql_join_on, sql_join_table, sql_join_type, sql_where)]
            
            if (nrow(desc_dat)>1){
              rv$dqa_plausibility_results$description[[rv$pl_vars_filter[[i]]]] <- calcPlausiDescription(desc_dat, rv, sourcesystem = "csv")
            } else {
              cat("\nError occured during creating descriptions of source system\n")
            }
          }
        })
      }
      
      # if there are no counts yet
      if (is.null(rv$dqa_plausibility_results$counts)){
        withProgress(message = "Calculating counts of plausibility checks", value = 0, {

          for (i in names(rv$pl_vars_filter)){
            incProgress(1/length(rv$pl_vars_filter), detail = paste("... calculating counts of", i, "..."))
            # generate counts
            cnt_dat <- rv$mdr[dqa_assessment==1,][grepl("^pl\\.", key),][name==i,.(source_system, source_variable_name, source_table_name, variable_type, key, variable_name)]
            
            
            if (length(cnt_dat[,unique(variable_name)]) == 1){
              rv$dqa_plausibility_results$counts[[rv$pl_vars_filter[[i]]]] <- calcCounts(cnt_dat, cnt_dat[,unique(variable_name)], rv, sourcesystem = "csv", plausibility = TRUE)
            } else {
              cat("\nError occured during creating counts\n")
            }
          }
        })
      }
      
      # if there are no statistics yet
      if (is.null(rv$dqa_plausibility_results$statistics)){
        withProgress(message = "Calculating statistics of plausibility checks", value = 0, {

          for (i in names(rv$pl_vars_filter)){
            incProgress(1/length(rv$pl_vars_filter), detail = paste("... calculating statistics of", i, "..."))
            # generate counts
            stat_dat <- rv$mdr[dqa_assessment==1,][grepl("^pl\\.", key),][name==i,.(source_system, source_variable_name, source_table_name, variable_name, variable_type, key)]
            
            if (stat_dat[,unique(variable_type)] == "factor"){
              rv$dqa_plausibility_results$statistics[[rv$pl_vars_filter[[i]]]] <- calcCatStats(stat_dat, stat_dat[,unique(variable_name)], rv, sourcesystem = "csv", plausibility = TRUE)
            # for target_data; our data is in rv$list_target$key
            } else {
              rv$dqa_plausibility_results$statistics[[rv$pl_vars_filter[[i]]]] <- calcNumStats(stat_dat, stat_dat[,unique(variable_name)], rv, sourcesystem = "csv", plausibility = TRUE)
            }
          }
        })
      }
      
      # generate output tables
      observeEvent(input_re()[["modulePlausibility-plausibility_sel"]], {
        
        # get description object
        desc_out <- rv$dqa_plausibility_results$description[[input_re()[["modulePlausibility-plausibility_sel"]]]]
        count_out <- rv$dqa_plausibility_results$counts[[input_re()[["modulePlausibility-plausibility_sel"]]]]
        stat_out <- rv$dqa_plausibility_results$statistics[[input_re()[["modulePlausibility-plausibility_sel"]]]]
        
        
        
        # render source description
        output$pl_selection_description_source <- renderTable({
          o <- desc_out$source_data
          data.table(" " = c("Variable name:", "Source table:", "FROM (SQL):", "JOIN TABLE (SQL):", "JOIN TYPE (SQL):", "JOIN ON (SQL):", "WHERE (SQL):"),
                     " " = c(o$var_name, o$table_name, o$sql_from, o$sql_join_table, o$sql_join_type, o$sql_join_on, o$sql_where))
          
        })
        
        output$pl_description <- renderText({
          d <- desc_out$source_data$description
          # https://community.rstudio.com/t/rendering-markdown-text/11588
          out <- knitr::knit2html(text = d, fragment.only = TRUE)
          # output non-escaped HTML string 
          HTML(out)
        })
        
        # render target description
        output$pl_selection_description_target <- renderTable({
          o <- desc_out$target_data
          data.table(" " = c("Variable name:", "Source table:", "FROM (SQL):", "JOIN TABLE (SQL):", "JOIN TYPE (SQL):", "JOIN ON (SQL):", "WHERE (SQL):"),
                     " " = c(o$var_name, o$table_name, o$sql_from, o$sql_join_table, o$sql_join_type, o$sql_join_on, o$sql_where))
          
        })
        
        # render source counts
        output$pl_selection_counts_source <- renderTable({
          tryCatch({
            o <- count_out$source_data$cnt[,.(variable, distinct, valids, missings)]
            data.table(" " = c("DQ-internal Variable Name:", "Variable type:", "Distinct values:", "Valid values:", "Missing values:"),
                       " " = c(o[,variable], count_out$source_data$type, o[,distinct], o[,valids], o[,missings]))
          }, error=function(e){logjs(e)})
        })
        # render target counts
        output$pl_selection_counts_target <- renderTable({
          tryCatch({
            o <- count_out$target_data$cnt[,.(variable, distinct, valids, missings)]
            data.table(" " = c("DQ-internal Variable Name:", "Variable type:", "Distinct values:", "Valid values:", "Missing values:"),
                       " " = c(o[,variable], count_out$target_data$type, o[,distinct], o[,valids], o[,missings]))
          }, error=function(e){logjs(e)})
        })
        
        
        # render target statistics
        output$pl_selection_target_table <- renderTable({
          stat_out$target_data
        })
        # render source statistics
        output$pl_selection_source_table <- renderTable({
          stat_out$source_data
        })
      })
    }
  })
}


modulePlausibilityUI <- function(id){
  ns <- NS(id)
  
  tagList(
    fluidRow(
      column(4,
             box(title = "Select variable",
                 uiOutput(ns("pl_selection_uiout")),
                 width = 12
             ),
             box(title = "Description",
                 htmlOutput(ns("pl_description")),
                 width = 12
             )
      ),
      column(8,
             box(title="Results Source Data",
                 width = 12,
                 fluidRow(
                   column(6,
                          h5(tags$b("Source Format")),
                          tableOutput(ns("pl_selection_description_source"))
                   ),
                   column(6,
                          h5(tags$b("Variable Description")),
                          tableOutput(ns("pl_selection_counts_source"))
                   )
                 )
             ),
             box(title="Results Target Data",
                 width = 12,
                 fluidRow(
                   column(6,
                          h5(tags$b("Source Format")),
                          tableOutput(ns("pl_selection_description_target"))
                   ),
                   column(6,
                          h5(tags$b("Variable Description")),
                          tableOutput(ns("pl_selection_counts_target"))
                   )
                 )
             )
      )
    ),
    fluidRow(
      box(title="Statistics Source",
          tableOutput(ns("pl_selection_source_table")),
          width=6
      ),
      box(title="Statistics Target",
          tableOutput(ns("pl_selection_target_table")),
          width=6
      )
    )
  )
}
