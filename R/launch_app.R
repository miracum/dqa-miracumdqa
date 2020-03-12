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
#' @param config_file The path to the configuration yml.
#'   E.g. config_file = system.file("application/_utilities/settings/settings_
#'   default.yml", package = "miRacumDQA").
#' @param use_env_credentials A boolean. If environment variables should
#'   be used to pass database credentials (default: TRUE). If you want
#'   to use environment variables to pass database credentials, please
#'   provide one variable for the respective data system (the name, which
#'   is stored in the default settings file and correspsondingly in the MDR)
#'   with the following format: *SYSTEMNAME*_PASSWORD, where *SYSTEMNAME*
#'   should be replaced with the name of the datasystem.
#' @param logfile_dir Is the absolute path to the directory where the logfile
#'   will be stored. If not path is provided the tempdir() will be used.
#'
#' @return the MIRACUM DQA Tool Shiny application
#'
#' @import shiny shinydashboard
#'
#' @export
#'

launch_dqa_tool <- function(
  port = 3838,
  utils_path = system.file("application/_utilities",
                           package = "miRacumDQA"),
  config_file =
    system.file("application/_utilities/settings/settings_default.yml",
                package = "miRacumDQA"),
  use_env_credentials = TRUE,
  logfile_dir = tempdir()) {


  DQAstats::global_env_hack(
    key = "utils_path",
    val = utils_path,
    pos = 1L
  )

  DQAstats::global_env_hack(
    key = "config_file",
    val = config_file,
    pos = 1L
  )

  DQAstats::global_env_hack(
    key = "use_env_credentials",
    val = use_env_credentials,
    pos = 1L
  )

  DQAstats::global_env_hack(
    key = "logfile_dir",
    val = logfile_dir,
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


  cat(paste0("\nVersion DQAstats: ", utils::packageVersion("DQAstats"),
             "\nVersion DQAgui: ", utils::packageVersion("DQAgui"),
             "\n"))

  shiny::shinyAppDir(
    appDir = system.file("application", package = "miRacumDQA")
  )
}
