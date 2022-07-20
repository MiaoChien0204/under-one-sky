
library(shiny)
source("funcs.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {


# MAP ---------------------------------------------------------------------
    output$main_map <- leaflet::renderLeaflet({
        main_map
    })

    countryName <- reactive(input$navbar)
    themeName <- reactive(input$theme_selector)
    popName <- reactive(input$pop_selector)
    brk <- reactive(input$brk_selector)
    number <- reactive(input$number_selector)

    observe({
        message("#------------#")
        message(countryName())
        message(themeName())
        message(popName())
        message(brk())
        message(number())
        message("#------------#")
    })

    observeEvent(countryName(), {
        countryName = countryName()
        if(countryName=="India"){
            view = list(lng = 78, lat = 22, zoom = 5.1)    
        }
        

        leafletProxy("main_map") %>%
            # main_map %>% 
            addMapPane("boundary", zIndex=430) %>% # 最上
            addMapPane("pop", zIndex=420) %>% #中間
            addMapPane("theme_pm25", zIndex=410) %>% #最下
            addMapPane("theme_AQstation", zIndex = 430) %>% # 最上
            setView(lng=view$lng, lat=view$lat, zoom=view$zoom) %>% 
            addMap_boundary(countryName = countryName) %>%
            addMap_pop(countryName=countryName)
    })

    observeEvent(themeName(), {
        countryName = countryName()
        # countryName = "India"
        themeName = themeName()
        # themeName = "AQ Station"
        
        
        country_boundary_layer_name = paste0(countryName, " Boundary")
        country_pop_layer_name = paste0(countryName, " Population")
        country_theme_layer_name = paste0(countryName, " ", themeName)

        leafletProxy("main_map") %>%
            ## main_map %>%
            addMap_theme(themeName=themeName, countryName = countryName) %>%
            addLayersControl(
                baseGroups = c("Toner", "Carto", "World Physical"),
                overlayGroups = c(country_boundary_layer_name, country_pop_layer_name, country_theme_layer_name),
                options = layersControlOptions(collapsed = FALSE)
            )

        
    })
    
    
    ##### Rank 20 ######
    observeEvent({
        themeName()
        popName()
        brk()
        number()
        1
    }, {
        popName = popName()
        # popName = "pregs"
        brk = brk()
        # brk = "25km"
        number = number()
        # number = "number of people"
        
        
        rankData = getRankData(countryName = countryName(), themeName=themeName(), popName = popName, brk=brk)
        # print(rankData)
        
        output$rank20_chart <- renderPlotly({
            drawRankChart(rankData = rankData, number = number)
        })
        
        output$rank20_table <- DT::renderDataTable({
            rankData %>% arrange(desc(main_count)) %>% 
                transmute(name, 
                          `number of people` = main_count, 
                          `% of all people` = main_all_perc, 
                          `% of this population` = main_group_perc
                          #, ID_2
                          )
        }, 
        server = FALSE, 
        extensions = c("Scroller", "Select"), 
        option = list(
            select = list(style = 'os', items = 'row'),
            deferRender = TRUE, scrollY = 250, scroller = TRUE
            ),
        selection = 'none'
        )
        
    })

    
})
