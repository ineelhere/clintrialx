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
  status <- .validate_status(status)
  query_params <- .build_query_params(
    condition = condition,
    location = location,
    title = title,
    intervention = intervention,
    status = status,
    page_size = 1L,
    count_total = TRUE
  )

  response <- .api_request(
    .ctg_studies_url,
    query_params = query_params,
    accept = "text/csv"
  )
  total_count <- .response_total_count(response)

  if (is.na(total_count)) {
    .abort_clintrialx(
      "The ClinicalTrials.gov response did not include a valid x-total-count header",
      class = "ctg_parse_error"
    )
  }

  total_count
}
