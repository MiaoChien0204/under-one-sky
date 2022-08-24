getCountryNameAbbr = function(countryName, tolower=TRUE){
  COUNTRIES = c("Colombia" = "COL", "India" = "IND", "Indonesia" = "IDN", "Malaysia" = "MYS", "Philippines" = "PHL", "SouthAfrica" = "ZAF", "Thailand" = "THA", "Turkey" = "TUR")
  name = COUNTRIES[countryName] %>% unname
  if(tolower){
    tolower(name)
  }else{
    name
  } 
}


getStationData = function(countryName){
  readRDS(paste0("data/",countryName,"/station_data_L",BOUND_LV,".rds"))
}

getPM25Data = function(countryName){
  readRDS(paste0("data/",countryName,"/pm25_data_L",BOUND_LV,".rds"))  
}

getBoundary = function(countryName){
  readRDS(paste0("data/",countryName,"/border_LV",BOUND_LV,".rds"))  
}

getStation = function(countryName){
  readRDS(paste0("data/",countryName,"/station.rds"))  
}

getPM25Layer = function(countryName){
  raster(paste0("data/",countryName,"/pm25.tif"))  
}

getPopNameLayer = function(countryName, popName=c("pop", "pregs", "old", "child")){
  raster(paste0("data/",countryName,"/pop_",popName,".tif"))  
}

getPopNameLayerBrk = function(countryName, popName=c("pop", "pregs", "old", "child")){
  readRDS(paste0("data/",countryName,"/pop_",popName,"_brk.rds"))
}

addMap_boundary = function(map, countryName){
  boundary = getBoundary(countryName)
  layerName = LAYER_BOUNDARY_NAME
  labels <- paste0("<h4 style='text-align: center;'>",boundary[[NAME]],"</h4>") %>% lapply(htmltools::HTML)
  
  map %>%
   # main_map %>%
  addPolygons(
    data = boundary,
    layerId = ~get(ID),
    
    ###### no hide ######
    weight = 1,
    opacity = 1,
    color = "#CDCDCD",
    dashArray = "3",
    fillOpacity = 0,
    
    ###### hide ######
    # stroke = FALSE,
    # fill = TRUE,
    # fillOpacity = 0,
    # dashArray = "3",
    highlightOptions = highlightOptions(
      weight = 5,
      color = "red",
      dashArray = "",
      bringToFront = TRUE),
    ######
    label = labels,
    labelOptions = labelOptions(
      direction = "top",
      style = list(
        "font-weight" = "900",
        "font-size" = "20px"
      )
    ), 
    group = layerName
    # ,options = pathOptions(pane = "boundary")
  ) 
  
}

# bound_id = "IND.29.4_1"
addMap_selectCity = function(map, countryName, bound_id){
  bound = getBoundary(countryName) %>% filter(get(ID)==bound_id)
  layerName = "selected city"
  labels <- paste0("<h4 style='text-align: center;'>",bound[[NAME]],"</h4>") %>% lapply(htmltools::HTML)
  
  if(nrow(bound)!=0){
    map %>%
      # main_map %>% 
      addPolygons(
        data = bound, 
        weight = 5,
        color = "#FF00C9",
        fillOpacity = 0,
        group = layerName,
        label = labels,
        labelOptions = labelOptions(
          noHide = T, 
          direction = "top",
          style = list(
            "font-weight" = "900",
            "font-size" = "20px"
          )
          
        ), 
        options = pathOptions(pane = layerName)
      )
  }
}

cleanMap_selectCity = function(map){
  map %>% 
    # main_map %>% 
    clearGroup("selected city")
}

