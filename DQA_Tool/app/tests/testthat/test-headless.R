context("test dataloading")

# debugging prefix
#prefix <- "./DQA_Tool/app/tests/testthat/"
prefix <- "./"

library(data.table)


test_that("correct functioning of headless function",{
  
  rv <- headless_initialization(sourcefiledir = paste0(prefix, "testdata"), utilsdir = paste0(prefix, "../../_utilities/"), target_db = "i2b2")
  
  expect_type(rv, "list")
  expect_length(rv, 15)
  
  
  expect_known_hash(rv$list_source[["FALL.CSV"]], "c33125ce1c")
  expect_known_hash(rv$list_source[["FAB.CSV"]], "2902b68a5a")
  expect_known_hash(rv$list_source[["OPS.CSV"]], "b100df4018")
  expect_known_hash(rv$list_source[["ICD.CSV"]], "8dda050b3d")

})
