library(RMySQL,   quietly = T, warn.conflicts = F)
library(ggplot2,  quietly = T, warn.conflicts = F)
## This code is necessary to test the program because data can not be 
## stored into a database

btc = read.csv("data/BTC.csv", dec=",", sep=";")
eos = read.csv("data/EOS.csv", dec=",", sep=";")
eth = read.csv("data/ETH.csv", dec=",", sep=";")
xrp = read.csv("data/XRP.csv", dec=",", sep=";")
ltc = read.csv("data/LTC.csv", dec=",", sep=";")

btc$Fecha = as.Date(btc$Fecha, format="%d/%m/%Y")
eth$Fecha = as.Date(eth$Fecha, format="%d/%m/%Y")
eos$Fecha = as.Date(eos$Fecha, format="%d/%m/%Y")
ltc$Fecha = as.Date(ltc$Fecha, format="%d/%m/%Y")
xrp$Fecha = as.Date(xrp$Fecha, format="%d/%m/%Y")

getLocalData <- function(currency) {
    df <- switch(currency , btc, eth, ltc, eos, xrp)
    df[order(df$Fecha),] 
}

getData <- function (tb.name) {
   mydb = getConnection()
   data <- dbReadTable(conn = mydb, name = tb.name)
   dbDisconnect(mydb)
   data$Fecha = as.Date(data$Fecha)
   data[order(data$Fecha),] 
}


getCurrencies <- function() {
    mydb = getConnection()
    data <- dbReadTable(conn = mydb, name = "monedas")
    dbDisconnect(mydb)
    setNames(as.list(data$tabla), as.list(data$nombre))
}

getConnection <- function() {
    dbConnect(MySQL(), user='CTC', password='ctc', dbname='CTC')
}
