getStationData = function(countryName){
  # aq = readOGR("data/AQ_station_5_10_25_pop/AQ_station_5_10_25_pop.shp") %>% st_as_sf()
  # aq %<>% transmute(name = NAME_2, ID_2,
  #                   station_all=all,
  #                   station_all_all=all, station_all_5km = all_5km, station_all_10km = all_10km, station_all_25km=all_25km,
  #                   station_pregs_all = pregs_all, station_pregs_5km=pregs_5km, station_pregs_10km=pregs_10km, station_pregs_25km=pregs_25km,
  #                   station_child_all=child_all, station_child_5km=child_5km, station_child_10km=child_10km, station_child_25km=child_25km,
  #                   station_old_all=old_all, station_old_5km=old_5km, station_old_10km=old_10km, station_old_25km=old_25km)
  
  # saveRDS(aq, "data/final/India_station_data.rds")
  
  readRDS(paste0("data/final/", countryName, "_station_data.rds")) %>% st_drop_geometry() %>% as_tibble()
}

getPM25Data = function(countryName){
  # pm25 = read.csv(paste0("data/", countryName, "_pm25.csv")) %>% as_tibble() %>% dplyr::select(-FID, -ID_0, -COUNTRY, -NAME_1, -NL_NAME_1, -NAME_2)
  # colnames(pm25) %<>% gsub("^X", "",.)
  # colnames(pm25) <- c(colnames(pm25)[1], paste0("pm25_", colnames(pm25[2:length(pm25)])))
  # saveRDS(pm25, paste0("data/final/", countryName, "_pm25.rds"))
  readRDS(paste0("data/final/", countryName, "_pm25.rds"))
}

getBoundary = function(countryName){
  # boundary = readOGR(paste0("data/",countryName,"_border.geojson")) %>% st_as_sf()
  # border_sp = readRDS(paste0("data/final/",countryName,"_border.rds")) %>% st_as_sf() %>% 
  #   dplyr::select(-ID_0, -COUNTRY, -NAME_1, -NL_NAME_1, -VARNAME_2, -NL_NAME_2, -TYPE_2, -ENGTYPE_2, -CC_2, -HASC_2)
  
  
  #######----- 把border 和 station.csv & pm25.csv 綁在一起 -----#######
  # pm25 = getPM25Data(countryName)
  # station = getStationData(countryName)
  # border_sp %<>% left_join(station, by="ID_2") %>% left_join(pm25, by="ID_2")
  # saveRDS(border_sp, paste0("data/final/",countryName,"_border.rds"))
   
  readRDS(paste0("data/final/",countryName,"_border.rds")) 
}

getStation = function(countryName){
  # india_bound = getBoundary(countryName) %>% st_as_sf
  # all_station = jsonlite::fromJSON("OldWebsite/data/csv.json")
  # all_station = lapply(all_station$features$geometry$coordinates, FUN = function(p){
  #   tibble(lon = p[1] %>% as.numeric(),lat = p[2] %>% as.numeric())
  # }) %>% bind_rows()
  # all_station_sf = st_as_sf(all_station, coords = c("lon", "lat")) %>%
  #   st_set_crs(st_crs(india_bound))
  # india_station_sf = st_filter(all_station_sf, india_bound)
  # saveRDS(india_station_sf, "data/final/india_station.rds")
  readRDS(paste0("data/final/",countryName,"_station.rds"))
}

getPM25 = function(countryName){
  # r = raster(paste0("data/",countryName,"_pm25.tiff"))
  # crs(r) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
  # saveRDS(r, "data/india_pm25_tiff.rds")
  
  readRDS(paste0("data/final/",countryName,"_pm25_tiff.rds"))
}

getPop = function(countryName){
  # r = raster(paste0("data/", countryName, "_pop_count.tiff"))
  # saveRDS(r, "data/india_pop_count_tiff.rds")
  readRDS(paste0("data/final/",countryName,"_pop_count_tiff.rds"))
}



addMap_boundary = function(map, countryName, theme){
  boundary = getBoundary(countryName)
  layerName = paste0(countryName, " Boundary")
  
  if(theme=="AQ Station"){
    # All Population
    labels <- paste0("<h4 style='text-align: center;'>",boundary$NAME_2,"</h4>") %>% lapply(htmltools::HTML)
  }else if(theme=="PM2.5"){
    # All Population
    labels <- paste0("<h4 style='text-align: center;'>",boundary$NAME_2,"</h4>") %>% lapply(htmltools::HTML)
  }
  
  map %>%
  addPolygons(
    data = boundary,
    fill = TRUE,
    weight = 2,
    fillOpacity = 0,
    color = "#B8B8B8",
    dashArray = "3",
    highlightOptions = highlightOptions(
      weight = 5,
      color = "red",
      dashArray = "",
      bringToFront = TRUE),
    label = labels,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px",
      direction = "auto"
    ), 
    group = layerName,
    options = pathOptions(pane = "boundary")
  ) 
}

