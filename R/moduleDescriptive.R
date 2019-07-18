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

# moduleDescriptiveServer
moduleDescriptiveServer <- function(input, output, session, rv, input_re){

  observe({
    # target_getdata is false, when data has loaded from database
    # source_getdata is false, when csv files have been imported
    if (isFALSE(rv$target_getdata) && isFALSE(rv$source_getdata)){

      # render select input here
      output$descr_selection_uiout <- renderUI({
        selectInput(session$ns("var_select"), "Select variable", rv$variable_list, multiple=FALSE, selectize=FALSE, size = 10)
      })

      # calculate rv$dqa_descriptive_results
      # list-object-structure:
      # rv$dqa_descriptive_results
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
      if (is.null(rv$dqa_descriptive_results$description)){
        shiny::withProgress(message = "Populating descriptions of variables", value = 0, {

          for (i in names(rv$variable_list)){
            shiny::incProgress(1/length(rv$variable_list), detail = paste("... working at description of", i, "..."))
            # generate descriptions
            desc_dat <- rv$mdr[get("dqa_assessment")==1,][grepl("^dt\\.", get("key")),][get("variable_name")==rv$variable_list[[i]],c("name", "source_system", "source_variable_name",
                                                                                                                                      "source_table_name", "fhir", "description",
                                                                                                                                      "variable_type", "value_set", "value_threshold", "missing_threshold"),with=F]

            if (nrow(desc_dat)>1){
              rv$dqa_descriptive_results$description[[rv$variable_list[[i]]]] <- calcDescription(desc_dat, rv, sourcesystem = "csv")
            } else {
              cat("\nError occured during creating descriptions of source system\n")
            }
          }
        })
      }

      # if there are no counts yet
      if (is.null(rv$dqa_descriptive_results$counts)){
        shiny::withProgress(message = "Calculating counts of variables", value = 0, {

          for (i in names(rv$variable_list)){
            shiny::incProgress(1/length(rv$variable_list), detail = paste("... calculating counts of", i, "..."))
            # generate counts
            cnt_dat <- rv$mdr[get("dqa_assessment")==1,][grepl("^dt\\.", get("key")),][get("variable_name")==rv$variable_list[[i]],c("source_system", "source_variable_name", "source_table_name", "variable_type", "key"),with=F]

            rv$dqa_descriptive_results$counts[[rv$variable_list[[i]]]] <- calcCounts(cnt_dat, rv$variable_list[[i]], rv, sourcesystem = "csv")
          }
        })
      }

      # if there are no statistics yet
      if (is.null(rv$dqa_descriptive_results$statistics)){
        shiny::withProgress(message = "Calculating statistics of variables", value = 0, {

          for (i in names(rv$variable_list)){
            shiny::incProgress(1/length(rv$variable_list), detail = paste("... calculating statistics of", i, "..."))
            # generate counts
            stat_dat <- rv$mdr[get("dqa_assessment")==1,][grepl("^dt\\.", get("key")),][get("variable_name")==rv$variable_list[[i]],c("source_system", "source_variable_name", "source_table_name", "variable_type", "key"),with=F]

            if (stat_dat[,unique(get("variable_type"))] == "factor"){
              rv$dqa_descriptive_results$statistics[[rv$variable_list[[i]]]] <- calcCatStats(stat_dat, rv$variable_list[[i]], rv, sourcesystem = "csv")
              # for target_data; our data is in rv$list_target$key
            } else {
              rv$dqa_descriptive_results$statistics[[rv$variable_list[[i]]]] <- calcNumStats(stat_dat, rv$variable_list[[i]], rv, sourcesystem = "csv")
            }
          }
        })
      }

      observe({
        req(rv$dqa_descriptive_results)
        # TODO maybe add progress here
        # calculate conformance of descriptive results here
        # value conformance
        rv[["conformance"]][["value_conformance"]] <- valueConformance(rv$dqa_descriptive_results)

      })

      # generate output tables
      observeEvent(input_re()[["moduleDescriptive-var_select"]], {

        # get description object
        desc_out <- rv$dqa_descriptive_results$description[[input_re()[["moduleDescriptive-var_select"]]]]
        count_out <- rv$dqa_descriptive_results$counts[[input_re()[["moduleDescriptive-var_select"]]]]
        stat_out <- rv$dqa_descriptive_results$statistics[[input_re()[["moduleDescriptive-var_select"]]]]

        value_conf <- rv$conformance$value_conformance[[input_re()[["moduleDescriptive-var_select"]]]]


        output$descr_description <- renderText({
          d <- desc_out$source_data$description
          # https://community.rstudio.com/t/rendering-markdown-text/11588
          out <- knitr::knit2html(text = d, fragment.only = TRUE)
          # output non-escaped HTML string
          shiny::HTML(out)
        })

        # render source description
        output$descr_selection_description_source <- renderTable({
          o <- desc_out$source_data
          c <- count_out$source_data
          data.table::data.table(" " = c("Variable name:", "Source table:", "FHIR ressource:", "DQ-internal Variable Name:", "Variable type:"),
                                 " " = c(o$var_name, o$table_name, o$fhir, c$cnt$variable, c$type))

        })

        # render target description
        output$descr_selection_description_target <- renderTable({
          o <- desc_out$target_data
          c <- count_out$target_data
          data.table::data.table(" " = c("Variable name:", "Source table:", "FHIR ressource:", "DQ-internal Variable Name:", "Variable type:"),
                                 " " = c(o$var_name, o$table_name, o$fhir, c$cnt$variable, c$type))

        })

        # render source counts
        output$descr_selection_counts_source <- renderTable({
          tryCatch({
            o <- count_out$source_data$cnt[,c("variable", "distinct", "valids", "missings"),with=F]
            data.table::data.table(" " = c("Distinct values:", "Valid values:", "Missing values:"),
                                   " " = c(o$distinct, o$valids, o$missings))
          }, error=function(e){shinyjs::logjs(e)})
        })

        # render target counts
        output$descr_selection_counts_target <- renderTable({
          tryCatch({
            o <- count_out$target_data$cnt[,c("variable", "distinct", "valids", "missings"),with=F]
            data.table::data.table(" " = c("Distinct values:", "Valid values:", "Missing values:"),
                                   " " = c(o$distinct, o$valids, o$missings))
          }, error=function(e){shinyjs::logjs(e)})
        })


        # render source statistics
        output$descr_selection_source_table <- renderTable({
          stat_out$source_data
        })

        # render target statistics
        output$descr_selection_target_table <- renderTable({
          stat_out$target_data
        })



        # conformance source
        # render conformance checks (only if value set present)
        if (!is.na(desc_out$source_data$checks$value_set)){

          # workaround to tell ui, that value_set is there
          output$gotValueset_s <- reactive({
            return(TRUE)
          })

          output$descr_checks_source <- renderUI({
            h <- h5(tags$b("Value set:"))
            v <- verbatimTextOutput("moduleDescriptive-descr_checks_source_valueset")


            ch <- h5(tags$b("Value conformance:"))
            ce <- h5(paste0("Conformance check: ", ifelse(value_conf$target_data$conformance_error, "failed", "passed")))
            cu <- uiOutput("moduleDescriptive-descr_conformance_source")
            do.call(tagList, list(h, v, tags$hr(), ch, ce, cu))
          })

          json_obj <- jsonlite::fromJSON(desc_out$source_data$checks$value_set)

          if (desc_out$source_data$checks$var_type == "factor"){
            output$descr_checks_source_valueset <- renderText({
              json_obj[["value_set"]]
            })
          } else if (desc_out$source_data$checks$var_type %in% c("integer", "numeric")){
            output$descr_checks_source_valueset <- renderPrint({
              json_obj
            })
          }

          # render automatic conformance checks source
          # value conformance
          if (isTRUE(value_conf$source_data$conformance_error)){

            output$descr_conformance_source <- renderUI({
              v <- verbatimTextOutput("moduleDescriptive-descr_conformance_source_results")
              do.call(tagList, list(v))
            })

            output$descr_conformance_source_results <- renderText({
              value_conf$source_data$conformance_results
            })
          } else {
            output$descr_conformance_source <- renderUI({
            })
          }

        } else {

          # workaround to tell ui, that value_set is not there
          output$gotValueset_s <- reactive({
            return(FALSE)
          })
        }
        outputOptions(output, 'gotValueset_s', suspendWhenHidden=FALSE)


        # conformance target
        # render conformance checks (only if value set present)
        if (!is.na(desc_out$target_data$checks$value_set)){

          # workaround to tell ui, that value_set is there
          output$gotValueset_t <- reactive({
            return(TRUE)
          })

          output$descr_checks_target <- renderUI({
            h <- h5(tags$b("Value set:"))
            v <- verbatimTextOutput("moduleDescriptive-descr_checks_target_valueset")


            ch <- h5(tags$b("Value conformance:"))
            ce <- h5(paste0("Conformance check: ", ifelse(value_conf$target_data$conformance_error, "failed", "passed")))
            cu <- uiOutput("moduleDescriptive-descr_conformance_target")
            do.call(tagList, list(h, v, tags$hr(), ch, ce, cu))
          })

          json_obj <- jsonlite::fromJSON(desc_out$target_data$checks$value_set)

          if (desc_out$target_data$checks$var_type == "factor"){
            output$descr_checks_target_valueset <- renderText({
              json_obj[["value_set"]]
            })
          } else if (desc_out$target_data$checks$var_type %in% c("integer", "numeric")){
            output$descr_checks_target_valueset <- renderPrint({
              json_obj
            })
          }


          # render automatic conformance checks target
          # value conformance
          if (isTRUE(value_conf$target_data$conformance_error)){

            output$descr_conformance_target <- renderUI({
              v <- verbatimTextOutput("moduleDescriptive-descr_conformance_target_results")
              do.call(tagList, list(v))
            })

            output$descr_conformance_target_results <- renderText({
              value_conf$target_data$conformance_results
            })
          } else {
            output$descr_conformance_target <- renderUI({
            })
          }

        } else {

          # workaround to tell ui, that value_set is not there
          output$gotValueset_t <- reactive({
            return(FALSE)
          })
        }
        outputOptions(output, 'gotValueset_t', suspendWhenHidden=FALSE)

      })
    }
  })
}

