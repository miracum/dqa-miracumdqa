context("test statistics")

# debugging prefix
#prefix <- "./DQA_Tool/app/tests/testthat/"
prefix <- "./"

library(data.table)
library(jsonlite)

test_that("correct functioning of countUnique",{
  
  rv <- headless_initialization(sourcefiledir = paste0(prefix, "testdata"), utilsdir = paste0(prefix, "../../_utilities/"), target_db = "i2b2")
  rv$list_source <- headless_loadSource(rv)
  
  expect_type(countUnique(rv$list_source[["FALL.CSV"]], "patient_identifier_value", "csv"), "list")
  expect_s3_class(countUnique(rv$list_source[["FALL.CSV"]], "patient_identifier_value", "csv"), "data.table")
  expect_known_hash(countUnique(rv$list_source[["FALL.CSV"]], "patient_identifier_value", "csv"), "778e701efe")
  
  expect_type(countUnique(rv$list_source[["FAB.CSV"]], "encounter_period_start", "csv"), "list")
  expect_s3_class(countUnique(rv$list_source[["FAB.CSV"]], "encounter_period_start", "csv"), "data.table")
  
  expect_type(countUnique(rv$list_source[["ICD.CSV"]], "condition_code_coding_code", "csv"), "list")
  expect_s3_class(countUnique(rv$list_source[["ICD.CSV"]], "condition_code_coding_code", "csv"), "data.table")
  
  expect_type(countUnique(rv$list_source[["OPS.CSV"]], "procedure_encounter_identifier_value", "csv"), "list")
  expect_s3_class(countUnique(rv$list_source[["OPS.CSV"]], "procedure_encounter_identifier_value", "csv"), "data.table")
  
})

test_that("correct functioning of extensiveSummary",{
  
  rv <- headless_initialization(sourcefiledir = paste0(prefix, "testdata"), utilsdir = paste0(prefix, "../../_utilities/"), target_db = "i2b2")
  rv$list_source <- headless_loadSource(rv)
  
  expect_type(extensiveSummary(rv$list_source[["FALL.CSV"]][, get("encounter_subject_patient_age_years")]), "list")
  expect_s3_class(extensiveSummary(rv$list_source[["FALL.CSV"]][, get("encounter_subject_patient_age_years")]), "data.table")
  expect_known_hash(extensiveSummary(rv$list_source[["FALL.CSV"]][, get("encounter_subject_patient_age_years")]), "0e70ced8ca")
  
  
})