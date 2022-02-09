state.cum.inf <- function(date.update){
  d.str = as.character(format(date.update, 'X%Y.%m.%d'))
  # Order cumulative infected counts for each state
  dat = IDDA::I.state %>% arrange(desc(get(d.str))) 
  # Select the top 10 states with highest counts
  dat.top <- dat[1:10,] %>%
    dplyr::select(State, all_of(d.str)) %>% 
    mutate(Date = date.update) 
  names(dat.top) <- c('State', 'CumInf', 'Date')
  plot.title <- paste0("Cumulative infected counts on ", 
                        as.character(date.update))
  # Set up the order of bars
  dat.top$State = factor(dat.top$State,
                  levels = dat.top$State[order(dat.top$CumInf,decreasing = T)])
  # Draw the bar plot
  plot.out <-
    ggplot(dat.top, aes(x = State, y = CumInf)) + 
    labs(title = plot.title) +
    geom_bar(stat = 'identity', fill = "#C93312") +
    xlab('') +
    ylab('') 
  return(plot.out) 
}

shinyServer(function(input, output) {
  output$state_cum_inf <- renderPlotly({
    ts <- state.cum.inf(input$date.update)
  })
})
