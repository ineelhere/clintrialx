#' Query ClinicalTrials.gov API
#'
#' This function sends a query to the ClinicalTrials.gov API and returns the results as a tibble.
#' Users can specify various parameters to filter the results, and if a parameter is not provided,
#' it will be omitted from the query.
#'
#' This function can return up to 1,000 results.
#'
#' @param condition A character string specifying the medical condition to search for.
#'                   This will filter the results to studies related to the given condition.
#' @param location A character string specifying the location (e.g., city or country)
#'                  to search in. This will filter the results to studies conducted in the specified
#'                  location.
#' @param title A character string specifying keywords to search for in study title.
#'               This will filter the results to studies with title that include the specified
#'               keywords.
#' @param intervention A character string specifying the intervention or treatment
#'                      to search for. This will filter the results to studies involving the specified
#'                      intervention.
#' @param status A character vector specifying the overall status of the studies.
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
#' @param page_size An integer specifying the number of results per page. The default
#'                  value is 20. The maximum allowed value is 1,000. If a value greater than 1,000
#'                  is specified, it will be coerced to 1,000. If not specified, the default value
#'                  will be used.
#'
#' @return A tibble containing the query results. Each row represents a study, and the columns
#'         correspond to the study details returned by the API.
#'
#' @details
#' The function constructs a query to the ClinicalTrials.gov API using the provided parameters.
#' It supports filtering by condition, location, title keywords, intervention, and overall status.
#' The function handles the API response, checks for errors, and parses the results into a tibble.
#'
#' @import httr
#' @import tibble
#' @import readr
#'
#' @examples
#' # Query for studies related to "diabetes" in "Kolkata" with the status "RECRUITING"
#' query_clinical_trials(condition = "diabetes", location = "Kolkata",
#'                                  status = "RECRUITING")
#'
#'
#' # Query for studies with "vaccine" in the title and the status "COMPLETED"
#' query_clinical_trials(title = "vaccine", status = "COMPLETED", page_size = 50)
#'
#'
#' @export


query_clinical_trials <- function(condition = "Glioblastoma", location = "India", title = NULL,
                                  intervention = "Drug", status = NULL,
                                  page_size = 20) {

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

  # Check page_size and issue a warning if necessary
  if (page_size >= 1000) {
    warning("Page size is maximum number of studies to return in response.
    If not specified, the default value will be used.
    It will be coerced down to 1000, if greater than that.")
  }

  # Construct the base URL
  base_url <- "https://clinicaltrials.gov/api/v2/studies"

  # Prepare query parameters
  query_params <- list(
    format = "csv",
    markupFormat = "markdown",
    countTotal = "true"
  )

  # Add page_size parameter
  query_params[["pageSize"]] <- as.character(page_size)

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

  # Parse the CSV content
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  parsed_data <- readr::read_csv(content, show_col_types = FALSE)

  # Parse the count
  total_count <- headers(response)[["x-total-count"]]
  data_count <- nrow(parsed_data)
  message(paste("The Query matches", total_count, "trials/data points in the ClinicalTrials.gov records."))
  if(data_count>=1000){
    message(paste("Your query returned", data_count, "trials/data points. It has a max limit of 1000 rows"))
  }
  else{
    message(paste("Your query returned", data_count, "trials/data points."))
  }

  # Convert to tibble and return
  return(tibble::as_tibble(parsed_data))
}
