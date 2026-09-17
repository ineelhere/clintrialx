test_that("version_info returns structured ClinicalTrials.gov metadata", {
  local_mocked_bindings(
    .api_request = function(...) {
      fake_http_response(
        '{"apiVersion":"2.0.3","dataTimestamp":"2026-09-17T12:30:00Z"}',
        content_type = "application/json"
      )
    },
    .package = "clintrialx"
  )

  result <- NULL
  expect_message(
    result <- version_info("clinicaltrials.gov"),
    "API version: 2.0.3"
  )
  expect_type(result, "list")
  expect_equal(result$api_version, "2.0.3")
  expect_s3_class(result$timestamp, "POSIXct")
})

test_that("version_info handles supported and unsupported sources", {
  expect_message(
    expect_null(version_info("aact")),
    "Please refer to: https://aact.ctti-clinicaltrials.org/api/v2/version"
  )
  expect_error(
    version_info("unsupported_source"),
    "Unsupported source",
    class = "ctg_validation_error"
  )
})
