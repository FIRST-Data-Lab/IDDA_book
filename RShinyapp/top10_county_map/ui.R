library(shiny)
library(dplyr)
library(leaflet)
library(IDDA)
shinyUI(
  # Use a fluid layout
  fluidPage(
    # Give the page a title
    titlePanel(
      HTML(
        paste("Top 10 counties with the largest cumulative", '<br/>', 
              "infected count on December 31, 2020")
      )),
    mainPanel(leafletOutput("map"))
))
