context("test functioning of headless.R")

# debugging prefix
#prefix <- "./DQA_Tool/app/tests/testthat/"
prefix <- "./"

library(data.table)


test_that("correct functioning of headless function",{
  
  rv <- headless_initialization(sourcefiledir = paste0(prefix, "testdata"), utilsdir = paste0(prefix, "../../_utilities/"), target_db = "i2b2")
  
  expect_type(rv, "list")
  expect_length(rv, 15)
  
  expect_type(rv$sourcefiledir, "character")
  expect_type(rv$target_db, "character")
  expect_type(rv$target_keys, "character")
  expect_type(rv$source_keys, "character")
  expect_type(rv$cat_vars, "character")
  expect_type(rv$date_vars, "character")
  expect_type(rv$trans_vars, "character")
  
  expect_type(rv$mdr, "list")
  expect_s3_class(rv$mdr, "data.table")
  
  expect_type(rv$dqa_assessment, "list")
  expect_s3_class(rv$dqa_assessment, "data.table")
  
  expect_type(rv$dqa_vars, "list")
  expect_s3_class(rv$dqa_vars, "data.table")
  
  expect_type(rv$dqa_numerical, "list")
  expect_type(rv$dqa_categorical, "list")
  
  expect_type(rv$pl_vars, "list")
  expect_s3_class(rv$pl_vars, "data.table")
  
  # test files
  expect_known_hash(rv$list_source[["FALL.CSV"]], "c33125ce1c")
  expect_s3_class(rv$list_source[["FALL.CSV"]], "data.table")
  expect_known_hash(rv$list_source[["FAB.CSV"]], "2902b68a5a")
  expect_s3_class(rv$list_source[["FAB.CSV"]], "data.table")
  expect_known_hash(rv$list_source[["OPS.CSV"]], "b100df4018")
  expect_s3_class(rv$list_source[["OPS.CSV"]], "data.table")
  expect_known_hash(rv$list_source[["ICD.CSV"]], "8dda050b3d")
  expect_s3_class(rv$list_source[["ICD.CSV"]], "data.table")

})
