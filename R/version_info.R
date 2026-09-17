#' Get API Version Information
#'
#' This function retrieves version information from specified clinical trials API sources.
#'
#' @param source A character string specifying the source to query.
#'   Currently, "clinicaltrials.gov" and "aact" are supported.
#' @return A list containing API version and data timestamp for clinicaltrials.gov,
#'   or NULL for aact with a message printed.
#' @export
#'
#' @examples
#' version_info()
#' version_info("clinicaltrials.gov")
#' version_info("aact")
#'
#' @references
#' ClinicalTrials.gov API - https://clinicaltrials.gov/api/v2/version
#' AACT - https://aact.ctti-clinicaltrials.org/release_notes
version_info <- function(source = "clinicaltrials.gov") {
  supported_sources <- c("clinicaltrials.gov", "aact")

  if (!is.character(source) || length(source) != 1L || is.na(source) ||
      !source %in% supported_sources) {
    .abort_clintrialx(
      paste0("Unsupported source: ", paste(source, collapse = ", ")),
      class = "ctg_validation_error",
      argument = "source"
    )
  }

  urls <- c(
    "clinicaltrials.gov" = .ctg_version_url,
    "aact" = "https://aact.ctti-clinicaltrials.org/api/v2/version"
  )

  url <- urls[source]

  if (source == "clinicaltrials.gov") {
    response <- .api_request(url, accept = "application/json")
    response_content <- httr::content(response, as = "parsed", encoding = "UTF-8")

    if (is.null(response_content$apiVersion) || is.null(response_content$dataTimestamp)) {
      .abort_clintrialx(
        "The ClinicalTrials.gov version response is missing apiVersion or dataTimestamp",
        class = "ctg_parse_error"
      )
    }

    result <- list(
      api_version = response_content$apiVersion,
      timestamp = lubridate::ymd_hms(response_content$dataTimestamp, quiet = TRUE)
    )
    message("API version: ", result$api_version, "\nTimestamp: ", result$timestamp)
    return(result)
  } else {
    message("Please refer to: ", url)
    return(invisible(NULL))
  }
}
