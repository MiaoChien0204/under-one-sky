#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {


# MAP ---------------------------------------------------------------------
    observe({
        if(input$navbar=="India"){
            boundary = getBoundary()
            view = list(lng = 78, lat = 22, zoom = 5.1)
        }
    
    
        output$main_map <- leaflet::renderLeaflet(
           
            leaflet(boundary) %>%
                addProviderTiles(provider = providers$Stamen.TonerBackground) %>%
                setView(lng=view$lng, lat=view$lat, zoom=view$zoom) %>% 
                addPolygons(
                    fill = TRUE,
                    weight = 2,
                    fillOpacity = 0,
                    color = "gray",
                    dashArray = "3",
                    highlightOptions = highlightOptions(
                        weight = 5,
                        color = "red",
                        dashArray = "",
                        bringToFront = TRUE),
                    label = ~NAME_2,
                    labelOptions = labelOptions(
                        style = list("font-weight" = "normal", padding = "3px 8px"),
                        textsize = "15px",
                        direction = "auto")
                )
            
             
        )

    })
})
