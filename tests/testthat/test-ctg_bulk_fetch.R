test_that("ctg_bulk_fetch follows page tokens and reuses first-page columns", {
  request_number <- 0L
  observed_queries <- list()
  local_mocked_bindings(
    .api_request = function(url, query_params, ...) {
      request_number <<- request_number + 1L
      observed_queries[[request_number]] <<- query_params
      if (request_number == 1L) {
        fake_http_response(
          "NCT Number,Study Title\nNCT00000001,First trial",
          headers = list(
            "x-total-count" = "2",
            "x-next-page-token" = "token-2"
          )
        )
      } else {
        fake_http_response("NCT00000002,Second trial")
      }
    },
    .package = "clintrialx"
  )

  result <- suppressMessages(ctg_bulk_fetch(status = "recruiting"))

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2L)
  expect_equal(result[["NCT Number"]], c("NCT00000001", "NCT00000002"))
  expect_equal(observed_queries[[1L]][["filter.overallStatus"]], "RECRUITING")
  expect_null(observed_queries[[1L]][["pageToken"]])
  expect_equal(observed_queries[[2L]][["pageToken"]], "token-2")
})

test_that("ctg_bulk_fetch stops on repeated page tokens", {
  request_number <- 0L
  local_mocked_bindings(
    .api_request = function(...) {
      request_number <<- request_number + 1L
      body <- if (request_number == 1L) {
        "NCT Number,Study Title\nNCT00000001,First trial"
      } else {
        "NCT00000002,Second trial"
      }
      fake_http_response(
        body,
        headers = list(
          "x-total-count" = "3",
          "x-next-page-token" = "same-token"
        )
      )
    },
    .package = "clintrialx"
  )

  expect_error(
    suppressMessages(ctg_bulk_fetch()),
    "repeated page token",
    class = "ctg_pagination_error"
  )
})

test_that("ctg_bulk_fetch returns a typed empty table for no matches", {
  local_mocked_bindings(
    .api_request = function(...) {
      fake_http_response(
        "NCT Number,Study Title\n",
        headers = list("x-total-count" = "0")
      )
    },
    .package = "clintrialx"
  )

  result <- suppressMessages(ctg_bulk_fetch())
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0L)
  expect_equal(names(result), c("NCT Number", "Study Title"))
})

test_that("ctg_bulk_fetch does not require a total count to return one page", {
  local_mocked_bindings(
    .api_request = function(...) {
      fake_http_response("NCT Number,Study Title\nNCT00000001,Only trial")
    },
    .package = "clintrialx"
  )

  result <- suppressMessages(ctg_bulk_fetch())
  expect_equal(nrow(result), 1L)
  expect_equal(result[["NCT Number"]], "NCT00000001")
})

test_that("ctg_bulk_fetch aligns later pages whose headers change order", {
  request_number <- 0L
  local_mocked_bindings(
    .api_request = function(...) {
      request_number <<- request_number + 1L
      if (request_number == 1L) {
        fake_http_response(
          "NCT Number,Study Title\nNCT00000001,First trial",
          headers = list("x-next-page-token" = "token-2")
        )
      } else {
        fake_http_response("Study Title,NCT Number\nSecond trial,NCT00000002")
      }
    },
    .package = "clintrialx"
  )

  result <- suppressMessages(ctg_bulk_fetch())
  expect_equal(result[["NCT Number"]], c("NCT00000001", "NCT00000002"))
  expect_equal(result[["Study Title"]], c("First trial", "Second trial"))
})
