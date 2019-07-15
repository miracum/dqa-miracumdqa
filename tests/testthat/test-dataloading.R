context("test dataloading")

# debugging prefix
#prefix <- "./tests/testthat/"
#utildir <- paste0(prefix, "../../inst/")
prefix <- "./"
utildir <- paste0(prefix, "../../miRacumDQA/")

# initialize fake reactive values
rv <- list()

library(data.table)


test_that("correct functioning of loadCSV function",{

  # initialize sourcefiledir
  rv$sourcefiledir <- paste0(prefix, "testdata")

  # Fall.csv
  expect_silent(rv$list_source[["FALL.CSV"]] <- loadCSV(rv, "FALL.CSV", headless = TRUE))
  expect_type(rv$list_source[["FALL.CSV"]], "list")
  expect_s3_class(rv$list_source[["FALL.CSV"]], "data.table")

  # Fab.csv
  expect_silent(rv$list_source[["FAB.CSV"]] <- loadCSV(rv, "FAB.CSV", headless = TRUE))
  expect_type(rv$list_source[["FAB.CSV"]], "list")
  expect_s3_class(rv$list_source[["FAB.CSV"]], "data.table")

  # Ops.csv
  expect_silent(rv$list_source[["OPS.CSV"]] <- loadCSV(rv, "OPS.CSV", headless = TRUE))
  expect_type(rv$list_source[["OPS.CSV"]], "list")
  expect_s3_class(rv$list_source[["OPS.CSV"]], "data.table")

  # Icd.csv
  expect_silent(rv$list_source[["ICD.CSV"]] <- loadCSV(rv, "ICD.CSV", headless = TRUE))
  expect_type(rv$list_source[["ICD.CSV"]], "list")
  expect_s3_class(rv$list_source[["ICD.CSV"]], "data.table")
})
