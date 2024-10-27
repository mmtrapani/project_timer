library(ggplot2)
library(dplyr)
library(R6)

StudyTimeGraph <- R6Class("StudyTimeGraph",
  public = list(
    log_data = NULL,
    
    initialize = function(csv_file) {
      self$read_csv(csv_file)
    },
    
    read_csv = function(csv_file) {
      self$log_data <- read.csv(csv_file, stringsAsFactors = FALSE)
      self$log_data <- self$log_data %>%
        mutate(Study_Time_Minutes = as.numeric(sapply(strsplit(Study_Time, ":"), function(x) {
          as.numeric(x[1]) * 60 + as.numeric(x[2]) + as.numeric(x[3]) / 60
        })))
    },
    
    generate_plot = function() {
      aggregated_data <- self$log_data %>%
        group_by(Date) %>%
        summarise(Total_Study_Time_Minutes = sum(Study_Time_Minutes, na.rm = TRUE))
      
      avg_study_time <- mean(aggregated_data$Total_Study_Time_Minutes, na.rm = TRUE)
      
      ggplot(aggregated_data, aes(x = as.Date(Date), y = Total_Study_Time_Minutes)) +
        geom_bar(stat = "identity") +
        geom_hline(yintercept = avg_study_time, color = "red", linetype = "dashed") +
        labs(title = "Distribution of Study Times",
             x = "Date",
             y = "Total Study Time (minutes)") +
        theme_minimal()
    }
  )
)