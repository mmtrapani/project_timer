# Project Timer

This project is a Shiny application designed to help you track the time spent on various projects. It includes features for starting and stopping a timer, logging time entries, and visualizing the distribution of study time.

## Table of Contents

- Installation
- Usage
- File Structure
- Features
- Contributing
- License

## Installation

To run this Shiny application, you need to have R and the Shiny package installed. You can install Shiny using the following command:

```r
install.packages("shiny")
```

Additionally, you need the [`lubridate`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2FUsers%2Fmmtrapani%2FDocuments%2FR%20Shiny%20Apps%2FTimer%2Fproject_timer_v002.R%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%2C%22pos%22%3A%7B%22line%22%3A1%2C%22character%22%3A8%7D%7D%5D%2C%22ed62a2b8-e261-4ca1-bfed-dfa439d5e820%22%5D "Go to definition") package for date-time manipulation:

```r
install.packages("lubridate")
```

## Usage

To run the application, navigate to the project directory and execute the following command in your R console:

```r
shiny::runApp('project_timer_v002.R', launch.browser = TRUE)
```

This will launch the Shiny app in your default web browser.

## File Structure

- `project_timer_v002.R`: Main R script for the Shiny application.
- `run_app.sh`: Shell script to run the Shiny app.
- `study_time_graph.r`: R script for generating study time graphs.

## Features

### User Interface

- **Directory Input**: Allows the user to specify the directory for projects.
- **Project Dropdown**: Dropdown menu to select an existing project.
- **New Project Input**: Text input to create a new project.
- **Start/Stop Buttons**: Buttons to start and stop the timer.
- **Timer Status**: Displays the current status of the timer.
- **Elapsed Time**: Shows the elapsed time in HH:MM:SS format.
- **Study Time Plot**: Visualizes the distribution of study time.
- **Log Table**: Displays the log entries of start and stop times.

### Server Logic

- **Reactive Values**: Stores start and stop times, and calculates elapsed time.
- **Log Entries**: Stores log entries in a reactive data frame.
- **Elapsed Time Calculation**: Calculates the elapsed time using [`difftime`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2FUsers%2Fmmtrapani%2FDocuments%2FR%20Shiny%20Apps%2FTimer%2F.Rhistory%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%2C%22pos%22%3A%7B%22line%22%3A490%2C%22character%22%3A28%7D%7D%5D%2C%22ed62a2b8-e261-4ca1-bfed-dfa439d5e820%22%5D "Go to definition").
- **Log Table Rendering**: Renders the log table using [`renderTable`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2FUsers%2Fmmtrapani%2FDocuments%2FR%20Shiny%20Apps%2FTimer%2F.Rhistory%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%2C%22pos%22%3A%7B%22line%22%3A500%2C%22character%22%3A20%7D%7D%5D%2C%22ed62a2b8-e261-4ca1-bfed-dfa439d5e820%22%5D "Go to definition").

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License. See the [LICENSE.txt](./LICENSE.txt) file for details.

---

Feel free to customize this README further based on your specific needs and additional details about your project.
