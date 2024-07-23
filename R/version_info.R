#' Get API Version Information
#'
#' This function retrieves version information from specified clinical trials API sources.
#'
#' @param source A character string specifying the source to query.
#'   Currently, "clinicaltrials.gov" and "aact" are supported.
#' @return A list containing API version and data timestamp for clinicaltrials.gov,
#'   or NULL for aact with a message printed.
#' @importFrom httr GET status_code content
#' @importFrom lubridate ymd_hms
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

  if (!source %in% supported_sources) {
    stop("Unsupported source: ", source, call. = FALSE)
  }

  urls <- c(
    "clinicaltrials.gov" = "https://clinicaltrials.gov/api/v2/version",
    "aact" = "https://aact.ctti-clinicaltrials.org/api/v2/version"
  )

  url <- urls[source]

  if (source == "clinicaltrials.gov") {
    tryCatch({
      response <- httr::GET(url)
      httr::stop_for_status(response)

      content <- httr::content(response, as = "parsed", encoding = "UTF-8")
      readable_timestamp <- lubridate::ymd_hms(content$dataTimestamp)

      result <- list(
        api_version = content$apiVersion,
        timestamp = readable_timestamp
      )

      message("API version: ", result$api_version, "\nTimestamp: ", result$timestamp)
    }, error = function(e) {
      warning("Failed to retrieve data: ", conditionMessage(e), call. = FALSE)

    })
  } else if (source == "aact") {
    message("Please refer to: ", url)
  }
}
