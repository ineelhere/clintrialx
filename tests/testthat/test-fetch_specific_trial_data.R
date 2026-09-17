test_that("ctg_get_nct normalizes IDs, removes duplicates, and preserves fields", {
  observed_urls <- character()
  local_mocked_bindings(
    .api_request = function(url, query_params, ...) {
      observed_urls <<- c(observed_urls, url)
      fake_http_response(
        paste(
          "NCT Number,Study Title,Study Status",
          "NCT04000165,Example trial,COMPLETED",
          sep = "\n"
        )
      )
    },
    .package = "clintrialx"
  )

  result <- NULL
  expect_message(
    result <- ctg_get_nct(
      c(" nct04000165 ", "NCT04000165"),
      fields = c("NCT Number", "Study Title", "Study Status")
    ),
    "Removed duplicate"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1L)
  expect_equal(
    names(result),
    c("NCT Number", "Study Title", "Study Status")
  )
  expect_length(observed_urls, 1L)
  expect_match(observed_urls, "NCT04000165$")
})

test_that("ctg_get_nct validates IDs and fields before making requests", {
  expect_error(
    ctg_get_nct(NULL),
    "must be provided",
    class = "ctg_validation_error"
  )
  expect_error(
    ctg_get_nct("12345"),
    "Malformed NCT ID",
    class = "ctg_validation_error"
  )
  expect_error(
    ctg_get_nct("NCT04000165", fields = "Invalid Field"),
    "Invalid fields specified",
    class = "ctg_validation_error"
  )
})

test_that("ctg_get_nct reports partial and complete request failures", {
  request_number <- 0L
  local_mocked_bindings(
    .api_request = function(url, ...) {
      request_number <<- request_number + 1L
      if (request_number == 2L) {
        stop(structure(
          list(message = "not found", call = NULL),
          class = c("ctg_http_error", "clintrialx_error", "error", "condition")
        ))
      }
      fake_http_response("NCT Number,Study Title\nNCT04000165,Example trial")
    },
    .package = "clintrialx"
  )

  result <- NULL
  expect_warning(
    result <- ctg_get_nct(
      c("NCT04000165", "NCT04002440"),
      fields = c("NCT Number", "Study Title")
    ),
    "NCT04002440",
    class = "ctg_partial_result"
  )
  expect_equal(nrow(result), 1L)

  local_mocked_bindings(
    .api_request = function(...) {
      stop(structure(
        list(message = "not found", call = NULL),
        class = c("ctg_http_error", "clintrialx_error", "error", "condition")
      ))
    },
    .package = "clintrialx"
  )
  expect_error(
    suppressWarnings(ctg_get_nct("NCT04000165")),
    "Failed to fetch every requested NCT ID",
    class = "ctg_http_error"
  )
})

test_that("ctg_get_nct preserves requested ID order", {
  local_mocked_bindings(
    .api_request = function(url, ...) {
      nct_id <- sub(".*/", "", url)
      fake_http_response(
        paste0("NCT Number,Study Title\n", nct_id, ",Example trial")
      )
    },
    .package = "clintrialx"
  )

  requested <- c("NCT04002440", "NCT04000165")
  result <- ctg_get_nct(requested, fields = c("NCT Number", "Study Title"))
  expect_equal(result[["NCT Number"]], requested)
})
