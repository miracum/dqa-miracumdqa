context("test i2b2 SQL statements")

# debugging prefix
#prefix <- "./DQA_Tool/app/tests/testthat/"
prefix <- "./"

library(data.table)
library(jsonlite)


test_that("correct sql statments",{
  
  rv <- headless_initialization(sourcefiledir = paste0(prefix, "testdata"), utilsdir = paste0(prefix, "../../_utilities/"), target_db = "i2b2")
  
  # Loop over target_keys and check for hash and type
  known_hashes <- list("dt.admission_target" = "55ca6562dc",
                 "dt.ageindays_target" = "d377f2fb66",
                 "dt.ageinyears_target" = "4db7883890",
                 "dt.condition_target" = "3c7959b794",
                 "dt.discharge_target" = "a2e34c3f1b",
                 "dt.encounter_target" = "8a1c0383d3",
                 "dt.hospitalization_target" = "b4f592e41b",
                 "dt.patient_target" = "fe47701beb",
                 "dt.procedure_target" = "a7e0c49801",
                 "dt.provider_target" = "610652bbd6",
                 "dt.ventilation_target" = "8940e288c4",
                 "pl.item02_target" = "216214fbb8",
                 "pl.item03_target" = "571cecd257",
                 "pl.item04_target" = "1c26d2abc4",
                 "pl.item05_target" = "eb66a989c3")
  for (i in rv$target_keys){
    expect_type(rv$sql[[i]], "character")
    expect_known_hash(rv$sql[[i]], known_hashes[[i]])
  }
  
})