addMap_popName = function(map, countryName, popName){
  popRaster = getPopNameLayer(countryName, popName)
  # layerName = paste0(countryName, " Population")
  country_pop_layer_name = LAYER_POP_NAME
  brks = getPopNameLayerBrk(countryName, popName)

  if(popName=="all"){
    # brks = c(0, 100, 200, 300, 400, 500, 1000, 3000, 5000, 7010) #11
    # brks = c(0, 15, 40, 80, 160, 400, 1000, 2000, 4500, 6500, Inf)
    layerTitle = paste0(countryName, " All Population")
    # values(popRaster)[values(popRaster) == 0] = NA
  }
  if(popName=="old"){
    # brks = c(0, 1, 3, 6, 15, 40, 100, 150, 200, 350, Inf)
    layerTitle = paste0(countryName, " Elderlies (65+)")
    # values(popRaster)[values(popRaster) == 0] = NA
  }
  if(popName=="pregs"){
    # brks = c(0, 6, 15, 30, 60, 120, 250, 400, 650, Inf)
    layerTitle = paste0(countryName, " Pregnant Women")
    # values(popRaster)[values(popRaster) == 0] = NA
  }
  if(popName=="child"){
    # brks = c(0, 0.3, 0.8, 1.5, 3.5, 8.5, 21, 40, 70, Inf)
    layerTitle = paste0(countryName, " Infants (0-4)")
    # values(popRaster)[values(popRaster) == 0] = NA
  }
  


  pal <- colorBin(palette = c("#f0f0f0", "black"), bins = brks, pretty = TRUE, 
                  domain=brks, na.color = "transparent")


  map %>%
    # main_map %>%
    addRasterImage(popRaster, colors = pal, opacity = 0.4, group = country_pop_layer_name , options = tileOptions(pane = "pop")
    ) %>%
    addLegend(pal=pal, values = brks, title = layerTitle, position="bottomleft", group = country_pop_layer_name, layerId = country_pop_layer_name
              # ,labFormat = function(type, cuts, p) {  paste0(labels) }
    )


}

addMap_AQ_station = function(map, countryName){
  station = getStation(countryName)  
  layerName = "AQ Station"
  layerId = paste0(countryName, "_layer_AQStation")
  
  map %>% 
    addCircles(data = station,
               group = layerName,
               options = pathOptions(pane = "theme_AQstation")
    )
}

addMap_pm25 = function(map, countryName){
  pm25 = getPM25Layer(countryName)
  layerName = "PM2.5"
  layerId = paste0(countryName, "_layer_legend_pm25")
  
  
  
  if(countryName=="India"){
    brks = c(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 75, 100, Inf)
    pal = colorBin(palette = COLOR_BRK_map_india, bins = brks, domain = brks, na.color="transparent")
  }else{
    brks = c(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, Inf)
    pal = colorBin(palette = COLOR_BRK_map, bins = brks, domain = brks, na.color="transparent")  
  }
  
  
  map %>%
  # main_map %>%
    addRasterImage(pm25, colors = pal, opacity = 0.6, group = layerName #, options = tileOptions(pane = "theme_pm25")
                   ) %>% 
    addLegend(pal=pal, values = brks, title = "PM2.5 concentration", position="bottomleft", layerId = layerId)
}


clearMap_theme = function(map, countryName){
  theme_layer_names = c("AQ Station", "PM2.5")
  
  map %>% 
    removeControl(paste0(countryName, "_layer_legend_pm25")) %>% 
    clearGroup(theme_layer_names)
    
}

addMap_theme = function(map, themeName, countryName){
  if(themeName=="AQ Station"){
    map %>% 
      clearMap_theme(countryName) %>% 
      # removeControl(c("layer_AQstation", "layer_pm25")) %>% 
      addMap_AQ_station(countryName)
  }else if(themeName=="PM2.5"){
    map %>% 
      clearMap_theme(countryName) %>% 
      # removeControl(c("layer_AQstation", "layer_pm25")) %>% 
      addMap_pm25(countryName)
  }
}


### rank

getRankPlotData = function(countryName, themeName, popName){
  if(themeName=="AQ Station"){
    d = getStationData(countryName)
    fieldName = "station"
  }else if(themeName =="PM2.5"){
    d = getPM25Data(countryName)
    fieldName = "pm25"
  }
  
  
  field_selector = paste0(fieldName, "_", popName)
  group_all = paste0(fieldName, "_", popName, "_all")
  brks = c("A", "B", "C")
  group_brks = paste0("group", "_", brks)
  
  # 暴力改名法，小心不能出錯
  # 只成立在 Station 和 PM2.5 的 break point 組數一樣時
  d %<>% dplyr::select(NAME, ID, group_all, starts_with(field_selector))
  names(d) <- c(NAME, ID, "group_all", group_brks)
  
  d %<>% mutate(across(group_brks, ~round(.x/group_all, 6), .names = "{.col}_prec"))
  
  
  if(themeName=="AQ Station"){
    d %<>% mutate(
      group_a_prec = group_A_prec, 
      group_ab_prec = group_B_prec-group_A_prec,
      group_bc_prec = group_C_prec-group_B_prec,
      group_c_prec = 1-group_C_prec
    )
    
  }
  if(themeName=="PM2.5"){
    d %<>% mutate(
      group_a_prec = 1-group_A_prec,
      group_ab_prec = group_A_prec-group_B_prec, 
      group_bc_prec = group_B_prec-group_C_prec,
      group_c_prec = group_C_prec
    )
  }
  
  
    d %>% mutate(across(c("group_a_prec", "group_ab_prec", "group_bc_prec", "group_c_prec"), ~round(.x * group_all, 0), .names ="{.col}_num")) %>% 
    rename_if(grepl("_num", names(.)), ~gsub("_prec","",.x)) %>% 
      dplyr::select(NAME, ID, THEME_BREAK_TABLE %>% dplyr::filter(theme==themeName) %>% pull(var)) %>%  #reorder the columns
      replace(is.na(.), 0) 
    
    
}


