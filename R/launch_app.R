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
#'
#' @return the MIRACUM DQA Tool Shiny application
#'
#' @import DQAgui shiny
#'
#' @export
#'

launchDQAtool <- function(port=3838){

  # set port and latex-options here
  options(shiny.port = port)

  shiny::shinyAppDir(appDir = system.file("application", package = "miRacumDQA"))
}
