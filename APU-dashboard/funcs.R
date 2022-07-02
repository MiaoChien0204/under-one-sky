
nycounties <- rgdal::readOGR("https://rstudio.github.io/leaflet/json/nycounties.geojson") 

getBoundary = function(){
  # boundary = readOGR("data/border.geojson")
  # saveRDS(boundary, "data/border.rds")
  readRDS("data/border.rds")
}



