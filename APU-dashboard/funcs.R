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
  readRDS(paste0("data/final/", getCountryNameAbbr(countryName), "_station_data.rds"))  
}

getPM25Data = function(countryName){
  # pm = read.csv("../something/india/pm25_5_25_50_allinone/all_5_25_50_onefile.csv") %>% as_tibble()
  # pm2 = readOGR("../something/india/pm25_5_25_50_allinone/pm25_5_25_50_allinone.shp") %>% st_as_sf() %>% st_drop_geometry() %>%as_tibble() %>% dplyr::select(ID_2,NAME_1, NAME_2)
  # 
  # pm %<>% left_join(pm2)
  # 
  # # 處理同名城市問題
  # dup_name = pm %>% dplyr::select(ID_2, NAME_1,  NAME_2) %>% group_by(NAME_2) %>% filter(n()>1) %>% mutate(NAME_2 = paste0(NAME_2, " (",NAME_1,")")) %>% ungroup %>% dplyr::select(-NAME_1)
  # 
  # pm = rows_update(pm, dup_name, by="ID_2")
  # 
  # pm %<>% transmute(name = NAME_2, ID_2,
  #                 # pm25_all = all_all,
  #                  pm25_all_all = all_all, pm25_all_5u = all_pm25_5, pm25_all_25u = all_pm25_25, pm25_all_50u = all_pm25_50,
  #                  pm25_pregs_all = pregs_all, pm25_pregs_5u = pregs_pm25_5, pm25_pregs_25u = pregs_pm25_25, pm25_pregs_50u = pregs_pm25_50,
  #                  pm25_child_all = child_all, pm25_child_5u = child_pm25_5, pm25_child_25u = child_pm25_25, pm25_child_50u = child_pm25_50,
  #                  pm25_old_all = X65_all, pm25_old_5u = X65_pm25_5, pm25_old_25u = X65_pm25_25, pm25_old_50u = X65_pm25_50
  #                  )
  # saveRDS(pm, paste0("data/final/", countryName, "_pm25_data.rds"))
  
  readRDS(paste0("data/final/", getCountryNameAbbr(countryName), "_pm25_data.rds"))
}

getBoundary = function(countryName){
  # boundary = readOGR(paste0("../something/india/India_border.geojson")) %>% st_as_sf()
  # border_sp = readRDS(paste0("data/final/",countryName,"_border.rds")) %>% st_as_sf() %>% 
  #   dplyr::select(-ID_0, -COUNTRY, -NAME_1, -NL_NAME_1, -VARNAME_2, -NL_NAME_2, -TYPE_2, -ENGTYPE_2, -CC_2, -HASC_2)
  
  
  #######----- 把border 和 station.csv & pm25.csv 綁在一起 -----#######
  # pm25 = getPM25Data(countryName)
  # station = getStationData(countryName)
  # border_sp %<>% left_join(station, by="ID_2") %>% left_join(pm25, by="ID_2")
  # saveRDS(border_sp, paste0("data/final/",countryName,"_border.rds"))
   
  readRDS(paste0("data/final/",getCountryNameAbbr(countryName),"_border.rds")) 
}

getStation = function(countryName){
  readRDS(paste0("data/final/",getCountryNameAbbr(countryName),"_station.rds"))
}

getPM25Layer = function(countryName){
  raster(paste0("data/final/", getCountryNameAbbr(countryName), "_pm25.tif"))
}

getPopNameLayer = function(countryName, popName=c("pop", "pregs", "old", "infant")){
  raster(paste0("data/final/", getCountryNameAbbr(countryName), "_", popName,".tif"))
}

getPopNameLayerBrk = function(countryName, popName=c("pop", "pregs", "old", "infant")){
  readRDS(paste0("data/final/", getCountryNameAbbr(countryName), "_", popName,"_brk.rds"))
}

addMap_boundary = function(map, countryName){
  boundary = getBoundary(countryName)
  layerName = paste0(countryName, " Cities")
  
  labels <- paste0("<h4 style='text-align: center;'>",boundary$NAME_2,"</h4>") %>% lapply(htmltools::HTML)
  
  map %>%
   # main_map %>% 
  addPolygons(
    data = boundary,
    layerId = ~ID_2,
    
    ###### no hide ######
    weight = 2,
    opacity = 1,
    color = "#999",
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
      style = list("font-weight" = "normal"),
      textsize = "16px",
      direction = "auto"
    ), 
    group = layerName
    ,options = pathOptions(pane = "boundary")
  ) 
}

