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

# fire SQL to database
fireSQL <- function(rv, jsonobj, headless = FALSE){
  
  # avoid sql-injection
  # https://db.rstudio.com/best-practices/run-queries-safely/
  sql <- DBI::sqlInterpolate(rv$db_con, rv$sql[[jsonobj]])
  
  if (isFALSE(headless)){
    withProgress(
      message = paste0("Getting ", jsonobj, " data from server"), value = 0, {
        incProgress(1/1, detail = "... working hard to get data ...")
        
        # get data
        rv$data_objects[[jsonobj]] <- jsonobj
        outdat <- data.table(dbGetQuery(rv$db_con, sql), stringsAsFactors = TRUE)
      })
  } else {
    outdat <- data.table(dbGetQuery(rv$db_con, sql), stringsAsFactors = TRUE)
  }
  return(outdat)
}

# load csv files
loadCSV <- function(rv, filename, headless = FALSE){
  
  if (tolower(filename) == "fall.csv"){
    # only import necessary columns
    select_cols <- c(ENTLASSENDER_STANDORT = "factor",
                     KH_INTERNES_KENNZEICHEN = "factor",
                     GEBURTSJAHR = "factor",
                     GEBURTSMONAT = "factor",
                     GESCHLECHT = "factor",
                     PLZ = "factor",
                     AUFNAHMEDATUM = "integer64",
                     AUFNAHMEANLASS = "factor",
                     AUFNAHMEGRUND = "factor",
                     ENTLASSUNGSDATUM = "integer64",
                     ENTLASSUNGSGRUND = "factor",
                     ALTER_IN_TAGEN_AM_AUFNAHMETAG = "integer",
                     ALTER_IN_JAHREN_AM_AUFNAHMETAG = "integer",
                     PATIENTENNUMMER = "factor",
                     BEATMUNGSSTUNDEN = "integer")
  } else if (tolower(filename) == "fab.csv"){
    select_cols <- c(KH_INTERNES_KENNZEICHEN = "factor",
                     FAB = "factor",
                     FAB_AUFNAHMEDATUM = "integer64",
                     FAB_ENTLASSUNGSDATUM = "integer64")
  } else if (tolower(filename) == "icd.csv"){
    select_cols <- c(KH_internes_Kennzeichen = "factor",
                     Diagnoseart = "factor",
                     ICD_Kode = "factor")
  } else if (tolower(filename) == "ops.csv"){
    select_cols <- c(KH_internes_Kennzeichen = "factor",
                     OPS_Kode = "factor",
                     OPS_Datum = "integer64")
  } 
  
  if (isFALSE(headless)){
    withProgress(
      message = paste0("Reading ", filename, " file from directory"), value = 0, {
        incProgress(1/1, detail = "...name working hard to read data ...")
        # get data
        rv$data_objects[[filename]] <- filename
        outdat <- fread(paste0(rv$sourcefiledir, "/", filename), select = names(select_cols), colClasses = select_cols, header = T, na.strings = "", stringsAsFactors = TRUE)
      })
  } else {
    outdat <- fread(paste0(rv$sourcefiledir, "/", filename), select = names(select_cols), colClasses = select_cols, header = T, na.strings = "", stringsAsFactors = TRUE)
  }
  
  return(outdat)
}
