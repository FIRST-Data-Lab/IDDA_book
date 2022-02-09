date.update <- as.Date('2020-12-31')
mycol <- c("#5B1A18", "#F21A00", "#D67236", "#F1BB7B",
           "#D8B70A", "#A2A475", "#81A88D", "#78B7C5",
           "#3B9AB2", "#7294D4", "#C6CDF7", "#E6A0C4")
ts.plotly <- function(df, type = 'scatter', mode = 'lines+markers',
                     group = group, mycol, showlegend = TRUE, visible = T,
                     xaxis = xaxis, yaxis = yaxis, legend = legend) {

  ts <- plot_ly(df) %>%
    add_trace(x = ~x, y = ~y, type = type, mode = mode,
              color = ~group, colors = mycol,
              showlegend = showlegend,
              visible = visible) %>%
    layout(xaxis = xaxis, yaxis = yaxis,
           legend = legend)
  return(ts)
}

county.risk.ts <- function(date.update, type = 'localrisk'){
  date.all <- date.update - (0:29)
  date.lag <- date.all - 7
  County.pop0 <- IDDA::pop.county
  County.pop <- County.pop0 %>%
    filter((!(State %in% c("Alaska","Hawaii"))))
  County.pop <- County.pop %>%
    filter((!(ID %in% c(36005, 36047, 36081, 36085))))
  County.pop$ID[County.pop$ID == 46102] = 46113
  dat <- IDDA::I.county
  dat <- dat %>%
    filter((!(State %in% c("Alaska", "Hawaii"))))
  var.names <- paste0("X", as.character(date.all), sep = "")
  var.names <- gsub("\\-", "\\.", var.names)
  var.lag <- paste0("X", as.character(date.lag), sep = "")
  var.lag <- gsub("\\-", "\\.", var.lag)
  tmp <- as.matrix((dat[, var.names] - dat[, var.lag])/7)
  dat <- dat[, c("ID", "County", "State", var.names)]
  smr.c <- sum(County.pop$population)/as.matrix(colSums(dat[,-(1:3)]))

  I0 <- LogI0 <- LocRisk0 <- SMR0 <- dat
  LogI0[,-(1:3)] <- as.matrix(log(dat[,-(1:3)]+1))
  LocRisk0[,-(1:3)] <- sweep(as.matrix(dat[,-(1:3)]), 1,
                             County.pop$population[match(dat$ID, County.pop$ID)],
                             "/") * 1000
  SMR0[,-(1:3)] <- sweep(LocRisk0[,-(1:3)],2,smr.c/10,"*")
  WLR0 <- sweep(tmp, 1,
                County.pop$population[match(dat$ID, County.pop$ID)],
                "/") * 1e5

  county.dat <- data.frame(Date = date.all)
  CountyState <- paste(as.character(dat$County),
                       as.character(dat$State), sep = ",")

  LogI <- cbind(county.dat,round(t(LogI0[,-(1:3)]),2))
  names(LogI) <- c("Date", CountyState)

  LocRisk <- cbind(county.dat,round(t(LocRisk0[,-(1:3)]),2))
  names(LocRisk) <- c("Date", CountyState)

  SMR <- cbind(county.dat,t(SMR0[,-(1:3)]))
  names(SMR) <- c("Date", CountyState)

  WLR <- cbind(county.dat, round(t(WLR0), 2))
  names(WLR) <- c("Date", CountyState)

  xaxis.fr <- list(title = "", showline = FALSE,
                   showticklabels = TRUE, showgrid = TRUE,
                   type = 'date', tickformat = '%m/%d')
  legend.fr <- list(orientation = 'h', x = 0, y = -0.05,
                    autosize = F, width = 250, height = 200)

  if (type == 'localrisk'){
    ind.county = order(LocRisk0[,var.names[1]], decreasing = TRUE)
    df.fr <- LocRisk %>%
      select(c(1, 1 + ind.county[1:10])) %>%
      gather(key = "County.State", value = "LogI", -Date)
    names(df.fr) <- c("x","group","y")
    yaxis.fr <- list(title = "Local Risk (Cases per Thousand)")
    ts.fr <- ts.plotly(df.fr, type = 'scatter',
                       mode = 'lines+markers',
                       group = group, mycol,
                       showlegend = TRUE, visible = T,
                       xaxis = xaxis.fr, yaxis = yaxis.fr,
                       legend = legend.fr)
  }else if (type == 'smr'){
    ind.county = order(SMR0[,var.names[1]], decreasing = TRUE)
    df.fr <- SMR %>%
      select(c(1, 1 + ind.county[1:10])) %>%
      gather(key = "County.State", value = "LogI", -Date)
    names(df.fr) <- c("x","group","y")
    yaxis.fr <- list(title = "SMR (%)")
    ts.fr <- ts.plotly(df.fr, type = 'scatter',
                       mode = 'lines+markers',
                       group = group, mycol, showlegend = TRUE,
                       visible = T, xaxis = xaxis.fr,
                       yaxis = yaxis.fr, legend = legend.fr)
  }else if (type == 'logcount'){
    ind.county = order(dat[,var.names[1]], decreasing = TRUE)
    df.fr <- LogI %>%
      select(c(1,1+ind.county[1:10])) %>%
      gather(key = "County.State", value = "LogI", -Date)
    names(df.fr) = c("x","group","y")
    yaxis.fr <- list(title = "Log Counts")
    ts.fr <- ts.plotly(df.fr, type = 'scatter',
                       mode = 'lines+markers',
                       group = group, mycol,
                       showlegend = TRUE, visible = T,
                       xaxis = xaxis.fr, yaxis = yaxis.fr,
                       legend = legend.fr)
  }else if (type == 'wlr'){
    ind.county <- order(WLR0[, var.names[1]], decreasing = TRUE)
    df.fr <- WLR %>%
      select(c(1, 1 + ind.county[1:10])) %>%
      gather(key = "CountyState", value = "WLR", -Date)
    names(df.fr) <- c("x", "group", "y")
    yaxis.fr <- list(title = "WLR (New Cases Per 100K)")
    ts.fr <- ts.plotly(df.fr, type = 'scatter',
                       mode = 'lines+markers',
                       group = group, mycol,
                       showlegend = TRUE, visible = T,
                       xaxis = xaxis.fr, yaxis = yaxis.fr,
                       legend = legend.fr)
  }
  return(ts.fr)
}

shinyServer(function(input, output) {
  output$county_risk_ts <- renderPlotly({
    ts <- county.risk.ts(date.update, type = input$plot_type)
  })
})
