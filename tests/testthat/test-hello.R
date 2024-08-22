library(testthat)
library(clintrialx)

test_that("hello function works correctly", {
  output <- hello()
  expect_equal(output, "Welcome to ClinTrialX!")
})
