install.packages("ggplot2")
install.packages("dplyr")
install.packages("tmap")
install.packages("tmaptools")
install.packages("sf")
install.packages("leaflet")
library(ggplot2)
library(dplyr)
library(tmap)
library(tmaptools)
library(sf)
library(leaflet)
tpdata <- read.csv("https://www.dropbox.com/s/xo4ddqzyherf44n/county_outcomes_simple.csv?dl=1", header = T) #imports Opportunity Atlas data from Dropbox
tpdata <- tpdata[,c("czname", "kfr_pooled_pooled_p25")] #creates a table with only county names and kfr_pooled_pooled_p25
print(tpdata)
shapefile <- st_read("https://www.dropbox.com/s/gyvsoi2tihqc1kj/cb_2014_us_county_5m.shp?dl=1") #imports us county shapefile from Dropbox
usgeo$NAME <- as.character(usgeo$NAME)
usgeo <- usgeo[order(usgeo$NAME),]
tpdata <- tpdata[order(tpdata$czname),]
usmap <- merge(usgeo, tpdata, by.x = "NAME", by.y = "czname")
qtm(usmap, "kfr_pooled_pooled_p25")
