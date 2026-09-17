# clintrialx 0.1.1

## Improvements
- Enhanced error handling for API requests
- Improved input validation across all functions
- Code refactoring for better maintainability

## Bug Fixes
- Fixed inconsistent return values in `version_info()`
- Improved handling of paginated responses in bulk fetch

# clintrialx 0.1.0

## New Features
- Initial CRAN release
- `ctg_get_nct()`: Fetch clinical trial data by NCT ID(s)
- `ctg_get_fields()`: Search trials with multiple filter options
- `ctg_bulk_fetch()`: Bulk download all matching trials with pagination support
- `ctg_count()`: Get count of trials matching search criteria
- `ctg_data_report()`: Generate comprehensive HTML reports from trial data
- `aact_connection()`: Connect to CTTI AACT PostgreSQL database
- `aact_check_connection()`: Verify database connection
- `aact_custom_query()`: Run custom SQL queries on AACT database
- `version_info()`: Get API version information

## Data Sources
- ClinicalTrials.gov API v2 support
- CTTI AACT database support