addMap_popName = function(map, countryName, popName){
  popRaster = getPopNameLayer(countryName, popName)
  # layerName = paste0(countryName, " Population")
  country_pop_layer_name = paste0(countryName, " Selected Group Population")
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
    addRasterImage(popRaster, colors = pal, opacity = 0.7, group = country_pop_layer_name , options = tileOptions(pane = "pop")
    ) %>%
    addLegend(pal=pal, values = brks, title = layerTitle, position="bottomleft", group = country_pop_layer_name, layerId = country_pop_layer_name
              # ,labFormat = function(type, cuts, p) {  paste0(labels) }
    )


}

addMap_AQ_station = function(map, countryName){
  station = getStation(countryName)  
  layerName = paste0(countryName, " AQ Station")
  layerId = paste0(countryName, "_layer_AQStation")
  
  map %>% 
    addCircles(data = station,
               group = layerName,
               options = pathOptions(pane = "theme_AQstation")
    )
}

addMap_pm25 = function(map, countryName){
  pm25 = getPM25Layer(countryName)
  layerName = paste0(countryName, " PM2.5")
  layerId = paste0(countryName, "_layer_legend_pm25")
  
  brks = c(0, 5, 25, 50, 999)
  pal = colorBin(palette = COLOR_BRK, bins = brks, domain = brks, na.color="transparent")
  
  map %>%
  # main_map %>% 
    addRasterImage(pm25, colors = pal, opacity = 0.5, group = layerName #, options = tileOptions(pane = "theme_pm25")
                   ) %>% 
    addLegend(pal=pal, values = brks, title = "PM2.5 concentration", position="bottomleft", layerId = layerId)
}


clearMap_theme = function(map, countryName){
  theme_layer_names = paste0(countryName, c(" AQ Station", " PM2.5"))
  
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
  d %<>% dplyr::select(name, ID_2, group_all, starts_with(field_selector))
  names(d) <- c("name", "ID_2", "group_all", group_brks)
  
  d %<>% mutate(across(-c(name, ID_2, group_all), ~ round(.x/group_all,6), .names = "{.col}_prec" ))
  
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
      dplyr::select(name, ID_2, THEME_BREAK_TABLE %>% dplyr::filter(theme==themeName) %>% pull(var)) #reorder the columns
    
    
}


# d1 = getRankPlotData(countryName, themeName="PM2.5", popName="all")
# rankPlotData = getRankPlotData(countryName, themeName="PM2.5", popName="all")
# AQ: group_a_prec, head(100)

