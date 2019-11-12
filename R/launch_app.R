# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019 Universitätsklinikum Erlangen
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

#' @title Launch the MIRACUM DQA Tool
#'
#' @param port The port, the MIRACUM DQA Tool is running on (default: 3838)
#' @param utilspath The path to the utilities-folder, containing the metadata
#'   repository files (`mdr.csv` inside the folder `MDR`), JSON files with
#'   SQL statements (inside the folder `SQL`), config files for the database
#'   connection (`settings_default.yml`) and the email address used for the
#'   data map (`email.yml`), a JSON file containing site names (inside the
#'   folder `MISC`) and a markdown templated to create the PDF report
#'   (`DQA_report.Rmd` inside the folder `RMD`).
#' @param db_source The name of the source database. Currently, the only
#'   allowed argument is `p21csv` used for the import of the
#'   corresponding csv files.
#'
#' @return the MIRACUM DQA Tool Shiny application
#'
#' @import shiny
#'
#' @export
#'

launchDQAtool <- function(port=3838,
                          utilspath,
                          db_source){


  global_env_hack <- function(key,
                              val,
                              pos) {
    assign(
      key,
      val,
      envir = as.environment(pos)
    )
  }

  global_env_hack(
    key = "utilspath",
    val = utilspath,
    pos = 1L
  )

  global_env_hack(
    key = "db_source",
    val = db_source,
    pos = 1L
  )

  options(shiny.port = port)


  cat(paste0("\nVersion DQAstats: ", utils::packageVersion("DQAstats"),
             "\nVersion DQAgui: ", utils::packageVersion("DQAgui"),
             "\n"))

  shiny::shinyAppDir(
    appDir = system.file("application", package = "miRacumDQA")
  )
}

# debugging
# launchDQAtool(utilspath = "./_utilities/", db_source = "p21csv")
