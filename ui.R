
library(shinydashboard, quietly = T, warn.conflicts = F)
library(plotly,         quietly = T, warn.conflicts = F)
source("db.R")

header <- dashboardHeader(
    title = "Cryptocurrency prices"
)

body <- dashboardBody(
    tags$head(tags$style(HTML("
                                #final_text {
                              text-align: center;
                              }
                              div.box-header {
                              text-align: center;
                              }
                              div.row {
                                line-height: 14px;
                              }
                              div#dateSelect.form-control { 
                                 height: 14px;
                                 margin-bottom: 1px; 
                                 padding: 0px;
                                 font-size: 12px;
                               }
                              .tRow{height:14px;}
                              ")))
    # Boxes need to be put in a row (or column)
    ,fluidRow(
        column(width=9,
             box( width=NULL
                 ,plotlyOutput("plot")
             )         
        )
        ,column(width=3
                ,box(width=NULL, title = "Select Data Source"
                               , solidHeader = T
                               , status = "primary"
                     ,selectInput("currency", label = "Select currency"
                                  ,choices = c( "Bitcoin" = 1
                                                ,"Ethereum" = 2
                                                ,"Litecoin" = 3
                                                ,"EOS" = 4
                                                ,"Ripple" = 5)
                                  ,selected = 1
                     )
                     
                     ,selectInput("tipo", label = "Graph Type"
                                  ,choices = c("Linear" = 1, "Log" = 2, "Candles" = 3)
                                  ,selected = 1
                                  )
                )
                ,box(width=NULL, title = "Select Date Range"
                    ,solidHeader = T
                    ,status = "primary"
                    ,sliderInput("drSlider"
                                  , NULL # "Select Date Range:"
                                  , min = as.Date("2000-01-01")
                                  , max = Sys.Date()
                                  , value = c(as.Date("2000-01-01"), Sys.Date())
                                  , step=1
                                  ) 
                   ,dateRangeInput('drRange'
                                   ,label=""
                                   ,start = Sys.Date() - 3
                                   , end = Sys.Date() + 3
                                   , min = Sys.Date() - 10
                                   , max = Sys.Date() + 10
                                   , separator = " - "
                                   , format = "dd/mm/yy"
                                   , weekstart = 1
                                   )
                )
        )        
    )
    ,fluidRow(box( width=5, solidHeader = T, status = "primary"
                  ,title=fluidRow( column(2,"Day")
                                 ,column(5,div(style = "height:20px;"
                                               ,dateInput('dateSelect',label = NULL
                                                            # ,value = "01/01/2016"
                                                            ,min = Sys.Date() - 5
                                                            ,max = Sys.Date() + 5
                                                            # ,format = "dd/mm/yyyy"
                                                            ,weekstart = 1
                                                        )
                                       )
                                 ) 
                                )
                   , tableOutput("registro")
               )
              
              ,box( width=7 ,title = "Trends", solidHeader = T, status = "primary"
                    ,fluidRow( 
                               column(3, div(style = "height:20px;", h4(checkboxInput("chk1", label = "Week", value = FALSE))))
                              ,column(1, div(style = "height:30px;", imageOutput("imgWeek", width="16px", height="16px")))
                    )
                    ,fluidRow( 
                                column(3, div(style = "height:20px;", h4(checkboxInput("chk2", label = "Fortnight", value = FALSE))))
                               ,column(1, div(style = "height:30px;",imageOutput("imgFort", width="16px", height="16px")))
                    )
                    ,fluidRow( 
                                column(3, div(style = "height:20px;", h4(checkboxInput("chk3", label = "Month", value = FALSE))))
                               ,column(1, div(style = "height:30px;", imageOutput("imgMonth", width="16px", height="16px")))
                    )
                    ,fluidRow( 
                                column(3, div(style = "height:20px;",h4(checkboxInput("chk4", label = "Quarter", value = FALSE))))
                               ,column(1, div(style = "height:30px;",imageOutput("imgQuarter", width="16px", height="16px")))
                    )
            )
      )
    ,box( width=NULL, solidHeader = T, status = "primary",title="Usage"
          ,tags$p(h4("Currency"))
          ,tags$p("Select one of available currencies")
          ,tags$p("")
          ,tags$p(h4("Graph Type"))
          ,tags$p("Select one of three graph availables:")
          ,tags$ol(
               tags$li(tags$b("linear"), " - Show prices in linear mode")
              ,tags$li(tags$b("logarithmic"), " - Show prices in log mode")
              ,tags$li(tags$b("candle"), " - Show Candlestick graph")
          )
          ,tags$p(h4("Date Ranges"))
          ,tags$p("By default graph show all data available")
          ,tags$p("You can select a range using the slider or the date range. (Note that both controls are synchonized")
          ,tags$p("")

          ,tags$p(h4("Selecting a day"))
          ,tags$p("You can select an specific day using these methods:")
          ,tags$ul(
               tags$li("Clicking directly on one data in graph (It may not easy depending on how much data are sohowed)")
              ,tags$li("Selecting directly a date on Day box")
          )
          ,tags$p("")
          ,tags$p(paste("When you have a day selected prices for that day are showed and Median Mobiles can be selected."
                        ,"Showing the tendence line on graph and an icon "
                        )
                  )
          ,tags$p("")
          
          ,tags$p(h4("Data Sources"))
          ,tags$p("For this sample data is static -stored on data directory-")
          ,tags$p(paste( "Correct data source should be a database with updated prices"
                        ," but then we need to implement database server and connections"))
          
          
    )

)

dashboardPage(
    header,
    dashboardSidebar(disable = TRUE),
    body
)

