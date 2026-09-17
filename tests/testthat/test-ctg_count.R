test_that("ctg_count returns the total-count header as a number", {
  observed_query <- NULL
  local_mocked_bindings(
    .api_request = function(url, query_params, ...) {
      observed_query <<- query_params
      fake_http_response(
        "NCT Number\nNCT04000165",
        headers = list("x-total-count" = "42")
      )
    },
    .package = "clintrialx"
  )

  result <- NULL
  expect_warning(
    result <- ctg_count(status = c("recruiting", "INVALID")),
    "Invalid status value",
    class = "ctg_validation_warning"
  )

  expect_type(result, "double")
  expect_equal(result, 42)
  expect_equal(observed_query[["filter.overallStatus"]], "RECRUITING")
  expect_equal(observed_query[["pageSize"]], "1")
})

test_that("ctg_count fails clearly when the count header is absent", {
  local_mocked_bindings(
    .api_request = function(...) fake_http_response("NCT Number\nNCT04000165"),
    .package = "clintrialx"
  )

  expect_error(
    ctg_count(),
    "x-total-count",
    class = "ctg_parse_error"
  )
})
