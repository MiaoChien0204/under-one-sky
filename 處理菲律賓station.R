setwd("/Users/Miao/Dropbox/DataTalk/codeWork-datatalk/GreenPeace/APU/something/")


library(magrittr)
library(dplyr)
library(tidyr)
library(sf)

# file_url = "https://docs.google.com/spreadsheets/d/1p-2MUFp7wul7aUPiwbq4IoZrdJRagQq5t-Wyzf_T0-c/edit#gid=0"

station = read.csv("phi_office_station.csv") %>% as_tibble()  %>% 
  separate(col = coord, into = c("lat","lon"), sep = ", ") %>% as_tibble() %>% 
  mutate(lat = as.numeric(lat) %>% round(5), lon = as.numeric(lon)%>% round(5)) 

station_sf = st_as_sf(station, coords = c("lon", "lat")) %>% st_set_crs(4326)

write_sf(station_sf, "workfile/Countries/Philippines/station/station.shp")