moduleDescriptiveUI <- function(id){
  ns <- NS(id)

  tagList(
    fluidRow(
      box(title = "Select variable",
          uiOutput(ns("descr_selection_uiout")),
          width = 4
      ),
      box(title = "Description",
          htmlOutput(ns("descr_description")),
          width = 8
      )),
    fluidRow(
      box(title="Source Data System",
          width = 6,
          fluidRow(
            column(8,
                   h5(tags$b("Metadata")),
                   tableOutput(ns("descr_selection_description_source"))
            ),
            column(4,
                   h5(tags$b("Completeness Overview")),
                   tableOutput(ns("descr_selection_counts_source"))
            )
          ),
          fluidRow(
            column(8,
                   h5(tags$b("Results")),
                   tableOutput(ns("descr_selection_source_table"))
            ),
            column(4,
                   conditionalPanel(
                     condition = "output['moduleDescriptive-gotValueset_s']",
                     uiOutput(ns("descr_checks_source"))
                   )
            )
          )),
      box(title="Target Data System",
          width = 6,
          fluidRow(
            column(8,
                   h5(tags$b("Metadata")),
                   tableOutput(ns("descr_selection_description_target"))
            ),
            column(4,
                   h5(tags$b("Completeness Overview")),
                   tableOutput(ns("descr_selection_counts_target"))
            )
          ),
          fluidRow(
            column(8,
                   h5(tags$b("Results")),
                   tableOutput(ns("descr_selection_target_table"))
            ),
            column(4,
                   conditionalPanel(
                     condition = "output['moduleDescriptive-gotValueset_t']",
                     uiOutput(ns("descr_checks_target"))
                   )
            )
          ))
    )
  )
}
