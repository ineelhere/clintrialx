#' Generate a Comprehensive Clinical Trial Data Report
#'
#' The `ctg_data_report` function generates an HTML report that provides a comprehensive analysis of clinical trial data.
#' The report includes summary statistics, visualizations, and optional data quality assessment, with the ability to customize
#' the appearance and content.
#'
#' @param ctg_data A `data.frame` containing clinical trial data. The data frame should include columns such as 'Study Status',
#' 'Enrollment', 'Phases', 'Start Date', 'Completion Date', and others relevant to clinical trials.
#' @param title A `character` string specifying the title of the report. Default is "Clinical Trial Data Report".
#' @param author A `character` string specifying the author of the report. Default is "Author Name".
#' @param output_file A `character` string specifying the file path for the output HTML report. Default is "./report.html".
#' @param color_palette A `character` vector of hex color codes used for plots in the report. Default is a six-color palette.
#' @param theme A `character` string specifying the Bootstrap theme for the HTML report. Available options include "default",
#' "cerulean", "journal", "flatly", "readable", "spacelab", "united", "cosmo", "lumen", "paper", "sandstone", "simplex", and "yeti".
#' Default is "cerulean".
#' @param include_data_quality A `logical` value indicating whether to include a data quality assessment section in the report.
#' Default is `TRUE`.
#' @param include_interactive_plots A `logical` value indicating whether to include interactive plots using `plotly`. If `FALSE`,
#' static `ggplot2` plots will be used. Default is `TRUE`.
#' @param custom_footer A `character` string specifying custom HTML content for the footer of the report. If `NULL`, a default
#' footer will be included. Default is `NULL`.
#'
#' @details
#' The function first checks for the necessary packages and prompts the user to install any missing packages. It then loads
#' the required libraries and validates the provided theme. The report content is generated dynamically, with sections
#' for summary statistics, data overview, data quality assessment (optional), and visualizations of study status distribution,
#' enrollment by phase, study duration, and funding sources. The report is saved as an HTML file.
#'
#' The visualizations include:
#' \itemize{
#'   \item \strong{Study Status Distribution:} A bar chart showing the distribution of study statuses.
#'   \item \strong{Enrollment by Study Phase:} A boxplot of enrollment numbers across different study phases.
#'   \item \strong{Study Duration Timeline:} A scatter plot of study durations over time.
#'   \item \strong{Funding Sources and Study Types:} A stacked bar chart showing the proportion of study types by funder.
#' }
#'
#' @return None. The function generates an HTML report and saves it to the specified `output_file` location.
#'
#' @note Ensure that the `ctg_data` data frame contains all the necessary columns for accurate report generation. The function
#' dynamically generates the report content based on the provided data and parameters.
#'
#' @examples
#' \dontrun{
#' # Assuming `clinical_data` is a data frame with the required columns:
#' ctg_data_report(ctg_data = clinical_data,
#'                 title = "My Clinical Trial Report",
#'                 author = "John Doe",
#'                 output_file = "./my_report.html",
#'                 color_palette = c("#1f77b4", "#ff7f0e"),
#'                 theme = "flatly",
#'                 include_data_quality = TRUE,
#'                 include_interactive_plots = FALSE,
#'                 custom_footer = "<p>Custom footer text</p>")
#' }
#'
#' @import rmarkdown ggplot2 plotly dplyr lubridate reactable scales RColorBrewer htmltools
#' @export
ctg_data_report <- function(ctg_data,
                            title = "Clinical Trial Data Report",
                            author = "Author Name",
                            output_file = "./report.html",
                            color_palette = c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b"),
                            theme = "cerulean",
                            include_data_quality = TRUE,
                            include_interactive_plots = TRUE,
                            custom_footer = NULL) {
  # List of required packages
  required_packages <- c("rmarkdown", "ggplot2", "plotly", "dplyr", "lubridate", "reactable", "scales", "RColorBrewer", "htmltools")

  # Function to check if a package is installed
  is_installed <- function(package) {
    return(package %in% rownames(installed.packages()))
  }

  # Check which packages are missing
  missing_packages <- required_packages[!sapply(required_packages, is_installed)]

  # If there are missing packages, print a message and offer to install them
  if (length(missing_packages) > 0) {
    cat("The following packages are required but not installed:\n")
    cat(paste("-", missing_packages, collapse = "\n"), "\n\n")

    install_choice <- readline(prompt = "Would you like to install these packages now? (yes/no): ")

    if (tolower(install_choice) == "yes") {
      install.packages(missing_packages)
      cat("\nPackages installed successfully.\n")
    } else {
      cat("\nPlease install the missing packages before running the report generation function.\n")
      return()
    }
  } else {
    cat("All required packages are already installed.\n")
  }

  # Load all required packages
  lapply(required_packages, library, character.only = TRUE)

  cat("\nAll necessary packages are now loaded and ready to use.\n")

  # Available themes
  available_themes <- c("default", "cerulean", "journal", "flatly", "readable", "spacelab", "united", "cosmo", "lumen", "paper", "sandstone", "simplex", "yeti")

  # Check if the provided theme is valid
  if (!(theme %in% available_themes)) {
    cat("Invalid theme selected. Available themes are:\n")
    cat(paste("-", available_themes, collapse = "\n"), "\n\n")
    theme_choice <- readline(prompt = "Please choose a valid theme: ")
    theme <- match.arg(theme_choice, available_themes)
  }

  # Create a temporary Rmd file
  temp_rmd <- tempfile(fileext = ".Rmd")

  # Prepare summary statistics
  total_studies <- nrow(ctg_data)
  most_common_status <- names(which.max(table(ctg_data$`Study Status`)))
  avg_enrollment <- round(mean(ctg_data$Enrollment, na.rm = TRUE), 0)

  # Function to generate more colors if needed
  get_colors <- function(n) {
    if (n <= length(color_palette)) {
      return(color_palette[1:n])
    } else {
      return(colorRampPalette(color_palette)(n))
    }
  }

  # Function to truncate long text
  truncate_text <- function(text, max_chars = 50) {
    ifelse(nchar(text) > max_chars,
           paste0(substr(text, 1, max_chars), "..."),
           text)
  }

  # Prepare custom footer
  footer_content <- if (!is.null(custom_footer)) {
    paste0('\n\n<div class="footer">\n', custom_footer, '\n</div>\n')
  } else {
    '\n\n<div class="footer">\nAutomated report generated using <a href="https://ineelhere.github.io/clintrialx">ClinTrialX</a> package\n</div>\n'
  }

  # Write the Rmd content dynamically
  rmd_content <- paste0("
---
title: '", title, "'
author: '", author, "'
date: '`r format(Sys.Date(), \"%B %d, %Y\")`'
output:
  html_document:
    theme: ", theme, "
    highlight: tango
    toc: true
    toc_float: true
    code_folding: hide
---

<style>
.footer {
  position: fixed;
  left: 0;
  bottom: 0;
  width: 100%;
  background-color: #f1f1f1;
  color: black;
  text-align: center;
  padding: 10px 0;
}
</style>

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE)
library(ggplot2)
library(plotly)
library(dplyr)
library(lubridate)
library(reactable)
library(scales)
library(RColorBrewer)
library(htmltools)

color_palette <- c('", paste(color_palette, collapse = "', '"), "')

get_colors <- function(n) {
  if (n <= length(color_palette)) {
    return(color_palette[1:n])
  } else {
    return(colorRampPalette(color_palette)(n))
  }
}

truncate_text <- function(text, max_chars = 50) {
  ifelse(nchar(text) > max_chars,
         paste0(substr(text, 1, max_chars), '...'),
         text)
}
```

## Executive Summary

This report provides a comprehensive analysis of clinical trial data. Key highlights include:

- Total number of studies: ", total_studies, "
- Most common study status: ", most_common_status, "
- Average enrollment: ", avg_enrollment, " participants

## Data Overview

```{r}
reactable(
  ctg_data,
  filterable = TRUE,
  searchable = TRUE,
  bordered = TRUE,
  striped = TRUE,
  highlight = TRUE,
  compact = TRUE,
  defaultPageSize = 10,
  columns = list(
    `Study Status` = colDef(
      style = function(value) {
        status_colors <- get_colors(length(unique(ctg_data$`Study Status`)))
        color <- status_colors[match(value, unique(ctg_data$`Study Status`))]
        list(background = color, color = 'white')
      }
    ),
    Enrollment = colDef(
      format = colFormat(separators = TRUE)
    ),
    `Start Date` = colDef(
      format = colFormat(date = TRUE)
    ),
    `Completion Date` = colDef(
      format = colFormat(date = TRUE)
    )
  ),
  defaultColDef = colDef(
    cell = function(value) {
      if (is.character(value)) {
        value <- truncate_text(value)
      }
      value
    },
    minWidth = 100
  )
)
```

## Data Quality Assessment

", if(include_data_quality) "
```{r}
missing_data <- sapply(ctg_data, function(x) sum(is.na(x)))
missing_data_ctg_data <- data.frame(Variable = names(missing_data),
                              MissingCount = missing_data,
                              PercentMissing = missing_data / nrow(ctg_data) * 100)
missing_data_ctg_data <- missing_data_ctg_data[order(-missing_data_ctg_data$PercentMissing), ]

ggplot(missing_data_ctg_data, aes(x = reorder(Variable, -PercentMissing), y = PercentMissing)) +
  geom_bar(stat = 'identity', fill = color_palette[1]) +
  theme_minimal() +
  labs(title = 'Percentage of Missing Data by Variable',
       x = 'Variable',
       y = 'Percent Missing') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(labels = scales::percent_format(scale = 1))
```

The chart above shows the percentage of missing data for each variable. Variables with high percentages of missing data may require further investigation or imputation techniques.
" else "Data quality assessment was not included in this report.",
  "

## Study Status Distribution

```{r}
status_counts <- table(ctg_data$`Study Status`)
status_ctg_data <- data.frame(status = names(status_counts), count = as.numeric(status_counts))

n_colors <- nrow(status_ctg_data)
status_colors <- get_colors(n_colors)

p <- ggplot(status_ctg_data, aes(x = reorder(status, -count), y = count, fill = status)) +
  geom_bar(stat = 'identity') +
  theme_minimal() +
  labs(title = 'Distribution of Study Statuses',
       x = 'Study Status',
       y = 'Count') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = 'none') +
  scale_fill_manual(values = status_colors) +
  geom_text(aes(label = count), vjust = -0.5)

