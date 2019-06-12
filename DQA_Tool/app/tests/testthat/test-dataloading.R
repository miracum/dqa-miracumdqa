context("test dataloading")

# debugging prefix
#prefix <- "./DQA_Tool/app/tests/testthat/"
prefix <- "./"

library(data.table)


test_that("correct functioning of loadCSV function",{
  
  expect_true(headless(paste0(prefix, "testdata/exp_type_1.csv"), 
                       paste0(prefix, "testdata/cal_type_1.csv"),
                       type = "1",
                       plotdir = paste0(prefix, "plotdir"),
                       csvdir = paste0(prefix, "csvdir"),
                       logfilename = paste0(prefix, "log.txt")))
  expect_length(list.files(paste0(prefix, "plotdir")), 10)
  
  
  # cleanup
  expect_silent(cleanUp(plotdir = paste0(prefix, "plotdir"),
                        csvdir = paste0(prefix, "csvdir")))
  expect_true(file.remove(paste0(prefix, "log.txt")))
})