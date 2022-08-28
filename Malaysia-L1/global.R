if(interactive()){
  setwd("~/Dropbox/DataTalk/codeWork-datatalk/GreenPeace/APU/Malaysia-L1")
}

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

DOMAIN = "https://apu-rxwnwfojzq-de.a.run.app/"
COUNTRY = "Malaysia"
BOUND_LV = 1
ID = paste0("ID_",BOUND_LV)
NAME = paste0("NAME_",BOUND_LV)

cssFile = list.files("www")[grep(".css", list.files("www"))]
jsFile = paste0("www/", list.files("www")[grep(".js", list.files("www"))])
source("funcs.R")



COUNTRY_MAP_VAR = list(
  "Colombia" = list(
    view = list(lng = -72, lat = 4, zoom = 6),
    bound = list(lng1=-83, lat1=-5, lng2=-61, lat2=13)
  ),
  "India" = list(
    view = list(lng = 78, lat = 22, zoom = 5.1),
    bound = list(lng1=102, lat1=40, lng2=53, lat2=1)
  ),
  "Indonesia" = list(
    view = list(lng = 117.8, lat = -2.3, zoom = 5),
    bound = list(lng1=93, lat1=-14, lng2=142, lat2=9)
  ),
  "Malaysia" = list(
    view = list(lng = 110, lat = 4, zoom = 6),
    bound = list(lng1=97, lat1=10, lng2=122, lat2=-3)
  ),
  "Philippines" = list(
    view = list(lng = 122, lat = 11, zoom = 6),
    bound = list(lng1=116, lat1=3, lng2=129, lat2=20)
  ),
  "SouthAfrica" = list(
    view = list(lng = 24, lat = -29, zoom = 6),
    bound = list(lng1=11.6, lat1=-37, lng2=36, lat2=-20)
  ),
  "Thailand" = list(
    view = list(lng = 101, lat = 14, zoom = 5.5),
    bound = list(lng1=91, lat1=4, lng2=110, lat2=21)
  ),
  "Turkey" = list(
    view = list(lng = 35, lat = 38, zoom = 6),
    bound = list(lng1=24.5, lat1=33, lng2=47, lat2=43)
  )
)

BASE_GROUPS = c("Positron","WorldImagery")

LAYER_BOUNDARY_NAME = "Admin Boundary"
LAYER_THEME_NAME = ""
LAYER_POP_NAME = "Selected Group Pop"

if(COUNTRY=="India"){
  main_map = leaflet(options = leafletOptions(minZoom = COUNTRY_MAP_VAR[[COUNTRY]]$view$zoom, maxZoom = 7))   
}else{
  main_map = leaflet(options = leafletOptions(minZoom = COUNTRY_MAP_VAR[[COUNTRY]]$view$zoom))   
}


main_map %<>%
  addScaleBar(position = "topleft") %>% 
  addProviderTiles(providers$CartoDB.PositronNoLabels, group = BASE_GROUPS[1]) %>%
  addProviderTiles(providers$Esri.WorldImagery, group = BASE_GROUPS[2]) %>%
  setView(lng=COUNTRY_MAP_VAR[[COUNTRY]]$view$lng, lat=COUNTRY_MAP_VAR[[COUNTRY]]$view$lat, zoom=COUNTRY_MAP_VAR[[COUNTRY]]$view$zoom) %>%
  setMaxBounds(lng1=COUNTRY_MAP_VAR[[COUNTRY]]$bound$lng1, lat1=COUNTRY_MAP_VAR[[COUNTRY]]$bound$lat1, lng2=COUNTRY_MAP_VAR[[COUNTRY]]$bound$lng2, lat2=COUNTRY_MAP_VAR[[COUNTRY]]$bound$lat2)


COLOR_BRK_data = c("#9CD84E", "#FAA238", "#DF3233", "#7D3C98")
COLOR_BRK_map = c("#9CD84E",  #green
                  "#fb9946", "#fa8623", "#f47405", "#d16304", #orange
                  "#e8585b", "#db1e21", "#bc191c", "#9d1517", "#5e0c0e",   #red
                  "#7D3C98" #purple
)

COLOR_BRK_map_india = c(COLOR_BRK_map, 
                        "#9e02b8", "#590168", "#300038"
)


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



