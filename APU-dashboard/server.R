
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
    pm25_rank_order <- reactive(input$select_pm25_rank_order)
    # brk_aq <- reactive(input$brk_selector_aq)
    # brk_pm <- reactive(input$brk_selector_pm)
    # number <- reactive(input$number_selector)

    observe({
        message("#------------#")
        message(countryName())
        message(themeName())
        message(popName())
        message("#------------#")
    })

    ##### MAP ######
    observeEvent(countryName(), {
        countryName = countryName()
        if(countryName=="India"){
            view = list(lng = 78, lat = 22, zoom = 5.1)    
        }
        

        leafletProxy("main_map") %>%
            # main_map %>%
            addMapPane("boundary", zIndex=490) %>% # 最上
            addMapPane("pop", zIndex=410) %>% #最下
            addMapPane("theme_pm25", zIndex=430) %>% # 最上
            addMapPane("theme_AQstation", zIndex = 420) %>% #中間 
            setView(lng=view$lng, lat=view$lat, zoom=view$zoom) %>%
            setMaxBounds(lng1=102, lat1=40, lng2=53, lat2=1) %>% 
            addMap_boundary(countryName = countryName) #%>%
            # addMap_pop(countryName=countryName)
        
       
        
    })

    observeEvent(themeName(), {
        countryName = countryName()
        # countryName = "India"
        themeName = themeName()
        # themeName = "AQ Station"
        
        
        country_boundary_layer_name = paste0(countryName, " Cities")
        country_theme_layer_name = paste0(countryName, " ", themeName)
        country_pop_layer_name = paste0(countryName, " Selected Group Population")

        leafletProxy("main_map") %>%
            ## main_map %>%
            addMap_theme(themeName=themeName, countryName = countryName) %>%
            addLayersControl(
                baseGroups = BASE_GROUPS,
                overlayGroups = c(country_theme_layer_name, country_boundary_layer_name
                                  , country_pop_layer_name
                                  ),
                options = layersControlOptions(collapsed = FALSE)
            ) #%>% hideGroup(country_pop_layer_name)

        
    })
    
    observeEvent(popName(), {
      countryName = countryName()
      popName = popName()
      
      country_pop_layer_name = paste0(countryName, " Selected Group Population")
      
      
      leafletProxy("main_map") %>%
        clearGroup(country_pop_layer_name) %>% 
        # removeControl() %>% 
        addMap_popName(countryName = countryName, popName = popName) 
      
      
    })
    
    ##### Cities Rank ######
    observeEvent({
      themeName()
      popName()
      pm25_rank_order()
      1
    }, {
      countryName = countryName()
      themeName=themeName()
      popName = popName()
      
      # popName = "pregs"
      if(themeName=="AQ Station"){
        orderfield = "group_a_prec"
      }
      if(themeName=="PM2.5"){
        orderfield = pm25_rank_order()
        #orderfield = "group_c_prec"
      }
      
      
      
      rankPlotData = getRankPlotData(countryName, themeName=themeName, popName=popName)
      #rankPlotData = getRankPlotData(countryName, themeName="PM2.5", popName="all")
      
      
      
      output$rank_stacked_chart <- renderPlotly({
        if(nrow(rankPlotData)>0){
          drawStackedChart(rankPlotData, orderfield, themeName)
        }
      })
      
      output$rank_table <- DT::renderDataTable({
        d = getRankTable(rankPlotData, themeName)
        field_format_comma = names(d) %>% .[grep("#",.)]
        field_format_perc = names(d) %>% .[grep("%",.)]
        
        DT::datatable(d, 
                      option = list(
                        autoWidth = TRUE,
                        select = list(style = 'os', items = 'row'),
                        deferRender = TRUE, scrollY = 450, scrollX=400 , scroller = TRUE,
                        fixedColumns = list(leftColumns = 1)
                      ),
                      rownames = FALSE,
                      extensions = c("Scroller", "Select", "FixedColumns"),
                      selection = 'none'
          ) %>% 
          formatCurrency(columns = field_format_comma, currency = "", digits=0, interval = 3, mark = ",") %>% 
          formatPercentage(columns = field_format_perc, digits=2)
      }, server = FALSE
      )
      
    })
    
    
    ##### Inspect City ######
    observeEvent({
      input$main_map_shape_click
      popName()
      1
      }, {
      bound_id = input$main_map_shape_click$id
      #bound_id = "IND.11.25_1"
      message(bound_id)
      countryName = countryName()
      themeName = themeName()
      popName = popName()
      
      # 出錯 IND.7.26_1
      # IND.7.13_1
      # IND.29.20_1
      # IND.34.55_1
      
      
      if(themeName=="AQ Station"){
        data = getStationData(countryName)
        field="station"
      }else if(themeName =="PM2.5"){
        data = getPM25Data(countryName)
        field = "pm25"
      }
      
      tryCatch({
        this_data = data %>% dplyr::filter(ID_2==bound_id)
        
        output$ui_city_situaion <- renderUI({
          generateUI_city_situation(this_data, field, popName)
        })  
      }, error = function(e){
        message("NO RESULT!!")
        
        output$ui_city_situaion <- renderUI({
          h3("Please select city from the map")
        })  
        
      })
      
      
      
      tryCatch({
        rankPlotData = getRankPlotData(countryName, themeName=themeName, popName=popName)
        
        output$plot_city_propotion <- renderPlotly({
          drawRankChart_city(rankPlotData, bound_id, themeName = themeName)  
        })  
      }, error = function(e){
        message("NO RESULT!!")
        
        output$plot_city_propotion <- renderPlotly({
          NULL
        })  
        
      })
      
      
      
      
      
      
    })
    
    

    
})
