# miRacumDQA - The MIRACUM consortium's data quality assessment tool.
# Copyright (C) 2019 MIRACUM - Medical Informatics in Research and Medicine
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# moduleVisualizationsServer
moduleAtempPlausibilityServer <- function(input, output, session, rv, input_re){
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
        shiny::withProgress(message = "Populating descriptions of plausibility checks", value = 0, {

          for (i in names(rv$pl_vars_filter)){
            shiny::incProgress(1/length(rv$pl_vars_filter), detail = paste("... working at description of", i, "..."))
            # generate descriptions
            desc_dat <- rv$mdr[get("dqa_assessment")==1,][grepl("^pl\\.", get("key")),][get("name")==i,c("name", "source_system", "source_variable_name",
                                                                                                         "source_table_name", "description",
                                                                                                         "sql_from", "sql_join_on", "sql_join_table", "sql_join_type", "sql_where",
                                                                                                         "variable_type", "value_set", "value_threshold", "missing_threshold"), with=F]

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
        shiny::withProgress(message = "Calculating counts of plausibility checks", value = 0, {

          for (i in names(rv$pl_vars_filter)){
            shiny::incProgress(1/length(rv$pl_vars_filter), detail = paste("... calculating counts of", i, "..."))
            # generate counts
            cnt_dat <- rv$mdr[get("dqa_assessment")==1,][grepl("^pl\\.", get("key")),][get("name")==i,c("source_system", "source_variable_name", "source_table_name", "variable_type", "key", "variable_name"), with=F]


            if (length(cnt_dat[,unique(get("variable_name"))]) == 1){
              rv$dqa_plausibility_results$counts[[rv$pl_vars_filter[[i]]]] <- calcCounts(cnt_dat, cnt_dat[,unique(get("variable_name"))], rv, sourcesystem = "csv", plausibility = TRUE)
            } else {
              cat("\nError occured during creating counts\n")
            }
          }
        })
      }

      # if there are no statistics yet
      if (is.null(rv$dqa_plausibility_results$statistics)){
        shiny::withProgress(message = "Calculating statistics of plausibility checks", value = 0, {

          for (i in names(rv$pl_vars_filter)){
            shiny::incProgress(1/length(rv$pl_vars_filter), detail = paste("... calculating statistics of", i, "..."))
            # generate counts
            stat_dat <- rv$mdr[get("dqa_assessment")==1,][grepl("^pl\\.", get("key")),][get("name")==i,c("source_system", "source_variable_name", "source_table_name", "variable_name", "variable_type", "key"),with=F]

            if (stat_dat[,unique(get("variable_type"))] == "factor"){
              rv$dqa_plausibility_results$statistics[[rv$pl_vars_filter[[i]]]] <- calcCatStats(stat_dat, stat_dat[,unique(get("variable_name"))], rv, sourcesystem = "csv", plausibility = TRUE)
              # for target_data; our data is in rv$list_target$key
            } else {
              rv$dqa_plausibility_results$statistics[[rv$pl_vars_filter[[i]]]] <- calcNumStats(stat_dat, stat_dat[,unique(get("variable_name"))], rv, sourcesystem = "csv", plausibility = TRUE)
            }
          }
        })
      }

      # generate output tables
      observeEvent(input_re()[["moduleAtempPlausibility-plausibility_sel"]], {

        # get description object
        desc_out <- rv$dqa_plausibility_results$description[[input_re()[["moduleAtempPlausibility-plausibility_sel"]]]]
        count_out <- rv$dqa_plausibility_results$counts[[input_re()[["moduleAtempPlausibility-plausibility_sel"]]]]
        stat_out <- rv$dqa_plausibility_results$statistics[[input_re()[["moduleAtempPlausibility-plausibility_sel"]]]]



        # render source description
        output$pl_selection_description_source <- renderTable({
          o <- desc_out$source_data
          c <- count_out$source_data
          data.table::data.table(" " = c("Variable name:", "Source table:", "FROM (SQL):", "JOIN TABLE (SQL):", "JOIN TYPE (SQL):", "JOIN ON (SQL):", "WHERE (SQL):", "DQ-internal Variable Name:", "Variable type:"),
                                 " " = c(o$var_name, o$table_name, o$sql_from, o$sql_join_table, o$sql_join_type, o$sql_join_on, o$sql_where, c$cnt$variable, c$type))

        })

        output$pl_description <- renderText({
          d <- desc_out$source_data$description
          # https://community.rstudio.com/t/rendering-markdown-text/11588
          out <- knitr::knit2html(text = d, fragment.only = TRUE)
          # output non-escaped HTML string
          shiny::HTML(out)
        })

        # render target description
        output$pl_selection_description_target <- renderTable({
          o <- desc_out$target_data
          c <- count_out$target_data
          data.table::data.table(" " = c("Variable name:", "Source table:", "FROM (SQL):", "JOIN TABLE (SQL):", "JOIN TYPE (SQL):", "JOIN ON (SQL):", "WHERE (SQL):", "DQ-internal Variable Name:", "Variable type:"),
                                 " " = c(o$var_name, o$table_name, o$sql_from, o$sql_join_table, o$sql_join_type, o$sql_join_on, o$sql_where, c$cnt$variable, c$type))

        })

        # render source counts
        output$pl_selection_counts_source <- renderTable({
          tryCatch({
            o <- count_out$source_data$cnt[,c("variable", "distinct", "valids", "missings"),with=F]
            data.table::data.table(" " = c("Distinct values:", "Valid values:", "Missing values:"),
                                   " " = c(o$distinct, o$valids, o$missings))
          }, error=function(e){shinyjs::logjs(e)})
        })
        # render target counts
        output$pl_selection_counts_target <- renderTable({
          tryCatch({
            o <- count_out$target_data$cnt[,c("variable", "distinct", "valids", "missings"),with=F]
            data.table::data.table(" " = c("Distinct values:", "Valid values:", "Missing values:"),
                                   " " = c(o$distinct, o$valids, o$missings))
          }, error=function(e){shinyjs::logjs(e)})
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


moduleAtempPlausibilityUI <- function(id){
  ns <- NS(id)

  tagList(
    fluidRow(
      box(title = "Select variable",
          uiOutput(ns("pl_selection_uiout")),
          width = 4
      ),
      box(title = "Description",
          htmlOutput(ns("pl_description")),
          width = 8
      )
    ),
    fluidRow(
      box(title="Source Data System",
          width = 6,
          fluidRow(
            column(8,
                   h5(tags$b("Metadata")),
                   tableOutput(ns("pl_selection_description_source"))
            ),
            column(4,
                   h5(tags$b("Completeness Overview")),
                   tableOutput(ns("pl_selection_counts_source"))
            )
          ),
          fluidRow(
            column(12,
                   h5(tags$b("Results")),
                   tableOutput(ns("pl_selection_source_table"))
            )
          )
      ),
      box(title="Target Data System",
          width = 6,
          fluidRow(
            column(8,
                   h5(tags$b("Metadata")),
                   tableOutput(ns("pl_selection_description_target"))
            ),
            column(4,
                   h5(tags$b("Completeness Overview")),
                   tableOutput(ns("pl_selection_counts_target"))
            )
          ),
          fluidRow(
            column(12,
                   h5(tags$b("Results")),
                   tableOutput(ns("pl_selection_target_table"))
            )
          )
      )
    )
  )
}
