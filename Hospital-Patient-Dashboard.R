# Load libraries
library(shiny)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(lubridate)



# Load datasets
patients <- read.csv("D:/R folder/Hospital+Patient+Records/patients.csv")
encounters <- read.csv("D:/R folder/Hospital+Patient+Records/encounters.csv")
procedures <- read.csv("D:/R folder/Hospital+Patient+Records/procedures.csv")
payers <- read.csv("D:/R folder/Hospital+Patient+Records/payers.csv")
organizations <- read.csv("D:/R folder/Hospital+Patient+Records/organizations.csv")

# Data Wrangling

# 1. Handle missing values (removing rows with missing data in critical columns)
patients <- patients %>% filter(!is.na(BIRTHDATE))
encounters <- encounters %>% filter(!is.na(START) & !is.na(STOP))



# Merge data
merged_data <- encounters %>%
  left_join(patients, by = c("PATIENT" = "patient_Id")) %>%
  left_join(procedures, by = c("encounter_Id" = "ENCOUNTER_procedure")) %>%
  left_join(organizations, by = c("ORGANIZATION" = "organization_Id")) %>%
  left_join(payers, by = c("PAYER" = "payer_Id"))

# 2. Create derived metrics
merged_data$BIRTHDATE <- ymd(merged_data$BIRTHDATE)
merged_data$AGE <- floor(interval(merged_data$BIRTHDATE, Sys.Date()) / years(1))

merged_data$DURATION <- as.numeric(difftime(ymd_hms(merged_data$STOP), ymd_hms(merged_data$START), units = "hours"))



# -----------------------------------------------------------------------------------------------

ui <- fluidPage(
  titlePanel("Hospital Patient Records Dashboard"),
  sidebarLayout(
    sidebarPanel(
      selectInput("encounterType", "Select Encounter Type", 
                  choices = unique(merged_data$ENCOUNTERCLASS), 
                  selected = "ambulatory"),
      dateRangeInput("dateRange", "Select Date Range", 
                     start = min(as.Date(merged_data$START)), 
                     end = max(as.Date(merged_data$STOP)))
      ,
      
      
       sliderInput("ageRange", "Select Age Range", 
                  min = min(merged_data$AGE, na.rm = TRUE), 
                  max = max(merged_data$AGE, na.rm = TRUE), 
                  value = c(min(merged_data$AGE, na.rm = TRUE), max(merged_data$AGE, na.rm = TRUE))),
       actionButton("predict", "Run Prediction")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Patient Demographics", 
                 plotOutput("demographicsPlot")
                 , 
                 verbatimTextOutput("ageSummary")
                 ),
        tabPanel("Encounters Overview", 
                 plotOutput("encountersPlot"), 
                 verbatimTextOutput("encounterStats")),
        tabPanel("Procedures Analysis", 
                 plotOutput("proceduresPlot"),
                 verbatimTextOutput("costStats")),
        tabPanel("City Overview", 
                 plotOutput("cityPlot")),
        tabPanel("Cost and Stay analysis", 
                 plotOutput("Costpervisit"),
                 plotOutput("stayDurationBar"),
                 verbatimTextOutput("avg_stay")),
        tabPanel("Comparison", 
                 plotOutput("comparisonPlot"))
      )
    )
  )
)

# --------------------------------------------------------------------------------

