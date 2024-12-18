# Load ggplot2 for creating visualizations
# ggplot2 is particularly suited for complex and layered graphics.
library(ggplot2)

# Load dplyr for data manipulation tasks
library(dplyr)

# Load R6 for creating classes with object-oriented programming
library(R6)

# Load ggthemes for applying pre-built themes to ggplot visuals
library(ggthemes)

StudyTimeGraph <- R6Class("StudyTimeGraph",
  public = list(
    log_data = NULL,
    
    initialize = function(csv_file) {
      # Initialize the class by reading a CSV file containing study logs
      self$read_csv(csv_file)
    },
    
    read_csv = function(csv_file) {
      # Read study log data from a CSV file and convert study time to minutes
      self$log_data <- read.csv(csv_file, stringsAsFactors = FALSE)
      self$log_data <- self$log_data %>%
        mutate(Study_Time_Minutes = as.numeric(sapply(strsplit(Study_Time, ":"), function(x) {
          # Convert time in HH:MM:SS format into total minutes
          as.numeric(x[1]) * 60 + as.numeric(x[2]) + as.numeric(x[3]) / 60
        })))
    },
    
    generate_plot = function() {
      # Summarize total study time per day
      aggregated_data <- self$log_data %>%
        group_by(Date) %>%
        summarise(Total_Study_Time_Minutes = sum(Study_Time_Minutes, na.rm = TRUE))
      
      # Calculate the average study time for reference
      avg_study_time <- mean(aggregated_data$Total_Study_Time_Minutes, na.rm = TRUE)
      
      # Generate a bar plot with ggplot
      ggplot(aggregated_data, aes(x = as.Date(Date), y = Total_Study_Time_Minutes)) +
        geom_bar(stat = "identity", fill = "skyblue") +
        # Add a horizontal line indicating the average study time
        geom_hline(yintercept = avg_study_time, color = "red", linetype = "dashed") +
        labs(title = "Distribution of Study Times",
             x = "Date",
             y = "Total Study Time (minutes)") +
        # Apply the Economist theme for aesthetics
        theme_economist() +
        scale_fill_economist() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
              axis.title.x = element_text(vjust = -0.5),
              plot.margin = margin(t = 10, r = 10, b = 30, l = 10))
    }
  )
)
