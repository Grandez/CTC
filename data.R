 

setRecord <- function(input, session, dfg) {
    if (is.null(dfg)) return()
    d <- as.Date(input$dateSelect, origin=lubridate:::origin)
    rec <<- dfg %>% filter(Fecha == d)

    return(rec)
}

setTrend <- function(check, fecha, period, dfg) {
    img <- list(src = "www/none.png", alt="No data", filetype = "image/png", width=16, height=16)

    if (check) {
        segment <- calculateSegment(dfg, period, fecha)
        if (segment[1, "y"] > segment[2,"y"]) {
            res = segment[2, "y"] / segment[1,"y"]
            img$src <- "www/down.png"     
        }
        else {
            res = segment[1, "y"] / segment[2,"y"]
            img$src <- "www/up.png"     
        }
        if (res < 0.05) img$src <- "www/equal.png"     
        
    }

    renderImage({img}, deleteFile=F)
}    

# Adjust range for slider to date range and viceversa
syncRanges <- function(input, session, type) {
    if (type == 1) {
        rng <- input$drSlider
        updateDateRangeInput(session, "drRange", start = rng[1],end = rng[2])
    }
    if (type == 2) {
        rng <- input$drRange
        updateSliderInput   (session,"drSlider",value = rng)
    }
    
    if (input$dateSelect < rng[1] || input$dateSelect > rng[2]) {
        updateDateInput(session, "dateSelect", min=rng[1], max=rng[2], value=rng[2])
    }        
}    

calculateSegment <- function(data, interval, selected) {
    dateSelect = as.Date(selected, origin=lubridate::origin)
    df <- data %>% filter(Fecha <= dateSelect , Fecha >= dateSelect - interval)
    
    model <- lm(End ~ Fecha, data=df)
    
    y1 <- model$coefficients[1] + model$coefficients[2] * as.numeric(df[1,"Fecha"])
    y2 <- model$coefficients[1] + model$coefficients[2] * as.numeric(df[nrow(df),"Fecha"])
    X <- c(df[1,"Fecha"], df[nrow(df),"Fecha"])
    Y <- c(y1, y2)
    
    df <- as.data.frame(cbind(x=X, y=Y))
    df$x = as.Date(df$x, origin=lubridate:::origin)

    return(df)
}
