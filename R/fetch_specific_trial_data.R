#' Fetch Clinical Trial Data Based on NCT ID
#'
#' Retrieves data for one or more clinical trials from the ClinicalTrials.gov API based on their NCT ID(s).
#'
#' This function allows you to specify one or more NCT IDs and optionally select specific fields of interest. It fetches the relevant data and returns it as a tibble.
#'
#' @param nct_ids A character vector of one or more NCT IDs (e.g., "NCT04000165") for the clinical trials to fetch.
#' @param fields A character vector specifying the fields to retrieve. If NULL (default), all available fields are fetched. If specified, it must be a subset of the available fields.
#' @return A tibble containing the clinical trial data with columns matching the requested fields.
#' @export
#'
#'
#' @examples
#' # Fetch data for a single NCT ID
#' trial_data <- ctg_get_nct("NCT04000165")
#' trial_data
#'
#' # Fetch data for multiple NCT IDs
#' multiple_trials <- ctg_get_nct(c("NCT04000165", "NCT04002440"))
#' multiple_trials
#'
#' # Fetch data for multiple NCT IDs with specific fields
#' specific_fields <- ctg_get_nct(
#'   c("NCT04000165", "NCT04002440"),
#'   fields = c("NCT Number", "Study Title", "Study Status")
#' )
#' specific_fields
#'
#' @details
#' The function constructs a request for each NCT ID, specifying the desired fields. It uses a progress bar to show the progress of fetching data for multiple trials.
#' The data is returned as a tibble with columns corresponding to the requested fields. If any fetches fail or if the API response contains columns not requested, warnings will be issued.
#'
#' Ensure that the \code{fields} parameter contains valid field names as specified in the guide below. Invalid fields will result in an error.
#'
#' @section Field Names Guide:
#' The following are the available fields you can request from ClinicalTrials.gov:
#'   \code{NCT Number},
#'   \code{Study Title},
#'   \code{Study URL},
#'   \code{Acronym},
#'   \code{Study Status},
#'   \code{Brief Summary},
#'   \code{Study Results},
#'   \code{Conditions},
#'   \code{Interventions},
#'   \code{Primary Outcome Measures},
#'   \code{Secondary Outcome Measures},
#'   \code{Other Outcome Measures},
#'   \code{Sponsor},
#'   \code{Collaborators},
#'   \code{Sex},
#'   \code{Age},
#'   \code{Phases},
#'   \code{Enrollment},
#'   \code{Funder Type},
#'   \code{Study Type},
#'   \code{Study Design},
#'   \code{Other IDs},
#'   \code{Start Date},
#'   \code{Primary Completion Date},
#'   \code{Completion Date},
#'   \code{First Posted},
#'   \code{Results First Posted},
#'   \code{Last Update Posted},
#'   \code{Locations},
#'   \code{Study Documents}
#'

ctg_get_nct <- function(nct_ids, fields = NULL) {
  nct_ids <- .validate_nct_ids(nct_ids)

  all_fields <- c(
    "NCT Number", "Study Title", "Study URL", "Acronym", "Study Status",
    "Brief Summary", "Study Results", "Conditions", "Interventions",
    "Primary Outcome Measures", "Secondary Outcome Measures",
    "Other Outcome Measures", "Sponsor", "Collaborators", "Sex",
    "Age", "Phases", "Enrollment", "Funder Type", "Study Type",
    "Study Design", "Other IDs", "Start Date", "Primary Completion Date",
    "Completion Date", "First Posted", "Results First Posted",
    "Last Update Posted", "Locations", "Study Documents"
  )

  if (is.null(fields)) {
    fields <- all_fields
  } else {
    if (!is.character(fields) || anyNA(fields) || length(fields) == 0L) {
      .abort_clintrialx(
        "'fields' must be a non-empty character vector without missing values",
        class = "ctg_validation_error",
        argument = "fields"
      )
    }
    fields <- unique(fields)
    invalid_fields <- setdiff(fields, all_fields)
    if (length(invalid_fields) > 0L) {
      .abort_clintrialx(
        paste0("Invalid fields specified: ", paste(invalid_fields, collapse = ", ")),
        class = "ctg_validation_error",
        argument = "fields",
        invalid = invalid_fields
      )
    }
  }

  progress_bar <- if (interactive()) {
    progress::progress_bar$new(
      format = "[:bar] :current/:total (:percent) Fetching :id",
      total = length(nct_ids),
      clear = FALSE
    )
  } else {
    NULL
  }
  on.exit({
    if (!is.null(progress_bar)) progress_bar$terminate()
  }, add = TRUE)

  failed_ids <- character()

  fetch_single <- function(nct_id) {
    if (!is.null(progress_bar)) progress_bar$tick(tokens = list(id = nct_id))

    response <- tryCatch(
      .api_request(
        paste0(.ctg_studies_url, "/", nct_id),
        query_params = list(format = "csv", fields = paste(fields, collapse = "|")),
        accept = "text/csv"
      ),
      ctg_http_error = function(e) {
        failed_ids <<- c(failed_ids, nct_id)
        .warn_clintrialx(
          paste0("Failed to fetch data for ", nct_id, ": ", conditionMessage(e)),
          class = "ctg_partial_result",
          nct_id = nct_id,
          parent = e
        )
        NULL
      }
    )

    if (is.null(response)) {
      return(NULL)
    }
    .parse_csv_response(response)
  }

  all_data <- lapply(nct_ids, fetch_single)
  all_data <- Filter(Negate(is.null), all_data)

  if (length(all_data) == 0L) {
    .abort_clintrialx(
      paste0("Failed to fetch every requested NCT ID: ", paste(failed_ids, collapse = ", ")),
      class = "ctg_http_error",
      failed_ids = failed_ids
    )
  }

  combined_data <- dplyr::bind_rows(all_data)

  if (!all(colnames(combined_data) %in% fields)) {
    .warn_clintrialx(
      "Some response column names do not match the requested fields",
      class = "ctg_parse_warning"
    )
  }

  tibble::as_tibble(combined_data)
}
