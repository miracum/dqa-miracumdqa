context("test statistics")

# debugging prefix
#prefix <- "./tests/testthat/"
#utildir <- paste0(prefix, "../../inst/")
prefix <- "./"
utildir <- paste0(prefix, "../../miRacumDQA/")

library(data.table)
library(jsonlite)

test_that("correct functioning of countUnique",{

  rv <- headless_initialization(sourcefiledir = paste0(prefix, "testdata"), utilsdir = paste0(utildir, "application/_utilities/"), target_db = "i2b2")
  rv$list_source <- headless_loadSource(rv)

  expect_type(countUnique(rv$list_source[["FALL.CSV"]], "patient_identifier_value", "csv"), "list")
  expect_s3_class(countUnique(rv$list_source[["FALL.CSV"]], "patient_identifier_value", "csv"), "data.table")

  expect_type(countUnique(rv$list_source[["FAB.CSV"]], "encounter_period_start", "csv"), "list")
  expect_s3_class(countUnique(rv$list_source[["FAB.CSV"]], "encounter_period_start", "csv"), "data.table")

  expect_type(countUnique(rv$list_source[["ICD.CSV"]], "condition_code_coding_code", "csv"), "list")
  expect_s3_class(countUnique(rv$list_source[["ICD.CSV"]], "condition_code_coding_code", "csv"), "data.table")

  expect_type(countUnique(rv$list_source[["OPS.CSV"]], "procedure_encounter_identifier_value", "csv"), "list")
  expect_s3_class(countUnique(rv$list_source[["OPS.CSV"]], "procedure_encounter_identifier_value", "csv"), "data.table")

})

test_that("correct functioning of extensiveSummary",{

  rv <- headless_initialization(sourcefiledir = paste0(prefix, "testdata"), utilsdir = paste0(utildir, "application/_utilities/"), target_db = "i2b2")
  rv$list_source <- headless_loadSource(rv)

  expect_type(extensiveSummary(rv$list_source[["FALL.CSV"]][, get("encounter_subject_patient_age_years")]), "list")
  expect_s3_class(extensiveSummary(rv$list_source[["FALL.CSV"]][, get("encounter_subject_patient_age_years")]), "data.table")


})
