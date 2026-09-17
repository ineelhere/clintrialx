#' Internal utility functions for clintrialx
#'
#' @name utils
#' @keywords internal
NULL

.ctg_studies_url <- "https://clinicaltrials.gov/api/v2/studies"
.ctg_version_url <- "https://clinicaltrials.gov/api/v2/version"

.allowed_status <- c(
  "ACTIVE_NOT_RECRUITING",
  "COMPLETED",
  "ENROLLING_BY_INVITATION",
  "NOT_YET_RECRUITING",
  "RECRUITING",
  "SUSPENDED",
  "TERMINATED",
  "WITHDRAWN",
  "AVAILABLE",
  "NO_LONGER_AVAILABLE",
  "TEMPORARILY_NOT_AVAILABLE",
  "APPROVED_FOR_MARKETING",
  "WITHHELD",
  "UNKNOWN"
)

.abort_clintrialx <- function(message, class = "clintrialx_error", ..., call = NULL) {
  condition <- structure(
    c(list(message = message, call = call), list(...)),
    class = c(class, "clintrialx_error", "error", "condition")
  )
  stop(condition)
}

.warn_clintrialx <- function(message, class = "clintrialx_warning", ..., call = NULL) {
  condition <- structure(
    c(list(message = message, call = call), list(...)),
    class = c(class, "clintrialx_warning", "warning", "condition")
  )
  warning(condition)
}

.validate_status <- function(status) {
  if (is.null(status)) {
    return(NULL)
  }
  if (!is.character(status) || anyNA(status)) {
    .abort_clintrialx(
      "'status' must be a character vector without missing values",
      class = "ctg_validation_error",
      argument = "status"
    )
  }

  status <- unique(toupper(trimws(status)))
  status <- status[nzchar(status)]
  invalid_status <- status[!status %in% .allowed_status]

  if (length(invalid_status) > 0L) {
    .warn_clintrialx(
      sprintf(
        "Invalid status value(s) provided: %s\nThese values will be ignored. Allowed values are: %s",
        paste(invalid_status, collapse = ", "),
        paste(.allowed_status, collapse = ", ")
      ),
      class = "ctg_validation_warning",
      argument = "status",
      invalid = invalid_status
    )
  }

  status <- status[status %in% .allowed_status]
  if (length(status) == 0L) NULL else status
}

.validate_page_size <- function(page_size) {
  valid <- is.numeric(page_size) &&
    length(page_size) == 1L &&
    !is.na(page_size) &&
    is.finite(page_size) &&
    page_size == floor(page_size) &&
    page_size >= 1

  if (!valid) {
    .abort_clintrialx(
      "'page_size' must be one finite whole number greater than or equal to 1",
      class = "ctg_validation_error",
      argument = "page_size"
    )
  }

  if (page_size > 1000) {
    .warn_clintrialx(
      "'page_size' cannot exceed 1000 and has been reduced to 1000",
      class = "ctg_validation_warning",
      argument = "page_size",
      supplied = page_size
    )
    page_size <- 1000
  }

  as.integer(page_size)
}

.validate_nonempty_string <- function(value, argument) {
  if (!is.character(value) || length(value) != 1L || is.na(value) ||
      !nzchar(trimws(value))) {
    .abort_clintrialx(
      sprintf("'%s' must be provided as one non-empty character string", argument),
      class = "ctg_validation_error",
      argument = argument
    )
  }
  value
}

.validate_nct_ids <- function(nct_ids) {
  if (is.null(nct_ids) || length(nct_ids) == 0L) {
    .abort_clintrialx(
      "'nct_ids' must be provided and non-empty",
      class = "ctg_validation_error",
      argument = "nct_ids"
    )
  }
  if (!is.character(nct_ids) || anyNA(nct_ids)) {
    .abort_clintrialx(
      "'nct_ids' must be a character vector without missing values",
      class = "ctg_validation_error",
      argument = "nct_ids"
    )
  }

  nct_ids <- toupper(trimws(nct_ids))
  malformed <- !grepl("^NCT[0-9]{8}$", nct_ids)
  if (any(malformed)) {
    .abort_clintrialx(
      sprintf(
        "Malformed NCT ID(s): %s. Expected 'NCT' followed by eight digits (for example, NCT04000165).",
        paste(nct_ids[malformed], collapse = ", ")
      ),
      class = "ctg_validation_error",
      argument = "nct_ids",
      invalid = nct_ids[malformed]
    )
  }

  duplicated_ids <- duplicated(nct_ids)
  if (any(duplicated_ids)) {
    message(
      "Removed duplicate NCT ID(s): ",
      paste(unique(nct_ids[duplicated_ids]), collapse = ", ")
    )
    nct_ids <- nct_ids[!duplicated_ids]
  }

  nct_ids
}

.build_query_params <- function(condition = NULL,
                                location = NULL,
                                title = NULL,
                                intervention = NULL,
                                status = NULL,
                                page_size = NULL,
                                count_total = TRUE) {
  params <- list(
    format = "csv",
    markupFormat = "markdown"
  )

  if (isTRUE(count_total)) params[["countTotal"]] <- "true"
  if (!is.null(page_size)) params[["pageSize"]] <- as.character(page_size)
  if (!is.null(condition)) params[["query.cond"]] <- condition
  if (!is.null(location)) params[["query.locn"]] <- location
  if (!is.null(title)) params[["query.titles"]] <- title
  if (!is.null(intervention)) params[["query.intr"]] <- intervention
  if (!is.null(status) && length(status) > 0L) {
    params[["filter.overallStatus"]] <- paste(status, collapse = "|")
  }

  params
}

