setwd("~/Dropbox/DataTalk/codeWork-datatalk/GreenPeace/APU/something")
library(magrittr)
library(dplyr)
library(sf)

COUNTRIES = c("Colombia" = "COL", "India" = "IND", "Indonesia" = "IDN", "Malaysia" = "MYS", "Philippines" = "PHL", "SouthAfrica" = "ZAF", "Thailand" = "THA", "Turkey" = "TUR")


getCountryNameAbbr = function(countryName, tolower=TRUE){
  name = COUNTRIES[countryName] %>% unname
  if(tolower){tolower(name)}else{name}
}

path = "workfile/Countries/"


# i = 1
for(i in 1:length(COUNTRIES)){
  country_full = COUNTRIES[i] %>% names()
  country_abbr = getCountryNameAbbr(country_full, tolower=TRUE)
  message(country_full)
  
  # path
  path_pm25_data = paste0("workfile/Countries/",country_full, "/pm25_data/")
  path_station_data = paste0("workfile/Countries/",country_full, "/station_data/")
  path_border = paste0("workfile/Countries/",country_full, "/border/")
  
  # 讀取 LV1 資料
  bound = readRDS(paste0(path_border, "border_LV2.rds")) %>% st_drop_geometry() %>% as_tibble()
  
  
  ########## station_data 處理 ##########
  station_data = read.csv(paste0(path_station_data, country_full, "_station_data_miao.csv")) %>% as_tibble()
  names(station_data)[1] <- "ID_2"
  names(station_data)[2] <- "NAME_2"
  
  station_data_L2 = left_join(bound, station_data, by="ID_2") %>% #有些行政區pm25_data算出來為NA，改為0
    replace(is.na(.), 0) %>% 
    dplyr::select(-NAME_2.x) %>% rename(NAME_2 = NAME_2.y) %>% ungroup
  
  station_data_L1 = station_data_L2 %>% dplyr::select(-ID_2, -NAME_2) %>% group_by(ID_1, NAME_1) %>% 
    summarise_all(.funs = sum) %>% ungroup
  
  
  # 存檔
  saveRDS(station_data_L2, paste0(path_station_data, "station_data_L2.rds"))
  saveRDS(station_data_L1, paste0(path_station_data, "station_data_L1.rds"))
  
  
  ########## pm25_data 處理 ##########
  pm25_data = read.csv(paste0(path_pm25_data, country_abbr, "_pm25_data.csv")) %>% as_tibble()
  names(pm25_data)[1] <- "ID_2"
  
  pm25_data_L2 = left_join(bound, pm25_data, by="ID_2") %>% #有些行政區pm25_data算出來為NA，改為0
    replace(is.na(.), 0) %>% ungroup
    
  pm25_data_L1 = pm25_data_L2 %>% dplyr::select(-ID_2, -NAME_2) %>% group_by(ID_1, NAME_1) %>% 
    summarise_all(.funs = sum) %>% ungroup
   
  # 存檔
  saveRDS(pm25_data_L2, paste0(path_pm25_data, "pm25_data_L2.rds"))
  saveRDS(pm25_data_L1, paste0(path_pm25_data, "pm25_data_L1.rds"))

    
}
