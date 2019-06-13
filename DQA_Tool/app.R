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
