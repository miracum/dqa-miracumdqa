library(testthat)
options(testthat.use_colours = TRUE)

library(data.table)

# source("./DQA_Tool/app/R/headless.R", encoding = "UTF-8")

test_check("testthat")

# start tests manually
# debugging prefix
# debug_prefix <- "./DQA_Tool/app/tests/"
# test_dir(debug_prefix)
# test_file(paste0(debug_prefix, "testthat/test-sql-i2b2.R"))
# test_file(paste0(debug_prefix, "testthat/test-dataloading.R"))
# test_file(paste0(debug_prefix, "testthat/test-startup.R"))
# test_file(paste0(debug_prefix, "testthat/test-headless.R"))
# test_file(paste0(debug_prefix, "testthat/test-statistics.R"))
