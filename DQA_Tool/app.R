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

library(shiny)
library(shinyjs)
library(shinydashboard)
library(shinyFiles)
library(DT)
library(data.table)
library(ggplot2)
#library(config) ##!! do not make config available in namespace --> otherwise confusion with data.table's "get"-function
library(jsonlite)
library(RPostgres)
library(e1071)
library(rmarkdown)
library(knitr)

# this is necessary to build tables in latex-code
options(kableExtra.auto_format = FALSE)
library(kableExtra)
options(knitr.table.format = "latex")

# app entrypoint here
shinyAppDir("app")


# TODO create "dqa_datamap" element in mdr to generically include data-map vars into dashboard overview
# TODO integrate plausibility checks
# TODO integrate conformance checks
# TODO populate value restrictions (value set in mdr)
# TODO add checks based on value set
