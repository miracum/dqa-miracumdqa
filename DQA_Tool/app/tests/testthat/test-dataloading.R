context("test dataloading")

# debugging prefix
#prefix <- "./DQA_Tool/app/tests/testthat/"
prefix <- "./"

# initialize fake reactive values
rv <- list()

library(data.table)


test_that("correct functioning of loadCSV function",{
  
  # initialize sourcefiledir
  rv$sourcefiledir <- paste0(prefix, "testdata")
  
  # Fall.csv
  expect_silent(rv$list_source[["FALL.CSV"]] <- loadCSV(rv, "FALL.CSV", headless = TRUE))
  expect_type(rv$list_source[["FALL.CSV"]], "list")
  expect_known_hash(rv$list_source[["FALL.CSV"]], "f8e29df3df")
  
  # Fab.csv
  expect_silent(rv$list_source[["FAB.CSV"]] <- loadCSV(rv, "FAB.CSV", headless = TRUE))
  expect_type(rv$list_source[["FAB.CSV"]], "list")
  expect_known_hash(rv$list_source[["FAB.CSV"]], "8722410009")
  
  # Ops.csv
  expect_silent(rv$list_source[["OPS.CSV"]] <- loadCSV(rv, "OPS.CSV", headless = TRUE))
  expect_type(rv$list_source[["OPS.CSV"]], "list")
  expect_known_hash(rv$list_source[["OPS.CSV"]], "d3cfad0b93")
  
  # Icd.csv
  expect_silent(rv$list_source[["ICD.CSV"]] <- loadCSV(rv, "ICD.CSV", headless = TRUE))
  expect_type(rv$list_source[["ICD.CSV"]], "list")
  expect_known_hash(rv$list_source[["ICD.CSV"]], "af30f9ac66")
})