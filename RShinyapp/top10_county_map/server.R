shinyServer(function (input, output) {
  # Prepare data
  location.county <- IDDA::features.county %>% 
    dplyr:: select(ID, Longitude, Latitude) 
  county.top10.today <- IDDA::county.top10 %>% 
    select(ID, County, State, Infection)
  names(county.top10.today)[4] <- 'Count'
  df <- left_join(county.top10.today, location.county, key = "ID")
  # Prepare popup label
  labels_cases.county <- sprintf(
    "<strong>%s</strong>, <strong>%s</strong>
    <br/> Cum. Infected Cases on 2020-12-31: %g <br>",
    df$County, df$State, 
    df$Count
  ) %>% lapply(htmltools::HTML)
  # Draw a spot map with popup
  output$map <- renderLeaflet({
    leaflet() %>%
      setView(-96, 37.8, zoom = 4) %>%
      addTiles() %>%
      addCircles(data = df, lng = ~Longitude, lat = ~Latitude, 
                 weight = 1, radius = ~sqrt(Count)*200, 
                 popup = ~County) %>% 
      addMarkers(data = df, lng = ~Longitude, lat = ~Latitude, 
                 popup = ~labels_cases.county)
  })
})