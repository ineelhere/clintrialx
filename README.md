
<!-- README.md is generated from README.Rmd. Please edit that file -->

# clintrialx

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

You can install this package from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ineelhere/clintrialx")
```

## Example

This is a basic example that shows how to download data based on NCT
ID(s):

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
fetch_specific_trial_data("NCT04000165")
#> # A tibble: 1 × 30
#>   `NCT Number` `Study Title`  `Study URL` Acronym `Study Status` `Brief Summary`
#>   <chr>        <chr>          <chr>       <chr>   <chr>          <chr>          
#> 1 NCT04000165  A Dose-Findin… https://cl… <NA>    COMPLETED      "Background:\n…
#> # ℹ 24 more variables: `Study Results` <chr>, Conditions <chr>,
#> #   Interventions <chr>, `Primary Outcome Measures` <chr>,
#> #   `Secondary Outcome Measures` <chr>, `Other Outcome Measures` <chr>,
#> #   Sponsor <chr>, Collaborators <chr>, Sex <chr>, Age <chr>, Phases <chr>,
#> #   Enrollment <chr>, `Funder Type` <chr>, `Study Type` <chr>,
#> #   `Study Design` <chr>, `Other IDs` <chr>, `Start Date` <chr>,
#> #   `Primary Completion Date` <chr>, `Completion Date` <chr>, …
```

Fetch only a few/specific fields:

``` r
library(clintrialx)
fetch_specific_trial_data("NCT04000165", fields = c("NCT Number", "Study Title", "Study Status", "Sponsor"))
#> # A tibble: 1 × 4
#>   `NCT Number` `Study Title`                              `Study Status` Sponsor
#>   <chr>        <chr>                                      <chr>          <chr>  
#> 1 NCT04000165  A Dose-Finding Study of AG-348 in Sickle … COMPLETED      Nation…
```

You can also download data for multiple NCT IDs:

``` r
library(clintrialx)
fetch_specific_trial_data(c("NCT02967965", "NCT04000165", "NCT01007279", "NCT02376244", "NCT01179776"))
#> [=================>--------------------------] 2/5 ( 40%) Fetching
#> NCT04000165[=========================>------------------] 3/5 ( 60%) Fetching
#> NCT01007279[==================================>---------] 4/5 ( 80%) Fetching
#> NCT02376244[============================================] 5/5 (100%) Fetching
#> NCT01179776
#> # A tibble: 5 × 30
#>   `NCT Number` `Study Title`  `Study URL` Acronym `Study Status` `Brief Summary`
#>   <chr>        <chr>          <chr>       <chr>   <chr>          <chr>          
#> 1 NCT02967965  CARdioprotect… https://cl… CARIM   ACTIVE_NOT_RE… "CARIM is a pr…
#> 2 NCT04000165  A Dose-Findin… https://cl… <NA>    COMPLETED      "Background:\n…
#> 3 NCT01007279  Rosuvastatin … https://cl… ROMA    COMPLETED      "An increase i…
#> 4 NCT02376244  The Health Im… https://cl… <NA>    COMPLETED      "Cardiac rehab…
#> 5 NCT01179776  Ilomedin Trea… https://cl… <NA>    COMPLETED      "Acute myocard…
#> # ℹ 24 more variables: `Study Results` <chr>, Conditions <chr>,
#> #   Interventions <chr>, `Primary Outcome Measures` <chr>,
#> #   `Secondary Outcome Measures` <chr>, `Other Outcome Measures` <chr>,
#> #   Sponsor <chr>, Collaborators <chr>, Sex <chr>, Age <chr>, Phases <chr>,
#> #   Enrollment <chr>, `Funder Type` <chr>, `Study Type` <chr>,
#> #   `Study Design` <chr>, `Other IDs` <chr>, `Start Date` <chr>,
#> #   `Primary Completion Date` <chr>, `Completion Date` <chr>, …
```

Similarly, you can query only desired fields:

``` r
library(clintrialx)
fetch_specific_trial_data(c("NCT02967965", "NCT04000165", "NCT01007279", "NCT02376244", "NCT01179776"),
                          fields = c("NCT Number", "Study Title", "Study Status", "Sponsor"))
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

## Data Sources

You can fetch version information directly from the package:

``` r
library(clintrialx)
version_info(source = "clinicaltrials.gov")
#> Clinicaltrials.gov API version: 2.0.3
#> Timestamp: 2024-07-19 11:12:14
```

## Get Involved

🚀 **Ready to contribute?** We welcome contributions to make
`clintrialx` even better. Check out [contributing
guidelines](https://github.com/ineelhere/clintrialx/blob/main/CONTRIBUTING.md)
to get started.

💬 **Questions or Feedback?** Feel free to open an issue on [GitHub
Issues page](https://github.com/ineelhere/clintrialx/issues).

🌟 **Enjoying `clintrialx`?** Please consider giving a star on
[GitHub](https://github.com/ineelhere/clintrialx)! Your support helps
this project grow and improve.

More updates to come. Happy coding! 🎉
