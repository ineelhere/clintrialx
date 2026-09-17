#' Bulk Fetch Clinical Trial Data from ClinicalTrials.gov API
#'
#' This function retrieves clinical trial data in bulk from the ClinicalTrials.gov API based on
#' specified parameters. It handles pagination and returns a combined dataset.
#'
#' @param condition Character string specifying the condition to search for.
#' @param location Character string specifying the location to search in.
#' @param title Character string specifying the title to search for.
#' @param intervention Character string specifying the intervention to search for.
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
#'
#' @return A data frame containing the fetched clinical trial data.
#'
#'
#'
#' @examples
#' \dontrun{
#' trials <- ctg_bulk_fetch(location="india")
#' }
#' @export


ctg_bulk_fetch <- function(condition = NULL, location = NULL, title = NULL,
                           intervention = NULL, status = NULL) {
  status <- .validate_status(status)
  query_params <- .build_query_params(
    condition = condition,
    location = location,
    title = title,
    intervention = intervention,
    status = status,
    page_size = 1000L,
    count_total = TRUE
  )

  pages <- list()
  expected_columns <- NULL
  next_page_token <- NULL
  seen_tokens <- character()
  page_number <- 0L
  progress_bar <- NULL

  on.exit({
    if (!is.null(progress_bar)) progress_bar$terminate()
  }, add = TRUE)

  repeat {
    page_query <- query_params
    if (!is.null(next_page_token)) {
      page_query[["pageToken"]] <- next_page_token
    }

    response <- .api_request(
      .ctg_studies_url,
      query_params = page_query,
      accept = "text/csv"
    )
    page_number <- page_number + 1L
    page <- .parse_csv_response(response, column_names = expected_columns)

    if (is.null(expected_columns)) {
      expected_columns <- names(page)
      total_count <- .response_total_count(response)
      if (interactive()) {
        total_pages <- if (is.na(total_count)) {
          1L
        } else {
          max(1L, ceiling(total_count / 1000))
        }
        progress_bar <- progress::progress_bar$new(
          format = "Fetching page :current/:total :bar :percent :elapsedfull",
          total = total_pages,
          clear = FALSE,
          width = 80
        )
      }
    }

    pages[[page_number]] <- page
    if (!is.null(progress_bar)) progress_bar$tick()

    new_token <- .response_header(response, "x-next-page-token")
    if (is.null(new_token)) break
    if (new_token %in% seen_tokens) {
      .abort_clintrialx(
        "ClinicalTrials.gov returned a repeated page token; pagination was stopped to prevent duplicate results",
        class = "ctg_pagination_error",
        page_token = new_token
      )
    }

    seen_tokens <- c(seen_tokens, new_token)
    next_page_token <- new_token
  }

  result <- dplyr::bind_rows(pages)
  message("Fetched ", nrow(result), " trial records across ", page_number, " page(s).")
  tibble::as_tibble(result)
}
