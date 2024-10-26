# Load necessary libraries
library(ggplot2)
library(dplyr)

# Function to read CSV and create bar graph
create_study_time_graph <- function(csv_file) {
  # Read the CSV file
  log_data <- read.csv(csv_file, stringsAsFactors = FALSE)
  
  # Convert Study_Time to minutes
  log_data <- log_data %>%
    mutate(Study_Time_Minutes = as.numeric(sapply(strsplit(Study_Time, ":"), function(x) {
      as.numeric(x[1]) * 60 + as.numeric(x[2]) + as.numeric(x[3]) / 60
    })))
  
  # Aggregate study times by date
  aggregated_data <- log_data %>%
    group_by(Date) %>%
    summarise(Total_Study_Time_Minutes = sum(Study_Time_Minutes, na.rm = TRUE))
  
  # Calculate the average study time in minutes
  avg_study_time <- mean(aggregated_data$Total_Study_Time_Minutes, na.rm = TRUE)
  
  # Create the bar graph with average line
  ggplot(aggregated_data, aes(x = as.Date(Date), y = Total_Study_Time_Minutes)) +
    geom_bar(stat = "identity") +
    geom_hline(yintercept = avg_study_time, color = "red", linetype = "dashed") +
    labs(title = "Distribution of Study Times",
         x = "Date",
         y = "Total Study Time (minutes)") +
    theme_minimal()
}

# Example usage
create_study_time_graph("/Users/mmtrapani/Documents/R Shiny Apps/Timer/Insurance_accounting_disc.csv")