.clintrialx_user_agent <- function() {
  version <- tryCatch(
    as.character(utils::packageVersion("clintrialx")),
    error = function(e) "development"
  )
  paste0(
    "clintrialx/", version,
    " (+https://github.com/ineelhere/clintrialx)"
  )
}

.http_retry <- function(...) {
  httr::RETRY(...)
}

.api_request <- function(url,
                         query_params = NULL,
                         max_attempts = 4L,
                         accept = "application/json",
                         timeout = 30) {
  if (!is.character(url) || length(url) != 1L || is.na(url) || !nzchar(url)) {
    .abort_clintrialx(
      "'url' must be one non-empty character string",
      class = "ctg_validation_error",
      argument = "url"
    )
  }
  if (!is.numeric(max_attempts) || length(max_attempts) != 1L ||
      is.na(max_attempts) || max_attempts < 1 || max_attempts != floor(max_attempts)) {
    .abort_clintrialx(
      "'max_attempts' must be one positive whole number",
      class = "ctg_validation_error",
      argument = "max_attempts"
    )
  }
  if (!is.numeric(timeout) || length(timeout) != 1L ||
      is.na(timeout) || !is.finite(timeout) || timeout <= 0) {
    .abort_clintrialx(
      "'timeout' must be one positive finite number",
      class = "ctg_validation_error",
      argument = "timeout"
    )
  }

  response <- tryCatch(
    .http_retry(
      "GET",
      url = url,
      query = query_params,
      httr::accept(accept),
      httr::user_agent(.clintrialx_user_agent()),
      httr::timeout(timeout),
      times = as.integer(max_attempts),
      pause_base = 1,
      pause_cap = 8,
      pause_min = 1,
      quiet = FALSE,
      terminate_on = setdiff(400L:499L, c(408L, 429L))
    ),
    error = function(e) {
      .abort_clintrialx(
        paste0("API request failed: ", conditionMessage(e)),
        class = "ctg_http_error",
        url = url,
        parent = e
      )
    }
  )

  status <- httr::status_code(response)
  if (status < 200L || status >= 300L) {
    reason <- tryCatch(
      httr::http_status(response)$message,
      error = function(e) "HTTP request was unsuccessful"
    )
    .abort_clintrialx(
      sprintf("API request failed with status %d: %s", status, reason),
      class = "ctg_http_error",
      status_code = status,
      url = url
    )
  }

  response
}

.response_header <- function(response, name) {
  response_headers <- httr::headers(response)
  index <- match(tolower(name), tolower(names(response_headers)))
  if (is.na(index)) return(NULL)

  value <- response_headers[[index]]
  if (is.null(value) || length(value) == 0L || is.na(value[[1L]]) ||
      !nzchar(as.character(value[[1L]]))) {
    return(NULL)
  }
  as.character(value[[1L]])
}

.response_total_count <- function(response) {
  value <- .response_header(response, "x-total-count")
  if (is.null(value)) return(NA_real_)
  suppressWarnings(as.numeric(value))
}

.parse_csv_response <- function(response, column_names = NULL) {
  body <- httr::content(response, as = "text", encoding = "UTF-8")
  if (!nzchar(trimws(body))) {
    if (is.null(column_names)) return(tibble::tibble())
    empty <- stats::setNames(
      replicate(length(column_names), character(), simplify = FALSE),
      column_names
    )
    return(tibble::as_tibble(empty))
  }

  parse <- function(...) {
    readr::read_csv(
      I(body),
      ...,
      show_col_types = FALSE,
      progress = FALSE,
      name_repair = "minimal"
    )
  }

  tryCatch({
    if (is.null(column_names)) {
      return(tibble::as_tibble(parse()))
    }

    detected_names <- names(parse(n_max = 0L))
    if (setequal(detected_names, column_names)) {
      parsed <- tibble::as_tibble(parse())
      parsed[, column_names, drop = FALSE]
    } else {
      tibble::as_tibble(parse(col_names = column_names))
    }
  }, error = function(e) {
    .abort_clintrialx(
      paste0("Failed to parse the API CSV response: ", conditionMessage(e)),
      class = "ctg_parse_error",
      parent = e
    )
  })
}

.validate_dataframe_cols <- function(df, required_cols, df_name = "data") {
  if (!is.data.frame(df)) {
    .abort_clintrialx(
      sprintf("'%s' must be a data frame", df_name),
      class = "ctg_validation_error",
      argument = df_name
    )
  }

  missing_cols <- setdiff(required_cols, colnames(df))
  if (length(missing_cols) > 0L) {
    .abort_clintrialx(
      sprintf(
        "'%s' is missing required columns: %s",
        df_name,
        paste(missing_cols, collapse = ", ")
      ),
      class = "ctg_validation_error",
      argument = df_name,
      missing_columns = missing_cols
    )
  }

  invisible(TRUE)
}
