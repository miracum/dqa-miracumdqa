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


# app entrypoint here
shinyAppDir("app")


# TODO create metadata csv-table (to e.g. map variable names)
