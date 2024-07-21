library(testthat)
library(dplyr)

test_that("Number of rows matches page_size", {
  # Define a page size to test with
  test_page_size <- 1

  # Call the function with the test page size
  result <- ctg_get_fields(status = "RECRUITING", page_size = test_page_size)

  # Check if the number of rows in the result matches the page size
  expect_equal(nrow(result), test_page_size,
               info = paste("Expected", test_page_size, "rows but got", nrow(result)))
})
