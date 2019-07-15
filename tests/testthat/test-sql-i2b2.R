context("test i2b2 SQL statements")

# debugging prefix
#prefix <- "./tests/testthat/"
prefix <- "./"

library(data.table)
library(jsonlite)


test_that("correct sql statments",{
  
  rv <- headless_initialization(sourcefiledir = paste0(prefix, "testdata"), utilsdir = paste0(prefix, "../../inst/application/_utilities/"), target_db = "i2b2")
  rv$list_source <- headless_loadSource(rv)
  
  expect_type(rv$sql, "list")
  
  # Loop over target_keys and check for hash and type
  known_hashes <- list("dt.admission_target" = "ec7e204b1f",
                 "dt.ageindays_target" = "d3fab5408f",
                 "dt.ageinyears_target" = "906905f2b1",
                 "dt.condition_target" = "023b0fdb99",
                 "dt.discharge_target" = "5fe5ce3a96",
                 "dt.encounter_target" = "c0aab20872",
                 "dt.hospitalization_target" = "f63db6cf2b",
                 "dt.patient_target" = "3ef1d0d72b",
                 "dt.procedure_target" = "442626a979",
                 "dt.provider_target" = "ba576583a0",
                 "dt.ventilation_target" = "de35c69da8",
                 "pl.item02_target" = "609b0c81d8",
                 "pl.item03_target" = "184caf2f0d",
                 "pl.item04_target" = "282e8175bd",
                 "pl.item05_target" = "9b69ad20a9")
  for (i in rv$target_keys){
    expect_type(rv$sql[[i]], "character")
    expect_known_hash(rv$sql[[i]], known_hashes[[i]])
  }
  
})
