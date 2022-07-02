library(shiny)
library(shinyjs)
library(shinythemes)
library(magrittr)
library(dplyr)
library(leaflet)
library(rgdal)

cssFile = list.files("www")[grep(".css", list.files("www"))]
source("funcs.R")

# main_map = 
#   leaflet() %>%
#   addProviderTiles(provider = providers$CartoDB.DarkMatterNoLabels) 


# map_india = readRDS("data/map_india.rds")