# d1 = getRankPlotData(countryName, themeName="PM2.5", popName="all")
# rankPlotData = getRankPlotData(countryName, themeName="PM2.5", popName="all")
# AQ: group_a_prec, head(100)

# orderfield = "group_c_prec"
# themeName = "PM2.5"
drawStackedChart = function(rankPlotData, orderfield, themeName){
  
  
  countryAvg =
    rankPlotData %>% 
    mutate_at(.vars = vars(group_all, ends_with("_num")), .funs = sum) %>% 
    dplyr::select_at(.vars = vars(group_all, ends_with("_num"))) %>% distinct() %>% 
    mutate(across(ends_with("_num"), ~round(.x/group_all,6), .names = "{.col}_prec")) %>% 
    rename_if(grepl("_num", names(.)), ~gsub("_num","",.x)) %>% 
    mutate( name = "COUNTRY AVG") %>% 
    mutate(across(ends_with("prec"), ~.x*100)) %>% 
    mutate(across(ends_with("prec"), ~round(.x,2))) 
  
  # if(orderfield=="group_c_prec" & countryAvg$group_c_prec==0) orderfield = "group_bc_prec"
  # if(orderfield=="group_a_prec" & countryAvg$group_a_prec==0) orderfield = "group_ab_prec"
  
  if(orderfield == "group_c_prec"){
    d = rankPlotData %>% arrange(
      desc(group_c_prec),
      desc(group_bc_prec),
      desc(group_ab_prec),
      desc(group_a_prec)
    )
  }else{
    d = rankPlotData %>% arrange(
      desc(group_a_prec),
      desc(group_ab_prec),
      desc(group_bc_prec),
      desc(group_c_prec)
    )
  }
  
  
   d %<>% head(30) %>% 
    mutate(across(ends_with("prec"), ~.x*100)) %>% 
    mutate(across(ends_with("prec"), ~round(.x,2))) %>% 
    rename(name = !!NAME)

  tb = THEME_BREAK_TABLE %>% filter(theme==themeName) %>% dplyr::select(-theme)
  
  p_avg = 
    plot_ly(countryAvg, y=~name, x=~group_a_prec, type='bar', 
          name = filter(tb, var=="group_a_prec")%>% pull(varName), 
          text = filter(tb, var=="group_a_prec")%>% pull(varName), 
          hoverinfo = "x+y",
          hovertemplate = "%{y}: %{x}%",
          marker = list(color = COLOR_BRK_data[1])) %>% 
    add_trace(x=~group_ab_prec, 
              name = filter(tb, var=="group_ab_prec")%>% pull(varName), 
              text = filter(tb, var=="group_ab_prec")%>% pull(varName), 
              hoverinfo = "x+y",
              hovertemplate = "%{y}: %{x}%",
              marker = list(color = COLOR_BRK_data[2])) %>% 
    add_trace(x=~group_bc_prec, 
              name = filter(tb, var=="group_bc_prec")%>% pull(varName), 
              text = filter(tb, var=="group_bc_prec")%>% pull(varName), 
              hoverinfo = "x+y",
              hovertemplate = "%{y}: %{x}%",
              marker = list(color = COLOR_BRK_data[3])) %>% 
    add_trace(x=~group_c_prec, 
              name = filter(tb, var=="group_c_prec")%>% pull(varName), 
              text = filter(tb, var=="group_c_prec")%>% pull(varName), 
              hoverinfo = "x+y",
              hovertemplate = "%{y}: %{x}%",
              marker = list(color = COLOR_BRK_data[4])) %>% 
    layout(barmode = 'stack', showlegend = FALSE,
           xaxis = list(title = "%"),
           yaxis = list(title = "", categoryorder = "array", categoryarray = rev(d$name))
    )
  
  
  ###
  p = plot_ly(d, y=~name, x=~group_a_prec, type='bar', 
                name = filter(tb, var=="group_a_prec")%>% pull(varName), 
                text = filter(tb, var=="group_a_prec")%>% pull(varName), 
                hoverinfo = "x+y",
                hovertemplate = "%{y}: %{x}%",
                marker = list(color = COLOR_BRK_data[1])) %>% 
      add_trace(x=~group_ab_prec, 
                name = filter(tb, var=="group_ab_prec")%>% pull(varName), 
                text = filter(tb, var=="group_ab_prec")%>% pull(varName), 
                hoverinfo = "x+y",
                hovertemplate = "%{y}: %{x}%",
                marker = list(color = COLOR_BRK_data[2])) %>% 
      add_trace(x=~group_bc_prec, 
                name = filter(tb, var=="group_bc_prec")%>% pull(varName), 
                text = filter(tb, var=="group_bc_prec")%>% pull(varName), 
                hoverinfo = "x+y",
                hovertemplate = "%{y}: %{x}%",
                marker = list(color = COLOR_BRK_data[3])) %>% 
      add_trace(x=~group_c_prec, 
                name = filter(tb, var=="group_c_prec")%>% pull(varName), 
                text = filter(tb, var=="group_c_prec")%>% pull(varName), 
                hoverinfo = "x+y",
                hovertemplate = "%{y}: %{x}%",
                marker = list(color = COLOR_BRK_data[4])) %>% 
      layout(barmode = 'stack', showlegend = FALSE,
             xaxis = list(title = "%"),
             yaxis = list(title = "", categoryorder = "array", categoryarray = rev(d$name))
             )

    subplot(p_avg, p, nrows=2, shareX = TRUE, heights = c(0.05, 0.95),
            margin = 0.005
            )

}


