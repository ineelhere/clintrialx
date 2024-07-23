library(testthat)
library(clintrialx)

test_that("version_info works correctly", {
  expect_message(version_info("aact"), "Please refer to: https://aact.ctti-clinicaltrials.org/api/v2/version")
  expect_error(version_info("unsupported_source"), "Unsupported source")
})
