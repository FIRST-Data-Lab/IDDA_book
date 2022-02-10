library(shiny)
library(dplyr)
library(IDDA)
library(plotly)

shinyUI(fluidPage(
  sliderInput("date.update",
              label = h5("Select date"),
              min = as.Date("2020-12-01"),
              max = as.Date("2020-12-31"),
              value = as.Date("2020-12-31"),
              timeFormat = "%d %b",
              animate = animationOptions(interval = 2000, loop = FALSE)
  ),
  # Show a plot of the generated distribution
  mainPanel(
    plotlyOutput("state_cum_inf", height = "100%", width = "150%")
  )
))
