# Hospital Patient Dashboard


## Overview
This Shiny application provides a comprehensive dashboard for visualizing and analyzing hospital patient records, based on a dataset containing patient demographics, encounters, procedures, payers, and hospital organizations. The dashboard allows users to explore different aspects of the data, including patient demographics, encounter trends, procedure costs, and more.


## Features

### Interactive Filters: 
Users can filter the data by encounter type, date range, and patient age range using a sidebar panel with intuitive UI elements like dropdowns, date range selectors, and sliders.
### Demographic Analysis: 
Visualizes the gender distribution of patients and provides summary statistics for patient ages.

![image](https://github.com/user-attachments/assets/428f3260-21e0-4349-9ab2-3336190ef72f)


### Encounter Overview: 
Displays the distribution of patient encounters over time and provides key statistics, such as average and median encounter duration.

![image](https://github.com/user-attachments/assets/61e7aa8c-dc08-4d62-8d56-e46c9bed6e92)


### Procedure Analysis: 
Analyzes procedure costs, allowing users to see the distribution of procedure costs across different procedures and payers.

![image](https://github.com/user-attachments/assets/65b23554-5b24-4801-8bf8-8e0da3640cac)


### City Distribution: 
Visualizes patient distribution based on city.

![image](https://github.com/user-attachments/assets/fb456bcf-b858-459d-ad79-b7f0cf116923)


### Hospital Stay Insights: 
Provides insights into the average and median hospital stay duration, along with a cost analysis of procedures.

![image](https://github.com/user-attachments/assets/52fabeca-fd1f-4565-9da3-9967e251203e)![image](https://github.com/user-attachments/assets/a9a154a9-d79d-4076-8f7b-74b2a199a997)



### Cost and Ethnicity Comparison: 
Compares procedure costs across different ethnic groups, providing deeper insights into cost disparities.

![image](https://github.com/user-attachments/assets/5d4e2f9f-8bde-4ef6-9ba1-75feed6a5708)




## Technical Details
### Data Sources: 
The app utilizes patient, encounters, procedures, payers, and hospital organization data stored in CSV files.
### Data Wrangling: 
Data is cleaned and transformed, handling missing values and creating derived metrics such as patient age and encounter duration.
### Libraries Used:
- shiny for building the interactive web interface
- ggplot2 for generating plots
- dplyr and tidyverse for data manipulation
- lubridate for date handling


## Key Visualizations:
- Bar charts for patient demographics and city distribution
- Histograms for encounter trends and cost comparison
- Summary tables for encounter and cost statistics
- Comparison plots for costs across different ethnicities and counties
- User Interaction
- Users can interact with the data through:

### Encounter Type Filter: 
Filter records based on the type of encounter (e.g., ambulatory, inpatient, etc.).
### Date Range Selector: 
Specify a date range to focus on specific time periods.
### Age Range Slider: 
Adjust the slider to filter patients based on age.


## Code Breakdown
### UI: 
The ui function defines the layout of the dashboard, which includes various input controls, plots, and tabs for displaying different aspects of the data.
### Server: 
The server function processes the input from the UI, filters the data accordingly, and generates the plots and summaries displayed in the dashboard.




## Conclusion
This dashboard serves as a valuable tool for healthcare data analysis, offering users the ability to gain insights into hospital records in an interactive and intuitive way. The combination of data visualization and interactive controls makes it a powerful resource for both analysts and healthcare administrators.


## Note: 
This dashboard serves as a basic structure how to create R shiny dashboard. It has limited interactivity, but it can be enhanced as per business needs

