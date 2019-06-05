library(ggplot2)
library(dplyr)
library(tmap)
library(tmaptools)
library(sf)
library(leaflet)
tpdata <- read.csv("/Users/daniellee/Downloads/county_outcomes_simple.csv", header = T)
tpdata <- tpdata[,c("czname", "kfr_pooled_pooled_p25")]
print(tpdata)
shapefile <- st_read("/Users/daniellee/Downloads/cb_2014_us_county_5m/cb_2014_us_county_5m.shp")
usgeo$NAME <- as.character(usgeo$NAME)
usgeo <- usgeo[order(usgeo$NAME),]
tpdata <- tpdata[order(tpdata$czname),]
usmap <- merge(usgeo, tpdata, by.x = "NAME", by.y = "czname")
qtm(usmap, "kfr_pooled_pooled_p25")
