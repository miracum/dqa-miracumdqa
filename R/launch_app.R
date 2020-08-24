# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019-2020 Universitätsklinikum Erlangen
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
#' @param utils_path The path to the utilities-folder, containing the metadata
#'   repository files (`mdr.csv` inside the folder `MDR`), JSON files with SQL
#'   statements (inside the folder `SQL`), config files for the database
#'   connection (`settings_default.yml`) and the email address used for the
#'   data map (`email.yml`), a JSON file containing site names (inside the
#'   folder `MISC`) and a markdown templated to create the PDF report
#'   (`DQA_report.Rmd` inside the folder `RMD`).
#' @param logfile_dir Is the absolute path to the directory where the logfile
#'   will be stored. If not path is provided the tempdir() will be used.
#' @param parallel A boolean. If TRUE (the default value), initializing
#'   `future::plan("multiprocess")` before running the code.
#' @param ncores A integer. The number of cores to use. Caution: you would
#'   probably like to choose a low number when operating on large datasets.
#'   Default: 2.
#'
#' @return The MIRACUM DQA Tool Shiny application.
#'
#' @import shiny shinydashboard
#'
#' @export
#'

launch_dqa_tool <- function(
  port = 3838,
  utils_path = system.file("application/_utilities",
                           package = "miRacumDQA"),
  logfile_dir = tempdir(),
  parallel = TRUE,
  ncores = 2
) {


  DIZutils::global_env_hack(
    key = "utils_path",
    val = utils_path,
    pos = 1L
  )

  DIZutils::global_env_hack(
    key = "logfile_dir",
    val = logfile_dir,
    pos = 1L
  )

  DIZutils::global_env_hack(
    key = "parallel",
    val = parallel,
    pos = 1L
  )

  DIZutils::global_env_hack(
    key = "ncores",
    val = ncores,
    pos = 1L
  )

  options(shiny.port = port)

  # override DQAgui functions
  utils::assignInNamespace(
    x = "button_mdr",
    value = button_mdr,
    ns = "DQAgui"
  )
  utils::assignInNamespace(
    x = "button_send_datamap",
    value = button_send_datamap,
    ns = "DQAgui"
  )


  message(
    paste0(
      "\nVersion DIZutils: ", utils::packageVersion("DIZutils"),
      "\nVersion DQAstats: ", utils::packageVersion("DQAstats"),
      "\nVersion DQAgui: ", utils::packageVersion("DQAgui"),
      "\nVersion miRacumDQA: ", utils::packageVersion("miRacumDQA"),
      "\n"
    )
  )

  shiny::shinyAppDir(
    appDir = system.file("application", package = "miRacumDQA")
  )
}
