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

# moduleMDRServer
moduleMDRServer <- function(input, output, session, rv, input_re){

  # read mdr
  observe({
    req(rv$target_db)
    if (is.null(rv$mdr)){
      cat("\nRead MDR\n")
      rv$mdr <- data.table::fread("./_utilities/MDR/mdr.csv", header = T)
    }

    if (rv$target_db %in% rv$mdr[,unique(get("source_system"))]){
      # get target keys from our mdr
      rv$target_keys <- rv$mdr[get("key")!="undefined",][get("source_system")==rv$target_db,unique(get("key"))]#[1:4] # uncomment this for debugging purposes
    } else {
      showModal(modalDialog(
        "No keys for target database found in MDR.",
        title = "No keys found")
      )
    }

    # get source keys from our mdr
    rv$source_keys <- rv$mdr[get("key")!="undefined",][get("source_system")=="csv" & !grepl("^pl\\.", get("key")), unique(get("source_table_name"))]
  })

  # read variables of interest
  observe({
    req(rv$mdr)

    # when mdr is there, let's create some useful variables
    reactive_to_append <- createRVvars(rv$mdr, rv$target_db)
    # workaround, to keep "rv" an reactiveValues object
    # (rv <- c(rv, reactive_to_append)) does not work!
    for (i in names(reactive_to_append)){
      rv[[i]] <- reactive_to_append[[i]]
    }
    cat("\nIs rv reactive?", shiny::is.reactivevalues(rv), "\n\n")
  })

  output$mdr_table <- DT::renderDataTable({
    print(head(rv$mdr))
    DT::datatable(rv$mdr, options = list(scrollX = TRUE, pageLength = 20, dom="ltip"))
  })
}


moduleMDRUI <- function(id){
  ns <- NS(id)

  tagList(
    fluidRow(
      box(
        title = "DQ Metadatarepository",
        DT::dataTableOutput(ns("mdr_table")),
        width = 12
      )
    )
  )
}
