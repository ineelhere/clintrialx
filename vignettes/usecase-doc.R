## ----eval=FALSE---------------------------------------------------------------
#  # Load required libraries
#  invisible(suppressPackageStartupMessages({
#    library(clintrialx)  # For fetching clinical trial data
#    library(ggplot2)     # For data visualization
#    library(plotly)      # For interactive plots
#    library(dplyr)       # For data manipulation
#    library(lubridate)   # For date handling
#  }))

## ----eval=FALSE---------------------------------------------------------------
#  # Fetch cancer study data in India
#  df <- ctg_bulk_fetch(condition = "cancer", location = "India")

## ----eval=FALSE---------------------------------------------------------------
#  # Create a table of study statuses
#  status_counts <- table(df$`Study Status`)
#  
#  # Convert the table to a data frame
#  status_df <- data.frame(status = names(status_counts), count = as.numeric(status_counts))
#  
#  # Generate the bar plot
#  ggplotly(ggplot(status_df, aes(x = reorder(status, -count), y = count)) +
#    geom_bar(stat = "identity", fill = "orange") +
#    theme_minimal() +
#    labs(title = "Distribution of Study Statuses",
#         x = "Study Status",
#         y = "Count") +
#    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
#    geom_text(aes(label = count), vjust = -0.5))

## ----eval=FALSE---------------------------------------------------------------
#  # Create an interactive box plot of enrollment by study phase
#  ggplotly(ggplot(df, aes(x = Phases, y = Enrollment)) +
#    geom_boxplot(fill = "lightblue", outlier.colour = "red", outlier.shape = 1) +
#    geom_jitter(color = "darkblue", size = 0.5, alpha = 0.5, width = 0.2) +
#    theme_minimal(base_size = 14) +
#    labs(title = "Enrollment by Study Phase",
#         x = "Study Phase",
#         y = "Enrollment") +
#    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
#          plot.title = element_text(hjust = 0.5)))

## ----eval=FALSE---------------------------------------------------------------
#  # Convert date strings to Date objects
#  df$start_date <- as.Date(df$`Start Date`, format = "%Y-%m-%d")
#  df$completion_date <- as.Date(df$`Completion Date`, format = "%Y-%m-%d")
#  
#  # Create a scatter plot with a horizontal line at 2024
#  ggplot(df, aes(x = start_date, y = completion_date, color = `Study Status`)) +
#    geom_point(alpha = 0.6) +
#    geom_hline(yintercept = as.Date("2024-01-01"), linetype = "dashed", color = "blue") +
#    theme_minimal() +
#    labs(title = "Study Duration Timeline",
#         x = "Start Date",
#         y = "Completion Date") +
#    scale_color_brewer(palette = "Set1")

## ----eval=FALSE---------------------------------------------------------------
#  # Summarize and plot funding sources by study type
#  df_summary <- df %>%
#    count(`Funder Type`, `Study Type`) %>%
#    group_by(`Funder Type`) %>%
#    mutate(prop = n / sum(n))
#  
#  ggplotly(ggplot(df_summary, aes(x = `Funder Type`, y = prop, fill = `Study Type`)) +
#    geom_bar(stat = "identity", position = "dodge") +
#    theme_minimal() +
#    labs(title = "Funding Sources and Study Types",
#         x = "Funder Type",
#         y = "Proportion") +
#    scale_fill_brewer(palette = "Set2") +
#    theme(axis.text.x = element_text(angle = 45, hjust = 1)))

