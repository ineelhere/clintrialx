#' Connect to AACT PostgreSQL database
#'
#' @param user Database username
#' @param password Database password
#' @return A connection object to the AACT database
#' @examples
#' # Set environment variables for database credentials in .Renviron and load it
#' # readRenviron(".Renviron")
#'
#' # Connect to the database
#' con <- aact_connection(Sys.getenv('user'), Sys.getenv('password'))
#' @export
aact_connection <- function(user, password) {
  con <- dbConnect(
    drv = dbDriver("PostgreSQL"),
    dbname = "aact",
    host = "aact-db.ctti-clinicaltrials.org",
    port = 5432,
    user = user,
    password = password
  )
  return(con)
}

#' Check database connection
#'
#' @param con Database connection object
#' @return A data frame with distinct study types
#' @examples
#' # Set environment variables for database credentials in .Renviron and load it
#' # readRenviron(".Renviron")
#'
#' # Connect to the database
#' con <- aact_connection(Sys.getenv('user'), Sys.getenv('password'))
#'
#' # Check the connection
#' aact_check_connection(con)
#' @export
aact_check_connection <- function(con) {
  df <- dbGetQuery(con, "select distinct study_type from studies")
  if (length(df) > 0) {
    message("The connection works! Here is a result of a simple query - select distinct study_type from studies")
  }
  return(df)
}

#' Run a custom query
#'
#' @param con Database connection object
#' @param query SQL query string
#' @return A data frame with the query results
#' Check database schema here - https://aact.ctti-clinicaltrials.org/documentation/aact_schema.png
#' @examples
#' # Set environment variables for database credentials in .Renviron and load it
#' # readRenviron(".Renviron")
#'
#' # Connect to the database
#' con <- aact_connection(Sys.getenv('user'), Sys.getenv('password'))
#'
#' # Run a custom query
#' query <- "SELECT nct_id, source, enrollment, overall_status FROM studies LIMIT 5;"
#' results <- aact_custom_query(con, query)
#'
#' # Print the results
#' print(results)
#' @export
aact_custom_query <- function(con, query) {
  df <- dbGetQuery(con, query)
  return(df)
}
