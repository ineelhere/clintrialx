#' Get Count of Clinical Trials from ClinicalTrials.gov
#'
#' This function retrieves the count of clinical trials from ClinicalTrials.gov based on specified parameters.
#'
#' @param condition A character string specifying the condition being studied (default: NULL).
#' @param location A character string specifying the location of the trials (default: NULL).
#' @param title A character string specifying keywords in the study title (default: NULL).
#' @param intervention A character string specifying the type of intervention (default: NULL).
#' @param status A character vector specifying the recruitment status of the trials. Allowed values are:
#'               Valid values include:
#'               \itemize{
#'                 \item \code{ACTIVE_NOT_RECRUITING} - Studies that are actively conducting but not
#'                       recruiting participants.
#'                 \item \code{COMPLETED} - Studies that have completed all phases.
#'                 \item \code{ENROLLING_BY_INVITATION} - Studies that are enrolling participants
#'                       by invitation only.
#'                 \item \code{NOT_YET_RECRUITING} - Studies that have not yet started recruiting.
#'                 \item \code{RECRUITING} - Studies that are actively recruiting participants.
#'                 \item \code{SUSPENDED} - Studies that are temporarily halted.
#'                 \item \code{TERMINATED} - Studies that have been terminated before completion.
#'                 \item \code{WITHDRAWN} - Studies that have been withdrawn before enrollment.
#'                 \item \code{AVAILABLE} - Studies that are available.
#'                 \item \code{NO_LONGER_AVAILABLE} - Studies that are no longer available.
#'                 \item \code{TEMPORARILY_NOT_AVAILABLE} - Studies that are temporarily not available.
#'                 \item \code{APPROVED_FOR_MARKETING} - Studies that have been approved for marketing.
#'                 \item \code{WITHHELD} - Studies that have data withheld.
#'                 \item \code{UNKNOWN} - Studies with an unknown status.
#'               }
#'Default is NULL.
#' @return A number representing the total count of clinical trials matching the specified parameters.
#' @examples
#' ctg_count(
#'   condition = "Cancer",
#'   location = "India",
#'   title = NULL,
#'   intervention = "Drug",
#'   status = "RECRUITING"
#' )

#' @export
ctg_count <- function(condition = NULL, location = NULL, title = NULL,
                          intervention = NULL, status = NULL) {
  # Define allowed status values
  allowed_status <- c("ACTIVE_NOT_RECRUITING", "COMPLETED", "ENROLLING_BY_INVITATION",
                      "NOT_YET_RECRUITING", "RECRUITING", "SUSPENDED", "TERMINATED",
                      "WITHDRAWN", "AVAILABLE", "NO_LONGER_AVAILABLE",
                      "TEMPORARILY_NOT_AVAILABLE", "APPROVED_FOR_MARKETING",
                      "WITHHELD", "UNKNOWN")

  # Check if all provided status values are valid
  if (!is.null(status)) {
    invalid_status <- setdiff(status, allowed_status)
    if (length(invalid_status) > 0) {
      warning("Invalid status value(s) provided: ",
              paste(invalid_status, collapse = ", "),
              "\nThese values will be ignored. Allowed values are: ",
              paste(allowed_status, collapse = ", "))
      status <- intersect(status, allowed_status)
    }
  }

  # Construct the base URL
  base_url <- "https://clinicaltrials.gov/api/v2/studies"

  # Prepare query parameters
  query_params <- list(
    format = "csv",
    markupFormat = "markdown",
    countTotal = "true"
  )

  # Add optional parameters if they are provided
  if (!is.null(condition)) query_params[["query.cond"]] <- condition
  if (!is.null(location)) query_params[["query.locn"]] <- location
  if (!is.null(title)) query_params[["query.titles"]] <- title
  if (!is.null(intervention)) query_params[["query.intr"]] <- intervention
  query_params[["countTotal"]] <- "true"

  # Add status parameter
  if (length(status) > 0) {
    query_params[["filter.overallStatus"]] <- paste(status, collapse = "|")
  }

  # Make the API request
  response <- httr::GET(url = base_url, query = query_params,
                        httr::add_headers(accept = "application/json"))

  # Check for successful response
  if (httr::status_code(response) != 200) {
    stop("API request failed with status code: ", httr::status_code(response))
  }

  # Extract the countTotal value from the headers
  total_count <- headers(response)[["x-total-count"]]

  return(as.numeric(total_count))
}
