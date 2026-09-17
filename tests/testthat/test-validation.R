test_that("status validation normalizes valid values and removes invalid values", {
  result <- NULL
  expect_warning(
    result <- clintrialx:::.validate_status(c(" recruiting ", "INVALID", "RECRUITING")),
    "Invalid status value",
    class = "ctg_validation_warning"
  )
  expect_equal(result, "RECRUITING")
  expect_null(suppressWarnings(clintrialx:::.validate_status("INVALID")))
})

test_that("NCT validation normalizes and enforces the current identifier shape", {
  expect_equal(
    suppressMessages(clintrialx:::.validate_nct_ids(" nct04000165 ")),
    "NCT04000165"
  )
  expect_error(
    clintrialx:::.validate_nct_ids(NULL),
    "must be provided",
    class = "ctg_validation_error"
  )
  expect_error(
    clintrialx:::.validate_nct_ids("NCT123"),
    "Malformed",
    class = "ctg_validation_error"
  )
})

test_that("AACT inputs and connections are validated before DB access", {
  expect_error(aact_connection("", "pass"), "must be provided")
  expect_error(aact_connection("user", ""), "must be provided")
  expect_error(aact_check_connection(NULL), "Invalid or closed")
  expect_error(aact_custom_query(NULL, "SELECT 1"), "Invalid or closed")
})

test_that("ctg_data_report validates its data before optional packages", {
  invalid_data <- data.frame(A = 1:5)
  expect_error(
    ctg_data_report(invalid_data),
    "missing required columns",
    class = "ctg_validation_error"
  )
})
