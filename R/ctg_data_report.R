#' Generate a Comprehensive Clinical Trial Data Report
#'
#' @description
#' This function creates a detailed, visually appealing HTML report from clinical trial data.
#' It automates the process of data analysis and visualization, providing insights into various
#' aspects of clinical trials such as study status, enrollment, duration, and funding sources.
#'
#' Visit here for an example report - \url{https://www.indraneelchakraborty.com/clintrialx/report.html}.
#' @param ctg_data A data frame containing clinical trial data. Required columns include:
#'   \itemize{
#'     \item \code{Study Status}: Current status of each study (e.g., \code{"Completed"}, \code{"Ongoing"})
#'     \item \code{Enrollment}: Number of participants in each study
#'     \item \code{Start Date}: The date each study began
#'     \item \code{Completion Date}: The date each study ended or is expected to end
#'     \item \code{Phases}: The phase of each clinical trial (e.g., \code{"Phase 1"}, \code{"Phase 2"})
#'     \item \code{Funder Type}: The type of organization funding each study
#'     \item \code{Study Type}: The type of each study (e.g., \code{"Interventional"}, \code{"Observational"})
#'   }
#' @param title Character string. The title of the report.
#'   Default is \code{"Clinical Trial Data Report"}.
#' @param author Character string. The name of the report author.
#'   Default is \code{"Author Name"}.
#' @param output_file Character string. The file path where the HTML report will be saved.
#'   Default is \code{"./report.html"}. You can specify a different path if needed.
#' @param color_palette Character vector. A set of colors to be used in the report's visualizations.
#'   Default is a preset palette of 6 colors. You can provide your own color codes for customization.
#' @param theme Character string. The Bootstrap theme for the HTML report.
#'   Default is \code{"cerulean"}. Other options include \code{"default"}, \code{"journal"},
#'   \code{"flatly"}, \code{"readable"}, \code{"spacelab"}, \code{"united"}, \code{"cosmo"},
#'   \code{"lumen"}, \code{"paper"}, \code{"sandstone"}, \code{"simplex"}, and \code{"yeti"}.
#' @param include_data_quality Logical. Whether to include a data quality assessment section.
#'   Default is \code{TRUE}. Set to \code{FALSE} if you want to skip this section.
#' @param include_interactive_plots Logical. Whether to generate interactive plots using plotly.
#'   Default is \code{TRUE}. Set to \code{FALSE} for static plots, which may be preferred for certain use cases.
#' @param custom_footer Character string or \code{NULL}. A custom footer for the report.
#'   If \code{NULL} (default), a standard footer crediting the ClinTrialX package is used.
#'
#' @return This function doesn't return a value, but generates an HTML report at the specified location.
#'   It prints a message with the path to the generated report upon successful completion.
#'
#' @details
#' The function performs these key steps:
#'
#' 1. Package Management:
#'    \itemize{
#'    \item Checks for required packages and offers to install any that are missing.
#'    \item Required packages: \code{rmarkdown}, \code{ggplot2}, \code{plotly}, \code{dplyr},
#'      \code{lubridate}, \code{reactable}, \code{scales}, \code{RColorBrewer}, \code{htmltools}.
#'      }
#'
#' 2. Report Generation:
#'    \itemize{
#'    \item Creates a temporary R Markdown file with the report content.
#'    \item Includes an executive summary with key statistics.
#'    \item Provides an interactive data table for easy exploration of the dataset.
#'    }
#'
#' 3. Data Visualization:
#'    \itemize{
#'    \item Study Status Distribution: Bar chart showing the count of studies in each status.
#'    \item Enrollment by Study Phase: Box plot displaying enrollment numbers across different study phases.
#'    \item Study Duration Timeline: Scatter plot showing the relationship between study start dates and durations.
#'    \item Funding Sources and Study Types: Stacked bar chart illustrating the proportion of study types for each funder type.
#'    }
#'
#' 4. Optional Sections:
#'    \itemize{
#'    \item Data Quality Assessment: Bar chart showing the percentage of missing data for each variable (if enabled).
#'    \item Interactive Plots: Uses plotly to create interactive versions of all plots (if enabled).
#'    }
#'
#' 5. Report Finalization:
#'    \itemize{
#'    \item Renders the R Markdown file to an HTML report.
#'    \item Cleans up temporary files.
#'    }
#'
#' @section Tips for Users:
#' \itemize{
#' \item Ensure your data frame has all required columns before using this function.
#' \item Experiment with different themes to find the most suitable look for your report.
#' \item If you encounter any package installation issues, you may need to install them manually.
#' \item For large datasets, setting \code{include_interactive_plots = FALSE} may improve performance.
#' \item Custom color palettes can be used to match your organization's branding.
#' \item The generated report is self-contained and can be easily shared or published on the web.
#' }
#'
#' @examples
#' \dontrun{
#' # Basic usage with default settings
#' ctg_data_report(my_clinical_trial_data)
#'
#' # Customized report with specific settings
#' ctg_data_report(
#'   ctg_data = my_clinical_trial_data,
#'   title = "Clinical Trials Analysis",
#'   author = "Indra",
#'   output_file = "reports/clinical_trials.html",
#'   theme = "flatly",
#'   color_palette = c("#4E79A7", "#F28E2B", "#E15759", "#76B7B2", "#59A14F", "#EDC948"),
#'   include_data_quality = TRUE,
#'   include_interactive_plots = TRUE,
#'   custom_footer = "Proprietary report generated by SomeGreatOrg Inc."
#' )
#'
#' # Generate a report with static plots and no data quality assessment
#' ctg_data_report(
#'   my_clinical_trial_data,
#'   title = "Quick Clinical Trial Overview",
#'   include_data_quality = FALSE,
#'   include_interactive_plots = FALSE
#' )
#' }
#'
#' @seealso
#' \url{https://www.indraneelchakraborty.com/clintrialx} for more information about the ClinTrialX package.
#' @importFrom grDevices colorRampPalette
#' @importFrom utils install.packages installed.packages
#' @importFrom rmarkdown render
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
    '\n\n<div class="footer">\nAutomated report generated using <a href="https://www.indraneelchakraborty.com/clintrialx">ClinTrialX</a> package\n</div>\n'
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
