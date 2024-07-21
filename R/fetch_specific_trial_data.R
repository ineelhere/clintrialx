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
#' @importFrom httr GET content
#' @importFrom readr read_csv cols
#' @importFrom dplyr bind_rows as_tibble
#' @importFrom progress progress_bar
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
  # Base URL for the API
  base_url <- "https://clinicaltrials.gov/api/v2/studies/"

  # Define all available fields
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

  # If fields are not specified, use all fields
  if (is.null(fields)) {
    fields <- all_fields
  } else {
    # Validate user-provided fields
    invalid_fields <- setdiff(fields, all_fields)
    if (length(invalid_fields) > 0) {
      stop("Invalid fields specified: ", paste(invalid_fields, collapse = ", "))
    }
  }

  # Create progress bar
  pb <- progress::progress_bar$new(
    format = "[:bar] :current/:total (:percent) Fetching :id",
    total = length(nct_ids)
  )

  # Function to fetch data for a single NCT ID
  fetch_single <- function(nct_id) {
    # Update progress bar
    pb$tick(tokens = list(id = nct_id))

    # Construct the API URL
    fields_param <- gsub(" ", "%20", paste(fields, collapse = "%7C"))
    url <- paste0(base_url, nct_id, "?format=csv&fields=", fields_param)

    # Make the API request
    response <- httr::GET(url, httr::add_headers("accept" = "text/csv"))

    # Check for successful response
    if (httr::status_code(response) != 200) {
      warning("Failed to fetch data for ", nct_id, ". Status code: ", httr::status_code(response))
      return(NULL)
    }

    # Parse the CSV content
    content <- httr::content(response, "text", encoding = "UTF-8")
    data <- readr::read_csv(content, col_types = readr::cols(.default = "c"))

    return(data)
  }

  # Fetch data for all NCT IDs
  all_data <- lapply(nct_ids, fetch_single)

  # Remove NULL entries (failed fetches)
  all_data <- all_data[!sapply(all_data, is.null)]

  # Combine all data into a single dataframe
  combined_data <- dplyr::bind_rows(all_data)

  # Ensure column names match exactly with the requested fields
  if (!all(colnames(combined_data) %in% fields)) {
    warning("Some column names may not match exactly with the requested fields.")
  }

  return(combined_data)
}
