context("startup isalive")

library(processx)

test_that("test is_alive", {
  x <- process$new("R", args = c("-e", "miRacumDQA::miRacumDQA()"))
  
  Sys.sleep(5)
  expect_true(x$is_alive())
  
  x$kill()
})
