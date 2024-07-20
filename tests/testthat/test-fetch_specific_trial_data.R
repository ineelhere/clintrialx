library(testthat)

test_that("fetch_specific_trial_data returns correct columns", {
  # Test with default fields (all fields)
  result <- fetch_specific_trial_data("NCT04000165")

  expected_columns <- c(
    "NCT Number", "Study Title", "Study URL", "Acronym", "Study Status",
    "Brief Summary", "Study Results", "Conditions", "Interventions",
    "Primary Outcome Measures", "Secondary Outcome Measures",
    "Other Outcome Measures", "Sponsor", "Collaborators", "Sex",
    "Age", "Phases", "Enrollment", "Funder Type", "Study Type",
    "Study Design", "Other IDs", "Start Date", "Primary Completion Date",
    "Completion Date", "First Posted", "Results First Posted",
    "Last Update Posted", "Locations", "Study Documents"
  )

  expect_true(all(expected_columns %in% colnames(result)))

  # Test with specific fields
  specific_fields <- c("NCT Number", "Study Title", "Study Status")
  result_specific <- fetch_specific_trial_data("NCT04000165", fields = specific_fields)

  expect_true(all(specific_fields %in% colnames(result_specific)))
  expect_equal(length(colnames(result_specific)), length(specific_fields))

  # Test with multiple NCT IDs
  result_multiple <- fetch_specific_trial_data(c("NCT04000165", "NCT04002440"))
  expect_true(all(expected_columns %in% colnames(result_multiple)))
})

test_that("fetch_specific_trial_data handles invalid fields", {
  expect_error(
    fetch_specific_trial_data("NCT04000165", fields = c("Invalid Field")),
    "Invalid fields specified: Invalid Field"
  )
})
