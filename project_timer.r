# Load necessary libraries
library(shiny)
library(lubridate)

# Define the UI
ui <- fluidPage(
  titlePanel("Project Timer"),
  sidebarLayout(
    sidebarPanel(
      textInput("project", "Project Name"),
      actionButton("start", "Start"),
      actionButton("stop", "Stop"),
      textOutput("timer_status"),
      textOutput("elapsed_time")
    ),
    mainPanel(
      tableOutput("log_table")
    )
  )
)

# Define the server
server <- function(input, output, session) {
  # Reactive values to store start and stop times
  times <- reactiveValues(start = NULL, stop = NULL, elapsed = 0)
  
  # Reactive value to store log entries
  log_entries <- reactiveVal(data.frame(
    Date = character(), 
    Start_Time = character(), 
    Stop_Time = character(),
    Study_Time = character(),
    stringsAsFactors = FALSE
  ))
  
  # Function to load existing CSV if it exists
  load_existing_log <- function(file_name) {
    if (file.exists(file_name)) {
      existing_data <- read.csv(file_name, stringsAsFactors = FALSE)
      log_entries(existing_data)
    } else {
      log_entries(data.frame(
        Date = character(), 
        Start_Time = character(), 
        Stop_Time = character(),
        Study_Time = character(),
        stringsAsFactors = FALSE
      ))
    }
  }
  
  # Start button observer
  observeEvent(input$start, {
    times$start <- Sys.time()
    times$stop <- NULL
    times$elapsed <- 0
    output$timer_status <- renderText("Timer started")
    
    # Load existing log entries if any
    project <- input$project
    if (project == "") {
      project <- "default"
    }
    file_name <- paste0(getwd(), "/", project, ".csv")
    load_existing_log(file_name)
  })
  
  # Stop button observer
  observeEvent(input$stop, {
    times$stop <- Sys.time()
    output$timer_status <- renderText("Timer stopped")
    
    if (!is.null(times$start)) {
      # Calculate the study time
      study_time <- difftime(times$stop, times$start, units = "secs")
      formatted_study_time <- sprintf("%02d:%02d:%02d", 
                                      as.integer(study_time) %/% 3600, 
                                      (as.integer(study_time) %% 3600) %/% 60, 
                                      as.integer(study_time) %% 60)
      
      # Create a new log entry
      new_entry <- data.frame(
        Date = as.character(Sys.Date()), 
        Start_Time = as.character(times$start), 
        Stop_Time = as.character(times$stop),
        Study_Time = formatted_study_time,
        stringsAsFactors = FALSE
      )
      
      # Append new entry to log_entries
      updated_log <- rbind(log_entries(), new_entry)
      log_entries(updated_log)
      
      # Save log to CSV
      project <- input$project
      if (project == "") {
        project <- "default"
      }
      file_name <- paste0(project, ".csv")
      write.csv(updated_log, file = file_name, row.names = FALSE)
    }
  })
  
  # Update elapsed time every second
  observe({
    invalidateLater(1000, session)
    if (!is.null(times$start) && is.null(times$stop)) {
      times$elapsed <- as.numeric(difftime(Sys.time(), times$start, units = "secs"))
      output$elapsed_time <- renderText({
        sprintf("%02d:%02d:%02d", 
                as.integer(times$elapsed) %/% 3600, 
                (as.integer(times$elapsed) %% 3600) %/% 60, 
                as.integer(times$elapsed) %% 60)
      })
    }
  })
  
  # Render log table
  output$log_table <- renderTable({
    log_entries()
  })
  
  # Stop the Shiny server when the session ends
  session$onSessionEnded(function() {
    stopApp()
  })
}

# Run the app
shinyApp(ui = ui, server = server)