getRankTable = function(rankPlotData, themeName){
  
  
  field_show = c(NAME, ID,"group_all",
                 "group_a_num", "group_ab_num", "group_bc_num", "group_c_num",
                 "group_a_prec", "group_ab_prec", "group_bc_prec", "group_c_prec")
  d = rankPlotData %>% dplyr::select(!!field_show) %>% arrange(desc(group_all))
  tb = THEME_BREAK_TABLE %>% filter(theme==themeName) %>% dplyr::select(-theme) %>% 
    filter(var%in%field_show)
  names(d) <- c("name", ID, tb %>% pull(varName))
  
  
  d
}

#### City Inspect ####
# d = getStationData(countryName)

generateUI_city_situation = function(this_data, field, popName){
  
  field_all = paste0(field, "_",popName,"_all")
  
  generatePopRow = function(this_data, popName, field_all){
    numberFormat = function(num){
      formatC(num, format="f", big.mark=",", digits=0)
    }
    
    if(popName=="all"){
      title = "Total Population:"
    }
    if(popName=="child"){
      title = "Total Infant (0-4):"
    }
    if(popName=="old"){
      title = "Total Elderlies (65+):"
    }
    if(popName=="pregs"){
      title = "Total Pregnant Women:"
    }
    
    
    HTML('<tr style="height: 18px;">
      <td style="width: 50%; height: 18px;">', title,'</td>
      <td style="width: 50%; height: 18px;">', this_data %>% pull(field_all) %>% numberFormat,'</td>
      </tr>')
  }
  
  
  div(class="city_situation",
      h3(paste0(this_data[[NAME]])),
      hr(),
      HTML('
      <table style="height: 72px; width: 50%; border-collapse: collapse;" border="0">
      <tbody>
      ',generatePopRow(this_data, popName, field_all),'
      </tbody>
      </table>
      ')
  )
  
}


drawRankChart_city = function(rankPlotData, bound_id, themeName){
  
  tb = THEME_BREAK_TABLE %>% filter(theme==themeName) %>% dplyr::select(-theme)
  
  dt = rankPlotData %>% filter(get(ID)==bound_id) %>% 
    tidyr::gather("var", "value") %>% 
    filter(var%in%c("group_a_prec", "group_ab_prec", "group_bc_prec", "group_c_prec")) %>% 
    mutate(value = as.numeric(value) %>% "*"(100) %>% round(2)) %>% 
    left_join(., tb, by="var")
  
  
  plot_ly(dt, y = ~varName, x=~value, type="bar", 
          text = ~paste0(value, "%"), 
          textposition = 'auto', 
          hoverinfo = "y",
          hoverlabel = list(font = list(size=18)),
          marker = list(color=COLOR_BRK_data)
          ) %>% 
    layout(
      font = list(size=18),
      yaxis=list(title="", categoryorder = "array", categoryarray = rev(dt$varName), 
                 showticklabels = FALSE
                 ), 
      xaxis = list(title = "%"))
    
}
