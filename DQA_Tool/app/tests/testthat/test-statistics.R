context("test statistics")

# debugging prefix
#prefix <- "./DQA_Tool/app/tests/testthat/"
prefix <- "./"

library(data.table)
library(jsonlite)

test_that("correct functioning of countUnique",{
  
  rv <- headless_initialization(sourcefiledir = paste0(prefix, "testdata"), utilsdir = paste0(prefix, "../../_utilities/"), target_db = "i2b2")
  
  
  
})