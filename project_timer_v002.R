library(shiny)
library(lubridate)

# Source the study_time_graph.R script
source("study_time_graph.R")

# Define the UI
ui <- fluidPage(
  titlePanel("Project Timer"),
  sidebarLayout(
    sidebarPanel(
      textInput("directory", "Directory for Projects", value = getwd()), # Directory input
      selectInput("project_dropdown", "Select Existing Project", choices = NULL), # Dropdown for existing projects
      textInput("new_project", "Or Create New Project (Leave blank if selecting existing)"), # Text input for new project
      actionButton("start", "Start"),
      actionButton("stop", "Stop"),
      textOutput("timer_status"),
      textOutput("elapsed_time"),
      hr(),
      plotOutput("study_time_plot") # Add plot output for study time distribution
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
    tryCatch({
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
    }, error = function(e) {
      showNotification("Error loading log file", type = "error")
    })
  }
  
  # Validate directory input
  validate_directory <- function(dir_path) {
    if (!dir.exists(dir_path)) {
      showNotification("Invalid directory", type = "error")
      return(FALSE)
    }
    return(TRUE)
  }
  
  # Update the project dropdown choices based on the directory input
  observe({
    dir_path <- input$directory
    if (validate_directory(dir_path)) {
      project_files <- list.files(path = dir_path, pattern = "\\.csv$", full.names = FALSE)
      updateSelectInput(session, "project_dropdown", choices = project_files)
    }
  })
  
  # Load the selected project when the dropdown is changed
  observeEvent(input$project_dropdown, {
    if (input$project_dropdown != "") {
      file_name <- paste0(input$directory, "/", input$project_dropdown)
      load_existing_log(file_name)
      output$timer_status <- renderText(paste("Loaded project:", input$project_dropdown))
    }
  })
  
  # Start button observer
  observeEvent(input$start, {
    times$start <- Sys.time()
    times$stop <- NULL
    times$elapsed <- 0
    output$timer_status <- renderText("Timer started")
    
    # Determine which project to use
    project <- if (input$new_project != "") {
      input$new_project
    } else {
      input$project_dropdown
    }
    
    if (project == "") {
      project <- "default"
    }
    
    # Add .csv extension only if not already present
    file_name <- paste0(input$directory, "/", project)
    if (!grepl("\\.csv$", file_name)) {
      file_name <- paste0(file_name, ".csv")
    }
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
      project <- if (input$new_project != "") {
        input$new_project
      } else {
        input$project_dropdown
      }
      
      if (project == "") {
        project <- "default"
      }
      
      # Add .csv extension only if not already present
      file_name <- paste0(input$directory, "/", project)
      if (!grepl("\\.csv$", file_name)) {
        file_name <- paste0(file_name, ".csv")
      }
      tryCatch({
        write.csv(updated_log, file = file_name, row.names = FALSE)
      }, error = function(e) {
        showNotification("Error saving log file", type = "error")
      })
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
  
  # Generate the study time distribution plot
  output$study_time_plot <- renderPlot({
    if (input$project_dropdown != "") {
      file_name <- paste0(input$directory, "/", input$project_dropdown)
      if (file.exists(file_name)) {
        study_time_graph <- StudyTimeGraph$new(file_name) # nolint: object_usage_linter.
        study_time_graph$generate_plot()
      }
    }
  })
  
  # Stop the Shiny server when the session ends
  session$onSessionEnded(function() {
    stopApp()
  })
}

# Run the app
shinyApp(ui = ui, server = server)