", if(include_interactive_plots) "ggplotly(p)" else "print(p)", "
```

This chart shows the distribution of study statuses. The most common status is '", most_common_status, "' with ", max(table(ctg_data$`Study Status`)), " studies.

## Enrollment by Study Phase

```{r}
phase_counts <- table(ctg_data$Phases)
n_colors <- length(phase_counts)
phase_colors <- get_colors(n_colors)

p <- ggplot(ctg_data, aes(x = Phases, y = Enrollment, fill = Phases)) +
  geom_boxplot(outlier.colour = 'red', outlier.shape = 1) +
  theme_minimal(base_size = 14) +
  labs(title = 'Enrollment by Study Phase',
       x = 'Study Phase',
       y = 'Enrollment') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = 'none') +
  scale_fill_manual(values = phase_colors) +
  scale_y_log10(labels = scales::comma_format())

", if(include_interactive_plots) "ggplotly(p)" else "print(p)", "
```

This boxplot visualizes the distribution of enrollment numbers across different study phases. Note the logarithmic scale on the y-axis to better show the wide range of enrollment numbers.

## Study Duration Timeline

```{r}
ctg_data$start_date <- as.Date(ctg_data$`Start Date`, format = '%Y-%m-%d')
ctg_data$completion_date <- as.Date(ctg_data$`Completion Date`, format = '%Y-%m-%d')
ctg_data$duration <- as.numeric(ctg_data$completion_date - ctg_data$start_date) / 365.25  # Duration in years

