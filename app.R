btc = read.csv("data/BTC.csv", dec=",", sep=";")
eos = read.csv("data/EOS.csv", dec=",", sep=";")
eth = read.csv("data/ETH.csv", dec=",", sep=";")
xrp = read.csv("data/XRP.csv", dec=",", sep=";")
ltc = read.csv("data/LTC.csv", dec=",", sep=";")

btc$Fecha = as.Date(btc$Fecha)
eth$Fecha = as.Date(eth$Fecha)
eos$Fecha = as.Date(eos$Fecha)
ltc$Fecha = as.Date(ltc$Fecha)
xrp$Fecha = as.Date(xrp$Fecha)

source('ui.R')
source('server.R')
