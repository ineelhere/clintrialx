
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `ClinTrialX`

<!-- badges: start -->

[![R-CMD-check](https://github.com/ineelhere/clintrialx/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ineelhere/clintrialx/actions/workflows/R-CMD-check.yaml)
[![License:
Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![pkgdown](https://img.shields.io/badge/pkgdown-docs-blue.svg)](https://ineelhere.github.io/clintrialx/)
![Visitors](https://api.visitorbadge.io/api/visitors?path=https%3A%2F%2Fgithub.com%2Fineelhere%2Fclintrialx&label=Visitors&labelColor=%23f47373&countColor=%2337d67a&style=flat&labelStyle=upper)

![Static
Badge](https://img.shields.io/badge/Data_Sources-ClinicalTrials.gov-blue?link=https%3A%2F%2Fclinicaltrials.gov%2Fdata-api%2Fapi)
![Static
Badge](https://img.shields.io/badge/Data_Sources-CTTI%20AACT%20(Access%20to%20Aggregate%20Content%20of%20ClinicalTrials.gov)-purple?link=https%3A%2F%2Faact.ctti-clinicaltrials.org%2F)

<!-- badges: end -->

The goal of `{clintrialx}` is to fetch clinical trials data from freely
available registries. Currently, it supports the ClinicalTrials.gov
registry using its [V2 API](https://clinicaltrials.gov/data-api/api) and
the [CTTI AACT](https://aact.ctti-clinicaltrials.org/) (Public Access to
Aggregate Content of ClinicalTrials.gov).

## Installation

You can install this package from
[GitHub](https://github.com/ineelhere/clintrialx) with:

``` r
# install.packages("devtools")
devtools::install_github("ineelhere/clintrialx")
```

### Check installation

``` r
library(clintrialx)
```

## Query the [ClinicalTrials.gov](https://clinicaltrials.gov/) Registry

#### Based on NCT IDs

Fetch one or multiple trial records based on NCT IDs. You can opt to
fetch some specific fields or all fields available at source (default).

``` r
library(clintrialx)
#> Loading required package: httr
#> Loading required package: lubridate
#> 
#> Attaching package: 'lubridate'
#> The following objects are masked from 'package:base':
#> 
#>     date, intersect, setdiff, union
#> Loading required package: readr
#> Loading required package: dplyr
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
#> Loading required package: progress
#> Loading required package: RPostgreSQL
#> Loading required package: DBI
ctg_get_nct(c("NCT02967965", "NCT04000165", "NCT01007279", "NCT02376244", "NCT01179776"),
                          fields = c("NCT Number", "Study Title", "Study Status", "Sponsor"))
#> 
#> [=================>--------------------------] 2/5 ( 40%) Fetching
#> NCT04000165[=========================>------------------] 3/5 ( 60%) Fetching
#> NCT01007279[==================================>---------] 4/5 ( 80%) Fetching
#> NCT02376244[============================================] 5/5 (100%) Fetching
#> NCT01179776
#> # A tibble: 5 × 4
#>   `NCT Number` `Study Title`                              `Study Status` Sponsor
#>   <chr>        <chr>                                      <chr>          <chr>  
#> 1 NCT02967965  CARdioprotection in Myocardial Infarction  ACTIVE_NOT_RE… EZUS-L…
#> 2 NCT04000165  A Dose-Finding Study of AG-348 in Sickle … COMPLETED      Nation…
#> 3 NCT01007279  Rosuvastatin in Preventing Myonecrosis in… COMPLETED      Univer…
#> 4 NCT02376244  The Health Impact of High Intensity Exerc… COMPLETED      Liverp…
#> 5 NCT01179776  Ilomedin Treatment for Patients Having Un… COMPLETED      Thromb…
```

#### Based on fileds

Supports filtering by condition, location, title keywords, intervention,
and overall status.

``` r
ctg_get_fields(
     condition = "Cancer",
     location = "Kolkata",
     title = NULL,
     intervention = "Drug",
     status = c("ACTIVE_NOT_RECRUITING", "RECRUITING"),
     page_size = 10
)
#> The Query matches 82 trial records in the ClinicalTrials.gov records.
#> Your query returned 10 trial records.
#> # A tibble: 10 × 30
#>    `NCT Number` `Study Title` `Study URL` Acronym `Study Status` `Brief Summary`
#>    <chr>        <chr>         <chr>       <chr>   <chr>          <chr>          
#>  1 NCT01932125  An Intervent… https://cl… <NA>    ACTIVE_NOT_RE… "This multicen…
#>  2 NCT06472076  A Study of B… https://cl… <NA>    RECRUITING     "The goal of t…
#>  3 NCT04821622  Study of Tal… https://cl… <NA>    ACTIVE_NOT_RE… "The purpose o…
#>  4 NCT04884360  D9319C00001-… https://cl… MONO-O… RECRUITING     "This is a Pha…
#>  5 NCT03110562  Bortezomib, … https://cl… BOSTON  ACTIVE_NOT_RE… "This Phase 3,…
#>  6 NCT04487080  A Study of A… https://cl… MARIPO… ACTIVE_NOT_RE… "The purpose o…
#>  7 NCT02763566  A Study of A… https://cl… MONARC… ACTIVE_NOT_RE… "The main purp…
#>  8 NCT05687266  Phase III, O… https://cl… AVANZAR RECRUITING     "This is a Pha…
#>  9 NCT05894239  A Study to E… https://cl… <NA>    RECRUITING     "This study wi…
#> 10 NCT05501886  Gedatolisib … https://cl… VIKTOR… RECRUITING     "This is a Pha…
#> # ℹ 24 more variables: `Study Results` <chr>, Conditions <chr>,
#> #   Interventions <chr>, `Primary Outcome Measures` <chr>,
#> #   `Secondary Outcome Measures` <chr>, `Other Outcome Measures` <chr>,
#> #   Sponsor <chr>, Collaborators <chr>, Sex <chr>, Age <chr>, Phases <chr>,
#> #   Enrollment <dbl>, `Funder Type` <chr>, `Study Type` <chr>,
#> #   `Study Design` <chr>, `Other IDs` <chr>, `Start Date` <date>,
#> #   `Primary Completion Date` <date>, `Completion Date` <date>, …
```

## Query the [CTTI AACT](https://aact.ctti-clinicaltrials.org/)

#### Run Custom Queries

``` r
# Set environment variables for database credentials in .Renviron and load it
# readRenviron(".Renviron")

# Connect to the database
con <- aact_connection(Sys.getenv('user'), Sys.getenv('password'))

# Run a custom query
query <- "SELECT nct_id, source, enrollment, overall_status FROM studies LIMIT 5;"
results <- aact_custom_query(con, query)

# Print the results
print(results)
#>        nct_id                                               source enrollment
#> 1 NCT03787862      University of Texas Southwestern Medical Center          0
#> 2 NCT00528762                          M.D. Anderson Cancer Center         37
#> 3 NCT00991562                                      ImmunoGen, Inc.         50
#> 4 NCT04370080                Roseman University of Health Sciences         63
#> 5 NCT04680611 University Hospital Southampton NHS Foundation Trust        120
#>   overall_status
#> 1      WITHDRAWN
#> 2      COMPLETED
#> 3      COMPLETED
#> 4      COMPLETED
#> 5     RECRUITING
```

## Data Sources

You can fetch version information directly from the package:

``` r
version_info(source = "clinicaltrials.gov")
#> Clinicaltrials.gov API version: 2.0.3
#> Timestamp: 2024-07-23 11:12:33
```

## Get Involved

🚀 **Ready to contribute?** We welcome contributions to make
`clintrialx` even better. Check out our [contributing
guidelines](https://github.com/ineelhere/clintrialx/blob/main/CONTRIBUTING.md)
to get started.

💬 **Questions or Feedback?** Feel free to open an issue on our [GitHub
Issues page](https://github.com/ineelhere/clintrialx/issues).

🌟 **Enjoying `clintrialx`?** Please consider giving us a star on
[GitHub](https://github.com/ineelhere/clintrialx)! Your support helps us
grow and improve.

More updates to come. Happy coding! 🎉
