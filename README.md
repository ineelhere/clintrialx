# clintrialx

[![CRAN status](https://www.r-pkg.org/badges/version/clintrialx)](https://CRAN.R-project.org/package=clintrialx)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/clintrialx)](https://cranlogs.r-pkg.org/downloads/total/last-month/clintrialx)
[![R-CMD-check](https://github.com/ineelhere/clintrialx/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ineelhere/clintrialx/actions/workflows/R-CMD-check.yaml)
[![License: Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](https://opensource.org/license/apache-2-0)
[![Documentation](https://img.shields.io/badge/docs-pkgdown-176B87.svg)](https://www.indraneelchakraborty.com/clintrialx/)

**From a ClinicalTrials.gov question to tidy data—and an optional shareable report—in a few lines of R.**

`clintrialx` provides a focused R interface to:

- [ClinicalTrials.gov](https://clinicaltrials.gov/) through its
  [API v2](https://clinicaltrials.gov/data-api/api); and
- the [CTTI AACT](https://aact.ctti-clinicaltrials.org/) PostgreSQL
  database derived from ClinicalTrials.gov.

Use it to search common trial fields, retrieve specific NCT records,
download complete result sets with cursor-based pagination, run AACT
queries, and create HTML summaries.

## Quick start

```r
library(clintrialx)

trials <- ctg_get_fields(
  condition = "glioblastoma",
  status = c("RECRUITING", "NOT_YET_RECRUITING"),
  page_size = 25
)

trials[c("NCT Number", "Study Title", "Study Status")]
```

ClinicalTrials.gov access does not require an API key.

## Installation

Install the current CRAN release:

```r
install.packages("clintrialx")
```

Install the development version from GitHub:

```r
# install.packages("remotes")
remotes::install_github("ineelhere/clintrialx")
```

## Choose the right function

| Goal | Function |
|---|---|
| Estimate the size of a query | `ctg_count()` |
| Retrieve one page of matching trials | `ctg_get_fields()` |
| Retrieve particular NCT records | `ctg_get_nct()` |
| Retrieve every page of a query | `ctg_bulk_fetch()` |
| Inspect API version and data timestamp | `version_info()` |
| Connect to AACT | `aact_connection()` |
| Run SQL against AACT | `aact_custom_query()` |
| Generate an HTML summary | `ctg_data_report()` |

## Work with ClinicalTrials.gov

### Count before downloading

Use `ctg_count()` to estimate the size of a result set:

```r
trial_count <- ctg_count(
  condition = "breast cancer",
  location = "India",
  status = "RECRUITING"
)

trial_count
```

### Search common fields

`ctg_get_fields()` returns up to 1,000 records as a tibble:

```r
trials <- ctg_get_fields(
  condition = "breast cancer",
  location = "India",
  intervention = "Drug",
  status = c("RECRUITING", "ACTIVE_NOT_RECRUITING"),
  page_size = 100
)
```

`page_size` must be a whole number of at least 1. Values greater than
1,000 are reduced to the API maximum with a warning.

### Retrieve records by NCT ID

```r
selected_trials <- ctg_get_nct(
  c("NCT02967965", "NCT04000165"),
  fields = c(
    "NCT Number",
    "Study Title",
    "Study Status",
    "Sponsor"
  )
)
```

NCT IDs are trimmed, converted to uppercase, validated as `NCT`
followed by eight digits, and de-duplicated while preserving request
order.

### Retrieve all matching pages

```r
all_trials <- ctg_bulk_fetch(
  condition = "glioblastoma",
  status = "RECRUITING"
)
```

Bulk retrieval follows the API's page cursor until no next-page token
remains. Large queries can still take significant time and memory, so
use `ctg_count()` first and narrow the query when practical.

### Check source freshness

```r
source_info <- version_info("clinicaltrials.gov")

source_info$api_version
source_info$timestamp
```

The result is returned as a list, so it can be recorded with analysis
outputs.

## Query AACT

AACT access is optional and requires a free
[AACT account](https://aact.ctti-clinicaltrials.org/users/sign_up).

Store credentials in your user-level `.Renviron` file:

```text
AACT_USER="your_username"
AACT_PASSWORD="your_password"
```

Restart R after editing `.Renviron`, then connect:

```r
library(clintrialx)

results <- local({
  con <- aact_connection(
    user = Sys.getenv("AACT_USER"),
    password = Sys.getenv("AACT_PASSWORD")
  )
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  aact_check_connection(con)
  aact_custom_query(
    con,
    paste(
      "SELECT nct_id, source, enrollment, overall_status",
      "FROM studies",
      "LIMIT 5"
    )
  )
})
```

Never commit `.Renviron` or print credentials in examples, logs, or
issue reports. `aact_custom_query()` executes the SQL supplied to it;
prefer read-only queries unless you explicitly intend otherwise.

## Generate an HTML report

The reporting workflow uses optional visualization packages. Install
them once if needed:

```r
install.packages(c(
  "ggplot2",
  "plotly",
  "reactable",
  "scales",
  "RColorBrewer",
  "htmltools"
))
```

Create a report from the flattened ClinicalTrials.gov data:

```r
trial_data <- ctg_get_fields(
  condition = "glioblastoma",
  page_size = 250
)

dir.create("reports", showWarnings = FALSE)

ctg_data_report(
  ctg_data = trial_data,
  title = "Glioblastoma Trial Landscape",
  author = "Analysis team",
  output_file = "reports/glioblastoma-trials.html",
  theme = "flatly",
  include_data_quality = TRUE,
  include_interactive_plots = TRUE
)
```

See an [example report](https://www.indraneelchakraborty.com/clintrialx/report.html).
The current `custom_footer` parameter is rendered as HTML; only pass
content you trust.

## Reliability and error handling

The development version uses one HTTP path for all ClinicalTrials.gov
requests, including:

- a package user-agent and a finite request timeout;
- retry and jitter for transient failures, including rate limits;
- cursor-based bulk pagination;
- shared input validation; and
- typed conditions such as `ctg_http_error`,
  `ctg_validation_error`, and `ctg_partial_result`.

This makes failures catchable in production scripts:

```r
tryCatch(
  ctg_get_nct("not-an-nct-id"),
  ctg_validation_error = function(error) {
    message("Invalid request: ", conditionMessage(error))
  }
)
```

The package does not add silent usage telemetry.

## Scope and responsible use

`clintrialx` is intentionally focused on ClinicalTrials.gov and AACT.
For multi-register retrieval, registry history, document downloads, or
cross-register de-duplication, consider
[`ctrdata`](https://CRAN.R-project.org/package=ctrdata).

Registry data can be incomplete, delayed, or changed after retrieval.
Record the retrieval date and API version, verify important facts
against the source record, and do not interpret search results as
medical advice or patient-to-trial suitability.

## Contributing

Issues and pull requests are welcome.

1. Fork the [repository](https://github.com/ineelhere/clintrialx).
2. Create a focused branch from `dev`.
3. Add or update offline tests.
4. Run the checks below.
5. Open a pull request against `dev`.

```r
devtools::test()
devtools::check()
```

Routine ClinicalTrials.gov tests use local response fixtures. AACT
integration tests are skipped when credentials are unavailable.

Please use the
[issue tracker](https://github.com/ineelhere/clintrialx/issues) for bug
reports and feature requests.

## Citation

To cite the package in research:

```r
citation("clintrialx")
```

CRAN package DOI: <https://doi.org/10.32614/CRAN.package.clintrialx>

If `clintrialx` helps your work, a GitHub star, a reproducible example,
or a citation makes the project easier for others to discover.
