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
#' @import httr
#' @import readr
#' @import dplyr
#' @import progress
#'
#'
#' @examples
#' \dontrun{
#' trials <- ctg_bulk_fetch(location="india")
#' }
#' @export


ctg_bulk_fetch <- function(condition = NULL, location = NULL, title = NULL,
                           intervention = NULL, status = NULL) {

  allowed_status <- c("ACTIVE_NOT_RECRUITING", "COMPLETED", "ENROLLING_BY_INVITATION",
                      "NOT_YET_RECRUITING", "RECRUITING", "SUSPENDED", "TERMINATED",
                      "WITHDRAWN", "AVAILABLE", "NO_LONGER_AVAILABLE",
                      "TEMPORARILY_NOT_AVAILABLE", "APPROVED_FOR_MARKETING",
                      "WITHHELD", "UNKNOWN")

  validate_status(status, allowed_status)

  base_url <- "https://clinicaltrials.gov/api/v2/studies"
  query_params <- build_query_params(condition, location, title, intervention, status)

  total_count <- get_total_count(base_url, query_params)
  total_pages <- ceiling(total_count / 1000)

  pb <- create_progress_bar(total_pages)

  all_data <- fetch_all_pages(base_url, query_params, total_pages, pb)

  pb$terminate()

  dplyr::bind_rows(all_data)
}

validate_status <- function(status, allowed_status) {
  if (!is.null(status)) {
    invalid_status <- setdiff(status, allowed_status)
    if (length(invalid_status) > 0) {
      warning(sprintf("Invalid status value(s) provided: %s\nThese values will be ignored. Allowed values are: %s",
                      paste(invalid_status, collapse = ", "),
                      paste(allowed_status, collapse = ", ")))
      status <- intersect(status, allowed_status)
    }
  }
  status
}

build_query_params <- function(condition, location, title, intervention, status) {
  params <- list(
    format = "csv",
    markupFormat = "markdown",
    countTotal = "true",
    pageSize = 1000
  )

  if (!is.null(condition)) params[["query.cond"]] <- condition
  if (!is.null(location)) params[["query.locn"]] <- location
  if (!is.null(title)) params[["query.titles"]] <- title
  if (!is.null(intervention)) params[["query.intr"]] <- intervention
  if (length(status) > 0) params[["filter.overallStatus"]] <- paste(status, collapse = "|")

  params
}

get_total_count <- function(base_url, query_params) {
  response <- httr::GET(url = base_url, query = query_params, httr::add_headers(accept = "application/json"))
  httr::stop_for_status(response)
  as.numeric(httr::headers(response)[["x-total-count"]])
}

create_progress_bar <- function(total_pages) {
  progress::progress_bar$new(
    format = "Fetching Page :current/:total :spin :bar Completed :percent :elapsedfull ",
    total = total_pages,
    clear = FALSE,
    width = 80
  )
}

fetch_all_pages <- function(base_url, query_params, total_pages, pb) {
  all_data <- vector("list", total_pages)
  next_page_token <- NULL

  for (page_number in seq_len(total_pages)) {
    page_info <- fetch_data(base_url, query_params, page_number, next_page_token)
    all_data[[page_number]] <- page_info$data
    next_page_token <- page_info$next_page_token
    pb$tick(tokens = list(eta = format(Sys.time() + (pb$total - pb$current) * 5, "%H:%M:%S")))

    if (is.null(next_page_token)) break
  }

  all_data
}

fetch_data <- function(base_url, query_params, page_number, next_page_token) {
  if (!is.null(next_page_token)) {
    query_params[["pageToken"]] <- next_page_token
  }

  response <- httr::GET(url = base_url, query = query_params, httr::add_headers(accept = "application/json"))
  httr::stop_for_status(response)

  content <- httr::content(response, as = "text", encoding = "UTF-8")

  if (page_number != 1) {
    header_line <- "NCT Number,Study Title,Study URL,Acronym,Study Status,Brief Summary,Study Results,Conditions,Interventions,Primary Outcome Measures,Secondary Outcome Measures,Other Outcome Measures,Sponsor,Collaborators,Sex,Age,Phases,Enrollment,Funder Type,Study Type,Study Design,Other IDs,Start Date,Primary Completion Date,Completion Date,First Posted,Results First Posted,Last Update Posted,Locations,Study Documents"
    content <- paste(header_line, content, sep = "\n")
  }

  parsed_data <- readr::read_csv(content, show_col_types = FALSE)
  next_page_token <- httr::headers(response)[["x-next-page-token"]]

  list(data = parsed_data, next_page_token = next_page_token)
}
