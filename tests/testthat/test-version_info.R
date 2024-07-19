library(testthat)
library(clintrialx)

test_that("version_info works correctly", {
  expect_message(version_info(), "Clinicaltrials.gov API version")
  expect_error(version_info("unsupported_source"), "Unsupported source")
})
