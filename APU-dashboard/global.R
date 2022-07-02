library(shiny)
library(shinyjs)
library(shinythemes)
library(magrittr)
library(dplyr)
library(leaflet)

cssFile = list.files("www")[grep(".css", list.files("www"))]


main_map = 
  leaflet() %>%
  addProviderTiles(provider = providers$CartoDB.DarkMatterNoLabels) 
