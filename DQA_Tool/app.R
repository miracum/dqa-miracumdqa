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


# TODO populate metadata csv-table (to e.g. map variable names)
# TODO parse variables to correct vartypes after import
# TODO clean strings (regex) after import, e.g. source icd, ops, aufnahmeanlass, -grund, entlassgrund etc.
# TODO icd and ops in dashboard-übersicht mit aufnehmen
