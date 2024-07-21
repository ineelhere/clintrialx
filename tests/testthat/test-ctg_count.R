library(testthat)

test_that("ctg_count works correctly", {
  skip_on_cran()  # Skip this test on CRAN since it involves an API call

  result <- ctg_count(
    condition = "Glioblastoma",
    location = "India",
    title = NULL,
    intervention = "Drug",
    status = NULL
  )

  expect_type(result, "double")
  expect_true(result >= 0)  # Expect a non-negative double
})
