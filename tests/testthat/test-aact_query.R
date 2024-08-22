# Test for aact_connection function
test_that("aact_connection function works correctly", {
  skip_on_cran() # Skip on CRAN

  # Mock credentials
  user <- Sys.getenv('user')
  password <- Sys.getenv('password')

  # Skip if credentials are not set
  if (user == "" || password == "") {
    skip("Database credentials are not set in the environment.")
  }

  # Test connection
  con <- aact_connection(user, password)

  # Check if connection is a PostgreSQL connection
  expect_s4_class(con, "PostgreSQLConnection")

  # Disconnect after test
  dbDisconnect(con)
})

# Test for aact_check_connection function
test_that("aact_check_connection function works correctly", {
  skip_on_cran() # Skip on CRAN

  # Mock credentials
  user <- Sys.getenv('user')
  password <- Sys.getenv('password')

  # Skip if credentials are not set
  if (user == "" || password == "") {
    skip("Database credentials are not set in the environment.")
  }

  # Establish connection
  con <- aact_connection(user, password)

  # Test check connection
  df <- aact_check_connection(con)

  # Check if df is a data frame
  expect_true(is.data.frame(df))

  # Check if df contains expected column
  expect_true("study_type" %in% colnames(df))

  # Disconnect after test
  dbDisconnect(con)
})

# Test for aact_custom_query function
test_that("aact_custom_query function works correctly", {
  skip_on_cran() # Skip on CRAN

  # Mock credentials
  user <- Sys.getenv('user')
  password <- Sys.getenv('password')

  # Skip if credentials are not set
  if (user == "" || password == "") {
    skip("Database credentials are not set in the environment.")
  }

  # Establish connection
  con <- aact_connection(user, password)

  # Define a custom query
  query <- "SELECT nct_id, source, enrollment, overall_status FROM studies LIMIT 5;"

  # Run the custom query
  results <- aact_custom_query(con, query)

  # Check if results is a data frame
  expect_true(is.data.frame(results))

  # Check if results contains expected columns
  expect_true(all(c("nct_id", "source", "enrollment", "overall_status") %in% colnames(results)))

  # Disconnect after test
  dbDisconnect(con)
})
