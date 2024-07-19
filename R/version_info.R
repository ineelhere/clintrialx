#' Get API Version Information
#'
#' This function retrieves version information from specified clinical trials API sources.
#'
#' @param source A character string specifying the source to query. Currently, only "clinicaltrials.gov" is supported.
#' @return Prints the API version and data timestamp if successful. Otherwise, prints an error message.
#' @import httr
#' @import lubridate
#' @export
#' @examples
#' version_info()
#' version_info("clinicaltrials.gov")
version_info <- function(source = "clinicaltrials.gov") {
  supported_sources <- c("clinicaltrials.gov")

  if (!source %in% supported_sources) {
    stop("Unsupported source: ", source)
  }

  url <- switch(source,
                "clinicaltrials.gov" = "https://clinicaltrials.gov/api/v2/version")

  response <- httr::GET(url)

  if (httr::status_code(response) == 200) {
    content <- httr::content(response, as = "parsed", encoding = "UTF-8")
    readable_timestamp <- lubridate::ymd_hms(content$dataTimestamp)
    message("Clinicaltrials.gov API version: ", content$apiVersion, "\nTimestamp: ", readable_timestamp)
  } else {
    warning("Failed to retrieve data. HTTP status code: ", httr::status_code(response))
  }
}