addMap_AQ_station = function(map, countryName){
  station = getStation(countryName)  
  layerName = paste0(countryName, " AQ Station")
  
  map %>% 
    addCircles(data = station,
               group = layerName,
               options = pathOptions(pane = "theme_AQstation")
    )
}

addMap_pm25 = function(map, countryName){
  pm25 = getPM25(countryName)
  layerName = paste0(countryName, " PM2.5")
  custom_colors=c("#9CD84E", "#FACF38", "#F65E5F", "#A070B6")
  pm25_seq = c(0, 5, 25, 50, 999)
  pal = colorBin(palette = custom_colors, bins = pm25_seq, domain = pm25_seq, na.color="transparent")
  
  map %>%
  # leaflet() %>% 
    addRasterImage(pm25, colors = pal, opacity = 0.5, group = layerName
                   , options = tileOptions(pane = "theme_pm25")
                   ) %>% 
    addLegend(pal=pal, values = pm25_seq, title = "PM2.5 concentration", position="bottomleft")
  
}

addMap_pop = function(map, countryName){
  pop = getPop(countryName)
  layerName = paste0(countryName, " Population")
  
  if(countryName=="India"){
    #pop$India_pop_count %>% values %>% na.omit() %>% .[which(.>0)] %>% summary()
    brks = c(0, 1, 100, 200, 400, 53004)  
  }else if(countryName=="Tailand"){
    # brks = NA
  }
  
  pal <- colorBin(c("#FFFFFF", "black"), bins = brks, domain=brks, na.color = "transparent")
  
  map %>% 
  # leaflet() %>% addTiles() %>% 
    addRasterImage(pop, colors = pal, opacity = 0.2, 
                   group = layerName
                   , options = tileOptions(pane = "pop")
                   ) %>% 
    addLegend(pal=pal, values = brks, title = "Population", position="bottomleft")
}

clearMap_theme = function(map, countryName){
  theme_layer_names = paste0(countryName, c(" AQ Station", " PM2.5"))
  
  map %>% 
    clearGroup(theme_layer_names)
}


addMap_theme = function(map, themeName, countryName){
  if(themeName=="AQ Station"){
    map %>% 
      clearMap_theme(countryName) %>% 
      clearControls() %>% 
      addMap_AQ_station(countryName)
  }else if(themeName=="PM2.5"){
    map %>% 
      clearMap_theme(countryName) %>% 
      clearControls() %>%
      addMap_pm25(countryName)
  }
}


### rank

# countryName  = "India"
# themeName  = "AQ Station"
# popName = "all"
# brk = "5km"

getRankData = function(countryName, themeName, popName, brk){
  if(themeName=="AQ Station"){
    d = getStationData(countryName)
    fieldName = "station"
    all_field = "station_all"
    main_count = paste0(fieldName, "_", popName, "_",brk)
    main_group_all = paste0(fieldName, "_", popName, "_all")
  }else if(themeName =="PM2.5"){
    
  }
  
  
    d %>% rename(all_field=!!all_field, main_count=!!main_count, main_group_all = !!main_group_all) %>% 
      dplyr::select(name, ID_2, all_field, main_count, main_group_all ) %>% 
    transmute(name, ID_2, main_count = round(main_count, 2), main_all_perc = round((main_count/all_field)*100, 2), main_group_perc = round((main_count/main_group_all)*100, 2))
  
}

# draw rank plot
# number = "main_all_perc"
# rankData = getRankData(countryName = "India", themeName="AQ Station", popName = "pregs", brk="10km")
drawRankChart = function(rankData, number = c("main_count", "main_all_perc", "main_group_perc")){
  data = rankData %>% 
    rename(number = !!number) %>% 
    dplyr::select(name, number) %>% 
    arrange(desc(number)) %>% head(20)
  
  # print(data)
  
  if(number=="main_count"){
    unit = "number of people"
  }else{
    unit = "percentage"
  }
  
  plot_ly(data) %>% 
    plotly::add_bars(y = ~name, x=~number) %>% 
    layout(yaxis = list(title = "city name", categoryorder = "array", categoryarray = rev(data$name)),
           xaxis = list(title = unit)
           )
 
}