drawStackedChart = function(rankPlotData, orderfield, themeName){
  countryAvg = rankPlotData %>% 
    mutate_at(.vars = vars(group_all, ends_with("_num")), .funs = sum) %>% 
    dplyr::select_at(.vars = vars(group_all, ends_with("_num"))) %>% distinct() %>% 
    mutate(across(ends_with("_num"), ~round(.x/group_all,6), .names = "{.col}_prec")) %>% 
    rename_if(grepl("_num", names(.)), ~gsub("_num","",.x)) %>% 
    mutate(name = "COUNTRY AVG") %>% 
    mutate(across(ends_with("prec"), ~.x*100)) %>% 
    mutate(across(ends_with("prec"), ~round(.x,2))) 
  
  d = rankPlotData %>% arrange_at(.vars = orderfield, desc) %>% head(50) %>% 
    mutate(across(ends_with("prec"), ~.x*100)) %>% 
    mutate(across(ends_with("prec"), ~round(.x,2))) 

    
  tb = THEME_BREAK_TABLE %>% filter(theme==themeName) %>% dplyr::select(-theme)
  
  p_avg = 
    plot_ly(countryAvg, y=~name, x=~group_a_prec, type='bar', 
          name = filter(tb, var=="group_a_prec")%>% pull(varName), 
          text = filter(tb, var=="group_a_prec")%>% pull(varName), 
          hoverinfo = "x+y",
          hovertemplate = "%{y}: %{x}%",
          marker = list(color = COLOR_BRK[1])) %>% 
    add_trace(x=~group_ab_prec, 
              name = filter(tb, var=="group_ab_prec")%>% pull(varName), 
              text = filter(tb, var=="group_ab_prec")%>% pull(varName), 
              hoverinfo = "x+y",
              hovertemplate = "%{y}: %{x}%",
              marker = list(color = COLOR_BRK[2])) %>% 
    add_trace(x=~group_bc_prec, 
              name = filter(tb, var=="group_bc_prec")%>% pull(varName), 
              text = filter(tb, var=="group_bc_prec")%>% pull(varName), 
              hoverinfo = "x+y",
              hovertemplate = "%{y}: %{x}%",
              marker = list(color = COLOR_BRK[3])) %>% 
    add_trace(x=~group_c_prec, 
              name = filter(tb, var=="group_c_prec")%>% pull(varName), 
              text = filter(tb, var=="group_c_prec")%>% pull(varName), 
              hoverinfo = "x+y",
              hovertemplate = "%{y}: %{x}%",
              marker = list(color = COLOR_BRK[4])) %>% 
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
                marker = list(color = COLOR_BRK[1])) %>% 
      add_trace(x=~group_ab_prec, 
                name = filter(tb, var=="group_ab_prec")%>% pull(varName), 
                text = filter(tb, var=="group_ab_prec")%>% pull(varName), 
                hoverinfo = "x+y",
                hovertemplate = "%{y}: %{x}%",
                marker = list(color = COLOR_BRK[2])) %>% 
      add_trace(x=~group_bc_prec, 
                name = filter(tb, var=="group_bc_prec")%>% pull(varName), 
                text = filter(tb, var=="group_bc_prec")%>% pull(varName), 
                hoverinfo = "x+y",
                hovertemplate = "%{y}: %{x}%",
                marker = list(color = COLOR_BRK[3])) %>% 
      add_trace(x=~group_c_prec, 
                name = filter(tb, var=="group_c_prec")%>% pull(varName), 
                text = filter(tb, var=="group_c_prec")%>% pull(varName), 
                hoverinfo = "x+y",
                hovertemplate = "%{y}: %{x}%",
                marker = list(color = COLOR_BRK[4])) %>% 
      layout(barmode = 'stack', showlegend = FALSE,
             xaxis = list(title = "%"),
             yaxis = list(title = "", categoryorder = "array", categoryarray = rev(d$name))
             )

    subplot(p_avg, p, nrows=2, shareX = TRUE, heights = c(0.05, 0.95),
            margin = 0.005
            )

}


getRankTable = function(rankPlotData, themeName){
  field_show = c("name", "group_all",
                 "group_a_num", "group_ab_num", "group_bc_num", "group_c_num",
                 "group_a_prec", "group_ab_prec", "group_bc_prec", "group_c_prec")
  d = rankPlotData %>% dplyr::select(!!field_show) %>% arrange(desc(group_all))
  tb = THEME_BREAK_TABLE %>% filter(theme==themeName) %>% dplyr::select(-theme) %>% 
    filter(var%in%field_show)
  names(d) <- c("city name", tb %>% pull(varName))
  
  
  d
}

#### City Inspect ####
# d = getStationData(countryName)

generateUI_city_situation = function(this_data, field, popName){
  #this_data #%>% dplyr::select(name, starts_with(paste0(field, "_", popName)))
  # field_total_all = paste0(field, "_all_all")
  # field_child_all = paste0(field, "_child_all")
  # field_old_all = paste0(field, "_old_all")
  # field_pregs_all = paste0(field, "_pregs_all")
  # 
  
  
  
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
      h3(paste0(this_data$name)),
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
  
  dt = rankPlotData %>% filter(ID_2==bound_id) %>% 
    tidyr::gather("var", "value") %>% 
    filter(var%in%c("group_a_prec", "group_ab_prec", "group_bc_prec", "group_c_prec")) %>% 
    mutate(value = as.numeric(value) %>% "*"(100) %>% round(2)) %>% 
    left_join(., tb, by="var")
  
  
  plot_ly(dt, y = ~varName, x=~value, type="bar", 
          text = ~paste0(value, "%"), 
          textposition = 'auto', 
          hoverinfo = "y",
          hoverlabel = list(font = list(size=18)),
          marker = list(color=COLOR_BRK)
          ) %>% 
    layout(
      font = list(size=18),
      yaxis=list(title="", categoryorder = "array", categoryarray = rev(dt$varName), 
                 showticklabels = FALSE
                 ), 
      xaxis = list(title = "%"))
    
}
