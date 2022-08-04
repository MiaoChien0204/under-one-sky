suppressPackageStartupMessages({
  library(shiny)
  # library(shinyjs)
  library(shinythemes)
  library(shinycssloaders)
  library(magrittr)
  library(dplyr)
  library(leaflet)
  # library(leaflet.extras)
  library(rgdal)
  library(shinyWidgets)
  library(sf)
  library(raster)
  library(plotly)
  library(DT)
  # remotes::install_github("rstudio/leaflet", ref="joe/feature/raster-options")
  # https://github.com/rstudio/leaflet/pull/692
})




cssFile = list.files("www")[grep(".css", list.files("www"))]
source("funcs.R")

BASE_GROUPS = c("Voyager","WorldGray", "Positron", "StamenTerrainBackground",  "StamenTerrain", "WorldImagery")

main_map =
  leaflet() %>%
  addProviderTiles(providers$CartoDB.VoyagerNoLabels, group = BASE_GROUPS[1]) %>%
  addProviderTiles(providers$Esri.WorldGrayCanvas, group = BASE_GROUPS[2]) %>%
  addProviderTiles(providers$CartoDB.PositronNoLabels, group = BASE_GROUPS[3]) %>%
  addProviderTiles(providers$Stamen.TerrainBackground, group = BASE_GROUPS[4]) %>%
  addProviderTiles(providers$Stamen.Terrain, group = BASE_GROUPS[5]) %>%
  addProviderTiles(providers$Esri.WorldImagery, group = BASE_GROUPS[6]) %>%
  setView(lng=78, lat=22, zoom=5.1)

main_map %<>%
  addMapPane("pop", zIndex=410) %>%
  addLayersControl(
    baseGroups = BASE_GROUPS,
    options = layersControlOptions(collapsed = FALSE)
  )

WMS_URL = "http://localhost:8080/geoserver/apu/wms"
WMS_LEGEND_URL = "http://localhost:8080/geoserver/wms?REQUEST=GetLegendGraphic&VERSION=1.0.0&FORMAT=image/png&WIDTH=20&HEIGHT=20
    &legend_options=forceLabels:on;forceTitles:on&LAYER=apu:"

COLOR_BRK = c("#9CD84E", "#FAA238", "#DF3233", "#7D3C98")

theme_break = tibble(
  "AQ Station" = c("group_a_prec" ="5 km↓",  
                  "group_ab_prec" = "5-10 km", 
                  "group_bc_prec" = "10-25 km", 
                  "group_c_prec" = "25 km↑"),
  "PM2.5" = c("group_a_prec" ="5 μg/m3↓",  
             "group_ab_prec" = "5-25 μg/m3", 
             "group_bc_prec" = "25-50 μg/m3", 
             "group_c_prec" = "50 μg/m3↑")
  
)

THEME_BREAK_TABLE = 
  tibble(
       theme = "AQ Station", 
       var = c("group_all", 
               "group_A", "group_B", "group_C",
               "group_A_prec", "group_B_prec", "group_C_prec",
               "group_a_num",  "group_ab_num", "group_bc_num", "group_c_num",
               "group_a_prec", "group_ab_prec", "group_bc_prec", "group_c_prec"),
       varName = c("group pop #",
                 "# <5 km", "# <10 km", "# <25 km",
                 "% <5 km", "% <10 km", "% <25 km", 
                 "# <5 km", "# 5-10 km", "# 10-25 km", "# >25 km",  
                 "% <5 km", "% 5-10 km", "% 10-25 km", "% >25 km"  
                 )
       ) %>% 
  bind_rows(
  tibble(
      theme = "PM2.5",
      var = c("group_all", 
              "group_A", "group_B", "group_C",
              "group_A_prec", "group_B_prec", "group_C_prec",
              "group_a_num",  "group_ab_num", "group_bc_num", "group_c_num",
              "group_a_prec", "group_ab_prec", "group_bc_prec", "group_c_prec"),
      varName = c("group pop #",
                "# >5 μg/m3", "# >25 μg/m3", "# >50 μg/m3",
                "% >5 μg/m3", "% >25 μg/m3", "% >50 μg/m3", 
                "# <5 μg/m3", "# 5-25 μg/m3", "# 25-50 μg/m3", "# >50 μg/m3↑",  
                "% <5 μg/m3", "% 5-25 μg/m3", "% 25-50 μg/m3", "% >50 μg/m3↑"  
      )
    )
  )



