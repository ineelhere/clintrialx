#' clintrialx: Connect and Work with Clinical Trials Data Sources
#'
#' @description
#' The clintrialx package simplifies fetching and managing clinical trial data
#' from freely available registries. It supports querying ClinicalTrials.gov
#' using its V2 API and the CTTI AACT (Access to Aggregate Content of
#' ClinicalTrials.gov) PostgreSQL database.
#'
#' @section ClinicalTrials.gov Functions:
#' \describe{
#'   \item{\code{\link{ctg_get_nct}}}{Fetch clinical trial data by one or more NCT IDs}
#'   \item{\code{\link{ctg_get_fields}}}{Search trials with filters (condition, location, status, etc.)}
#'   \item{\code{\link{ctg_bulk_fetch}}}{Bulk download all matching trials with automatic pagination}
#'   \item{\code{\link{ctg_count}}}{Get count of trials matching search criteria}
#'   \item{\code{\link{ctg_data_report}}}{Generate comprehensive HTML reports from trial data}
#' }
#'
#' @section AACT Database Functions:
#' \describe{
#'   \item{\code{\link{aact_connection}}}{Establish connection to the AACT PostgreSQL database}
#'   \item{\code{\link{aact_check_connection}}}{Verify database connection is working}
#'   \item{\code{\link{aact_custom_query}}}{Execute custom SQL queries against the AACT database}
#' }
#'
#' @section Utility Functions:
#' \describe{
#'   \item{\code{\link{version_info}}}{Get API version and timestamp information}
#'   \item{\code{\link{hello}}}{Display a welcome message}
#' }
#'
#' @section Getting Started:
#' For ClinicalTrials.gov queries, no authentication is required:
#' \preformatted{
#' library(clintrialx)
#'
#' # Fetch a specific trial
#' trial <- ctg_get_nct("NCT04000165")
#'
#' # Search for trials
#' trials <- ctg_get_fields(condition = "Cancer", location = "India")
#'
#' # Bulk download
#' all_trials <- ctg_bulk_fetch(condition = "Diabetes")
#' }
#'
#' For AACT database queries, you need to set up credentials:
#' \preformatted{
#' # Save credentials in .Renviron
#' # user = "your_username"
#' # password = "your_password"
#'
#' con <- aact_connection(Sys.getenv('user'), Sys.getenv('password'))
#' results <- aact_custom_query(con, "SELECT * FROM studies LIMIT 10")
#' }
#'
#' @seealso
#' \itemize{
#'   \item ClinicalTrials.gov API: \url{https://clinicaltrials.gov/data-api/api}
#'   \item AACT Database: \url{https://aact.ctti-clinicaltrials.org/}
#'   \item Package website: \url{https://www.indraneelchakraborty.com/clintrialx/}
#' }
#'
#' @docType package
#' @name clintrialx-package
#' @aliases clintrialx
#' @keywords package
"_PACKAGE"
