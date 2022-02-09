library(shiny)
library(dplyr)
library(plotly)
library(tidyr)
library(lubridate)

shinyUI(fluidPage(
  div(class="outer",
      # tags$head(includeCSS("styles.css")),
      plotlyOutput("county_risk_ts", height="90%", width="100%"),
      absolutePanel(id = "control", class = "panel panel-default",
                    top = 60, left = 70, width = 255, fixed=TRUE,
                    draggable = TRUE, height = "auto", style = "opacity: 0.8",
                    selectInput("plot_type",
                                label = h5("Select type"),
                                choices = c("WLR" = "wlr", "IR" = "localrisk",
                                            "SIR" = "smr")
                    ) # end of selectInput
      ) # end of absolutePanel
  ) # end of div
))
