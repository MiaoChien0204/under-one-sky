suppressPackageStartupMessages({
  library(shiny)
  # library(shinyjs)
  library(shinythemes)
  library(shinycssloaders)
  library(magrittr)
  library(dplyr)
  library(leaflet)
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

main_map =
  leaflet() %>%
  addProviderTiles(providers$Stamen.TonerLite, group = "Toner") %>%
  addProviderTiles(providers$CartoDB.Positron, group = "Carto") %>%
  addProviderTiles(provider = providers$Esri.WorldPhysical, group = "World Physical") %>% 
  setView(lng=78, lat=22, zoom=5.1)

# countryName = "India"
# map_india = readRDS("data/map_india.rds")
