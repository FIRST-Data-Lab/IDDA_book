mycol <- c("#F21A00","#7294D4", "#D67236", "#78B7C5", "#D8B70A")
ili_age_scatter = function(date.update, plot.type) {
  Ili.usa <- ilinet(region = "national", years = NULL)

  Ili.usa10 <- Ili.usa %>%
    filter(year >= 2010, year <= 2018) %>%
    select(week_start, age_0_4, age_5_24, age_25_49, age_50_64,
           age_65, total_patients)

  all.df = tidyr::gather(Ili.usa10, age, ILI,
                         -c(week_start, total_patients))

  all.df$age[which(all.df$age == "age_0_4")] = "age_00_04"
  all.df$age[which(all.df$age == "age_5_24")] = "age_05_24"

  if (plot.type == 'Scatter'){
    g <- ggplot(all.df, aes(age, log(ILI + 1), color = age)) +
      geom_point()
  } else if (plot.type == 'Jitter'){
    g <- ggplot(all.df, aes(age, log(ILI + 1), color = age)) +
      geom_jitter()
  }else if (plot.type == 'Box'){
    g <- ggplot(all.df, aes(age, log(ILI + 1), color = age)) +
      geom_boxplot()
  } else if (plot.type == 'Violin'){
    g <- ggplot(all.df, aes(age, log(ILI + 1), color = age)) +
      geom_violin()
  }
  return(g)
}

function(input, output) {
  output$ili_age_scatter <- renderPlotly({
    g <- ili_age_scatter(date.update = date.update,
                         plot.type = input$plot_type)
  })
}
