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
#'
#' @examples
#' # Query for studies related to "diabetes" in "Kolkata" with the status "RECRUITING"
#' ctg_get_fields(condition = "diabetes", location = "Kolkata",
#'                                  status = "RECRUITING")
#'
#'
#' # Query for studies with "vaccine" in the title and the status "COMPLETED"
#' ctg_get_fields(title = "vaccine", status = "COMPLETED", page_size = 50)
#'
#'
#' @export


ctg_get_fields <- function(condition = NULL, location = NULL, title = NULL,
                           intervention = NULL, status = NULL,
                           page_size = 20) {
  status <- .validate_status(status)
  page_size <- .validate_page_size(page_size)

  query_params <- .build_query_params(
    condition = condition,
    location = location,
    title = title,
    intervention = intervention,
    status = status,
    page_size = page_size,
    count_total = TRUE
  )

  response <- .api_request(
    .ctg_studies_url,
    query_params = query_params,
    accept = "text/csv"
  )
  parsed_data <- .parse_csv_response(response)
  total_count <- .response_total_count(response)
  data_count <- nrow(parsed_data)

  if (is.na(total_count)) {
    message("The API did not provide a total match count for this query.")
  } else {
    message(
      "The query matches ",
      format(total_count, scientific = FALSE, trim = TRUE),
      " trial records in ClinicalTrials.gov."
    )
  }
  message(
    "Your query returned ", data_count, " trial records",
    if (data_count == page_size && !is.na(total_count) && total_count > data_count) {
      paste0(" (limited by page_size = ", page_size, ")")
    } else {
      ""
    },
    "."
  )

  tibble::as_tibble(parsed_data)
}
