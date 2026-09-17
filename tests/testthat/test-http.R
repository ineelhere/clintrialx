test_that(".api_request returns successful responses from the shared transport", {
  calls <- 0L
  observed_arguments <- NULL
  local_mocked_bindings(
    .http_retry = function(...) {
      calls <<- calls + 1L
      observed_arguments <<- list(...)
      fake_http_response("ok")
    },
    .package = "clintrialx"
  )

  response <- clintrialx:::.api_request("https://example.test")
  expect_s3_class(response, "response")
  expect_equal(calls, 1L)
  expect_equal(observed_arguments$times, 4L)
  expect_equal(observed_arguments$pause_base, 1)
  expect_equal(observed_arguments$pause_cap, 8)
  expect_false(observed_arguments$quiet)
  expect_true(400L %in% observed_arguments$terminate_on)
  expect_false(429L %in% observed_arguments$terminate_on)
})

test_that(".api_request raises typed errors after non-retryable or exhausted responses", {
  response_status <- 400L
  local_mocked_bindings(
    .http_retry = function(...) fake_http_response("", status = response_status),
    .package = "clintrialx"
  )

  for (status in c(400L, 404L, 429L, 500L)) {
    response_status <- status
    expect_error(
      clintrialx:::.api_request("https://example.test"),
      paste0("status ", status),
      class = "ctg_http_error"
    )
  }
})

test_that(".api_request turns an exhausted timeout into a typed transport error", {
  local_mocked_bindings(
    .http_retry = function(...) stop("Timeout was reached"),
    .package = "clintrialx"
  )
  expect_error(
    clintrialx:::.api_request("https://example.test"),
    "Timeout was reached",
    class = "ctg_http_error"
  )
})

test_that(".api_request validates transport settings", {
  expect_error(
    clintrialx:::.api_request("", max_attempts = 1L),
    "url",
    class = "ctg_validation_error"
  )
  expect_error(
    clintrialx:::.api_request("https://example.test", max_attempts = 0L),
    "max_attempts",
    class = "ctg_validation_error"
  )
  expect_error(
    clintrialx:::.api_request("https://example.test", timeout = 0),
    "timeout",
    class = "ctg_validation_error"
  )
})