status_counts <- table(ctg_data$`Study Status`)
n_colors <- length(status_counts)
status_colors <- get_colors(n_colors)

p <- ggplot(ctg_data, aes(x = start_date, y = duration, color = `Study Status`)) +
  geom_point(alpha = 0.6) +
  theme_minimal() +
  labs(title = 'Study Duration Timeline',
       x = 'Start Date',
       y = 'Study Duration (Years)') +
  scale_color_manual(values = status_colors) +
  scale_x_date(date_labels = '%Y', date_breaks = '1 year') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

", if(include_interactive_plots) "ggplotly(p)" else "print(p)", "
```

This scatter plot shows the relationship between study start dates and durations. Each point represents a study, colored by its status.

## Funding Sources and Study Types

```{r}
ctg_data_summary <- ctg_data %>%
  count(`Funder Type`, `Study Type`) %>%
  group_by(`Funder Type`) %>%
  mutate(prop = n / sum(n))

study_type_counts <- table(ctg_data$`Study Type`)
n_colors <- length(study_type_counts)
study_type_colors <- get_colors(n_colors)

p <- ggplot(ctg_data_summary, aes(x = `Funder Type`, y = prop, fill = `Study Type`)) +
  geom_bar(stat = 'identity', position = 'dodge') +
  theme_minimal() +
  labs(title = 'Funding Sources and Study Types',
       x = 'Funder Type',
       y = 'Proportion') +
  scale_fill_manual(values = study_type_colors) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(labels = scales::percent_format())

", if(include_interactive_plots) "ggplotly(p)" else "print(p)", "
```

This stacked bar chart shows the proportion of different study types for each funder type.

## Conclusion

This report provides a comprehensive overview of the clinical trial data, highlighting key trends in study status, enrollment, duration, and funding. The visualizations offer insights into the distribution and relationships within the data, which can be valuable for decision-making and further analysis.

For any questions or further analysis requests, please contact the report author.

", footer_content, "
")

# Write content to the Rmd file
writeLines(rmd_content, temp_rmd)

# Render the Rmd file to HTML
render(temp_rmd, output_file = output_file, output_dir = dirname(output_file))

# Clean up the temporary file
unlink(temp_rmd)

cat("Report successfully generated at:", normalizePath(output_file), "\n")
}
