
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `ClinTrialX`

<!-- badges: start -->

[![R-CMD-check](https://github.com/ineelhere/clintrialx/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ineelhere/clintrialx/actions/workflows/R-CMD-check.yaml)
[![License:
Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![pkgdown](https://img.shields.io/badge/pkgdown-docs-blue.svg)](https://ineelhere.github.io/clintrialx/)

<!-- badges: end -->

The goal of `{clintrialx}` is to fetch clinical trials data from freely
available registries. Currently, it supports the ClinicalTrials.gov
registry using its [V2 API](https://clinicaltrials.gov/data-api/api).

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

## Query Data based on NCT IDs

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
fetch_specific_trial_data(c("NCT02967965", "NCT04000165", "NCT01007279", "NCT02376244", "NCT01179776"),
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

## Query Data based on fileds

Supports filtering by condition, location, title keywords, intervention,
and overall status.

``` r
query_clinical_trials(
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
#>  1 NCT05348876  A Study to L… https://cl… <NA>    RECRUITING     "Researchers a…
#>  2 NCT05952557  An Adjuvant … https://cl… CAMBRI… RECRUITING     "This is a Pha…
#>  3 NCT05687266  Phase III, O… https://cl… AVANZAR RECRUITING     "This is a Pha…
#>  4 NCT02763566  A Study of A… https://cl… MONARC… ACTIVE_NOT_RE… "The main purp…
#>  5 NCT04821622  Study of Tal… https://cl… <NA>    ACTIVE_NOT_RE… "The purpose o…
#>  6 NCT03875235  Durvalumab o… https://cl… TOPAZ-1 ACTIVE_NOT_RE… "Durvalumab or…
#>  7 NCT03110562  Bortezomib, … https://cl… BOSTON  ACTIVE_NOT_RE… "This Phase 3,…
#>  8 NCT06120491  Saruparib (A… https://cl… EvoPAR… RECRUITING     "The intention…
#>  9 NCT04884360  D9319C00001-… https://cl… MONO-O… RECRUITING     "This is a Pha…
#> 10 NCT04873362  A Study Eval… https://cl… Astefa… RECRUITING     "This is a Pha…
#> # ℹ 24 more variables: `Study Results` <chr>, Conditions <chr>,
#> #   Interventions <chr>, `Primary Outcome Measures` <chr>,
#> #   `Secondary Outcome Measures` <chr>, `Other Outcome Measures` <chr>,
#> #   Sponsor <chr>, Collaborators <chr>, Sex <chr>, Age <chr>, Phases <chr>,
#> #   Enrollment <dbl>, `Funder Type` <chr>, `Study Type` <chr>,
#> #   `Study Design` <chr>, `Other IDs` <chr>, `Start Date` <date>,
#> #   `Primary Completion Date` <date>, `Completion Date` <date>, …
```

## Data Sources

You can fetch version information directly from the package:

``` r
version_info(source = "clinicaltrials.gov")
#> Clinicaltrials.gov API version: 2.0.3
#> Timestamp: 2024-07-19 11:12:14
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
