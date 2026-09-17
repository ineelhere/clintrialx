test_that("ctg_get_fields returns the requested page and builds shared query parameters", {
  observed_query <- NULL
  local_mocked_bindings(
    .api_request = function(url, query_params, ...) {
      observed_query <<- query_params
      fake_http_response(
        paste(
          "NCT Number,Study Title",
          "NCT04000165,Example trial",
          sep = "\n"
        ),
        headers = list("x-total-count" = "12")
      )
    },
    .package = "clintrialx"
  )

  result <- suppressMessages(
    ctg_get_fields(
      condition = "diabetes",
      status = "recruiting",
      page_size = 1
    )
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1L)
  expect_equal(observed_query[["query.cond"]], "diabetes")
  expect_equal(observed_query[["filter.overallStatus"]], "RECRUITING")
  expect_equal(observed_query[["pageSize"]], "1")
  expect_equal(observed_query[["countTotal"]], "true")
})

test_that("ctg_get_fields validates page_size boundaries", {
  observed_query <- NULL
  local_mocked_bindings(
    .api_request = function(url, query_params, ...) {
      observed_query <<- query_params
      fake_http_response(
        "NCT Number,Study Title\nNCT04000165,Example trial",
        headers = list("x-total-count" = "1")
      )
    },
    .package = "clintrialx"
  )

  expect_no_warning(suppressMessages(ctg_get_fields(page_size = 1000)))
  expect_equal(observed_query[["pageSize"]], "1000")

  expect_no_warning(suppressMessages(ctg_get_fields(page_size = 999)))
  expect_equal(observed_query[["pageSize"]], "999")

  expect_warning(
    suppressMessages(ctg_get_fields(page_size = 1001)),
    "reduced to 1000",
    class = "ctg_validation_warning"
  )
  expect_equal(observed_query[["pageSize"]], "1000")

  invalid_sizes <- list(0, -1, 1.5, NA_real_, Inf, "20", c(1, 2))
  for (value in invalid_sizes) {
    expect_error(
      ctg_get_fields(page_size = value),
      "page_size",
      class = "ctg_validation_error"
    )
  }
})

test_that("ctg_get_fields returns a typed empty result", {
  local_mocked_bindings(
    .api_request = function(...) {
      fake_http_response(
        "NCT Number,Study Title\n",
        headers = list("x-total-count" = "0")
      )
    },
    .package = "clintrialx"
  )

  result <- suppressMessages(ctg_get_fields())
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0L)
  expect_equal(names(result), c("NCT Number", "Study Title"))
})
