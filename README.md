
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `ClinTrialX`

<!-- badges: start -->

[![R-CMD-check](https://github.com/ineelhere/clintrialx/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ineelhere/clintrialx/actions/workflows/R-CMD-check.yaml)
[![License:
Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![pkgdown](https://img.shields.io/badge/pkgdown-docs-blue.svg)](https://ineelhere.github.io/clintrialx/)
[![Visitors](https://api.visitorbadge.io/api/visitors?path=https%3A%2F%2Fgithub.com%2Fineelhere%2Fclintrialx&label=Visitors&labelColor=%23f47373&countColor=%2337d67a&style=flat&labelStyle=upper)](https://github.com/ineelhere/clintrialx)

[![Data Sources:
ClinicalTrials.gov](https://img.shields.io/badge/Data_Sources-ClinicalTrials.gov-blue)](https://clinicaltrials.gov/data-api/api)
[![Data Sources: CTTI
AACT](https://img.shields.io/badge/Data_Sources-CTTI%20AACT%20-purple)](https://aact.ctti-clinicaltrials.org/)

<!-- badges: end -->

The goal of `{clintrialx}` is to fetch clinical trials data from freely
available registries. Currently, it supports querying the

- [ClinicalTrials.gov](https://clinicaltrials.gov/) registry using its
  [V2 API](https://clinicaltrials.gov/data-api/api) and

- [CTTI AACT](https://aact.ctti-clinicaltrials.org/) (Public Access to
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

## Setup AACT account

#### `Only if you wish to use AACT as a source for the data`

- Visit <https://aact.ctti-clinicaltrials.org/users/sign_up>

- Sign up and create an account. It’s free.

- The `username` and `password` will be needed to fetch data using this
  package.

- Save it in a `.Renviron` file, for example-

  ``` r
  user =  "random_name"
  password = "random_password"
  ```

- Now that the file is created, load the variable with the command
  `readRenviron("path/to/.Renviron)`

- You’re all set!

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
#>  1 NCT04487080  A Study of A… https://cl… MARIPO… ACTIVE_NOT_RE… "The purpose o…
#>  2 NCT05687266  Phase III, O… https://cl… AVANZAR RECRUITING     "This is a Pha…
#>  3 NCT02763566  A Study of A… https://cl… MONARC… ACTIVE_NOT_RE… "The main purp…
#>  4 NCT05104866  A Phase-3, O… https://cl… <NA>    ACTIVE_NOT_RE… "The study wil…
#>  5 NCT03778957  A Global Stu… https://cl… EMERAL… ACTIVE_NOT_RE… "A global stud…
#>  6 NCT06472076  A Study of B… https://cl… <NA>    RECRUITING     "The goal of t…
#>  7 NCT05348876  A Study to L… https://cl… <NA>    RECRUITING     "Researchers a…
#>  8 NCT06120491  Saruparib (A… https://cl… EvoPAR… RECRUITING     "The intention…
#>  9 NCT04884360  D9319C00001-… https://cl… MONO-O… RECRUITING     "This is a Pha…
#> 10 NCT04035486  A Study of O… https://cl… FLAURA2 ACTIVE_NOT_RE… "The reason fo…
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
#>        nct_id                                 source enrollment
#> 1 NCT00977600                                  Amgen         24
#> 2 NCT05340751 Hospital for Special Surgery, New York         35
#> 3 NCT01125254         University of Campinas, Brazil         10
#> 4 NCT02216851                           Galderma R&D        132
#> 5 NCT06376851                        HeartFlow, Inc.      10000
#>            overall_status
#> 1               COMPLETED
#> 2               COMPLETED
#> 3               COMPLETED
#> 4               COMPLETED
#> 5 ENROLLING_BY_INVITATION
```

## Data Sources

You can fetch version information directly from the package:

``` r
version_info(source = "clinicaltrials.gov")
#> API version: 2.0.3
#> Timestamp: 2024-07-24 11:12:51
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