# Shiny Server
server <- function(input, output) {
  # Filter data based on user input
  filtered_data <- reactive({
    merged_data %>%
      filter(ENCOUNTERCLASS == input$encounterType &
               as.Date(START) >= input$dateRange[1] &
               as.Date(STOP) <= input$dateRange[2] &
             
               merged_data$AGE >= input$ageRange[1] &
               merged_data$AGE <= input$ageRange[2]
            )
  })
  
# ---------------------------------------------------------------------------
  
  # Patient Demographics Plot
  output$demographicsPlot <- renderPlot({
    filtered_data() %>%
      ggplot(aes(x = GENDER)) +
      geom_bar() +
      theme_minimal() +
      labs(title = "Patient Gender Distribution")
  })
  
  # Age Summary
   output$ageSummary <- renderPrint({
    summary(filtered_data()$AGE)
   })
  
  # Encounters Overview (encounters over time)
  output$encountersPlot <- renderPlot({
    filtered_data() %>%
      ggplot(aes(x = as.Date(START), fill = ENCOUNTERCLASS)) +
      geom_histogram(binwidth = 30) +
      theme_minimal() +
      labs(title = "Encounters Over Time", x = "Date", y = "Number of Encounters")
  })
  
  # Encounter Statistics (e.g., mean, median duration)
  output$encounterStats <- renderPrint({
    filtered_data() %>%
      summarise(mean_duration = mean(DURATION, na.rm = TRUE),
                median_duration = median(DURATION, na.rm = TRUE),
                sd_duration = sd(DURATION, na.rm = TRUE))
  })
  
  # Procedures Analysis (cost by procedure)
  output$proceduresPlot <- renderPlot({
    filtered_data() %>%
      ggplot(aes(x = reorder(DESCRIPTION, -BASE_COST_procedure), y = BASE_COST_procedure)) +
      geom_bar(stat = "identity") +
      coord_flip() +
      theme_minimal() +
      labs(title = "Cost by Procedure", x = "Procedure", y = "Cost")
  })
  
  # Cost Statistics
  output$costStats <- renderPrint({
    summary(filtered_data()$BASE_COST_procedure)
  })
  
  # Payer Overview (payer distribution)
  output$cityPlot <- renderPlot({
    filtered_data() %>%
      filter(CITY != "") %>%
      group_by(CITY) %>%
      ggplot(aes(x = CITY)) +
      geom_bar() +
      theme_minimal() +
      labs(title = "City Distribution", x = "City", y = "Count")
  })
  
  
  
  # Average Stay
  output$avg_stay <- renderPrint({
    
      avg_stay <- filtered_data() %>%
        summarise(mean_stay = round(mean(DURATION, na.rm = TRUE)),
                  median_stay = median(DURATION, na.rm = TRUE),
                  mean_cost = round(mean(BASE_COST_procedure, na.rm = TRUE)),
                  median_cost = median(BASE_COST_procedure, na.rm = TRUE))
      
      
      covered_procedures <- filtered_data() %>%
        filter(!is.na(PAYER_COVERAGE)) %>%
        summarise(total_covered = n())
      
      
      cat("Average Stay and Cost Statistics:\n")
      print(avg_stay)
      
      cat("\nNumber of Procedures Covered by Insurance:\n")
      print(covered_procedures)
      
    
  })
  
  output$Costpervisit <- renderPlot({
    avg_cost <- filtered_data() %>%
      summarise(mean_cost = mean(BASE_COST_procedure, na.rm = TRUE),
                median_cost = median(BASE_COST_procedure, na.rm = TRUE))
    
    avg_cost %>%
      gather(key = "Statistic", value = "Cost", mean_cost, median_cost) %>%
      ggplot(aes(x = Statistic, y = Cost, fill = Statistic)) +
      geom_bar(stat = "identity", width = 0.5) +
      theme_minimal() +
      labs(title = "Average and Median Cost per Visit", 
           y = "Cost ($)", x = "Statistic")
  })
  
  
  output$stayDurationBar <- renderPlot({
    avg_stay <- filtered_data() %>%
      summarise(mean_stay = mean(DURATION, na.rm = TRUE),
                median_stay = median(DURATION, na.rm = TRUE))
    
    avg_stay %>%
      gather(key = "Statistic", value = "Duration", mean_stay, median_stay) %>%
      ggplot(aes(x = Statistic, y = Duration, fill = Statistic)) +
      geom_bar(stat = "identity", width = 0.5) +
      theme_minimal() +
      labs(title = "Average and Median Hospital Stay Duration", 
           y = "Duration (hours)", x = "Statistic")
  })
  

  
  # Comparison Plot (e.g., costs across organizations)
  output$comparisonPlot <- renderPlot({
    filtered_data() %>%
      ggplot(aes(x = BASE_COST_procedure, fill = COUNTY)) +
      geom_histogram() +
      theme_minimal() +
      facet_wrap(~ ETHNICITY) +
      labs(title = "Cost Comparison Across Ethnicity", x = "Organization", y = "Cost")
  })
  

  
}

# Run the app
shinyApp(ui = ui, server = server)