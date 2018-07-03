library(stats,   quietly = T, warn.conflicts = F)
library(dplyr,   quietly = T, warn.conflicts = F)
library(shiny,   quietly = T, warn.conflicts = F)
library(ggplot2, quietly = T, warn.conflicts = F)
library(plotly,  quietly = T, warn.conflicts = F)

source("db.R", local=FALSE)
source("data.R", local=FALSE)

dfg = NULL
rec = NULL

# This function make global dfg

cambiaMoneda <- function(input, session) {
    df <- getLocalData(as.integer(input$currency))
    rng <- c(df[1, "Fecha"], df[nrow(df), "Fecha"])

    updateSliderInput   (session,"drSlider",value = rng, min = rng[1], max = rng[2])
    updateDateRangeInput(session, "drRange",min = rng[1],max = rng[2],start = rng[1],end = rng[2])
    
    dfg <<- df
}   

server <- function(input, output, session) {
     tend = c(FALSE,FALSE,FALSE,FALSE)

     observeEvent({input$currency},   cambiaMoneda(input, session),        ignoreNULL=T, ignoreInit = F)
     observeEvent({input$drSlider},   syncRanges(input, session, 1),       ignoreNULL=T, ignoreInit = T)
     observeEvent({input$drRange},    syncRanges(input, session, 2),       ignoreNULL=T, ignoreInit = T)
     observeEvent({input$dateSelect}, setRecord(input, session, dfg),      ignoreNULL=T, ignoreInit = T)
     
     observeEvent({input$chk1},       output$imgWeek <- setTrend(input$chk1, input$dateSelect, 1, dfg)
                                      ,ignoreNULL=T, ignoreInit = T)
     observeEvent({input$chk2},       output$imgFort <- setTrend(input$chk2, input$dateSelect, 2, dfg)
                                      ,ignoreNULL=T, ignoreInit = T)
     observeEvent({input$chk3},       output$imgMonth <- setTrend(input$chk3, input$dateSelect, 3, dfg)
                                      ,ignoreNULL=T, ignoreInit = T)
     observeEvent({input$chk4},       output$imgQuarter <- setTrend(input$chk4, input$dateSelect, 4, dfg)
                                      ,ignoreNULL=T, ignoreInit = T)
     
     output$registro <- renderTable(dfg %>% 
                                        filter(Fecha == as.Date(input$dateSelect, origin=lubridate:::origin)) %>%
                                        subset(select=c("Beg", "End", "High", "Low"))
                                    )
     
     output$dateSelect <- renderPrint({
         s <- event_data("plotly_click")
         if (length(s) != 0) s
     })
     
     output$plot <- renderPlotly({
         if (is.null(dfg)) return (NULL)
         
         rng <- input$drRange
         df <- dfg %>% filter(Fecha >= rng[1] , Fecha <= rng[2])
         
         tend[1] <- ifelse(input$chk1, T, F)
         tend[2] <- ifelse(input$chk2, T, F)
         tend[3] <- ifelse(input$chk3, T, F)
         tend[4] <- ifelse(input$chk4, T, F)
         
         if (input$tipo < 3) {
             p <- plot_ly(df, x = ~Fecha, y = ~End
                          , type = 'scatter'
                          , mode = 'lines + markers'
                          , source='grafico')
         }
         
         if (input$tipo == 2) {
             p <- layout(p, yaxis = list(type = "log"))
         }
         
         if (input$tipo == 3) {
             p <- plot_ly(df, x = ~Fecha
                          , type = 'candlestick'
                          , open = ~Beg
                          , close = ~End
                          , high = ~High
                          , low = ~Low
             )
             p <- layout(p, xaxis = list(rangeslider = list(visible = F)))
             
         }
         
         p$elementId <- NULL
         
         p <- layout(p
                     ,shapes=list(type="line", fillcolor="red",line=list(color="red")
                                  ,opacity=1
                                  ,x0=input$dateSelect, x1=input$dateSelect, xref="x"
                                  ,y0=0, y1=1, yref="paper")
         )
        
       for (idx in 1:4) {
           if (tend[idx]){
               interval = switch(idx, 7,15,30,120)
               segment <- calculateSegment(df, interval, input$dateSelect)
               p <- add_trace(p, x=~x, y=~y, data=segment, mode="lines", showlegend = F)
           }
       }

        p %>% layout()         
     })
}     
