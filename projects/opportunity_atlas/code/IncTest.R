options(max.print=1000000)
library(ggplot2)
library(dplyr)
library(tmap)
library(tmaptools)
library(sf)
library(leaflet)
#map of US counties
counties <- map_data("county")
View(as_data_frame(counties))
us_base <- ggplot(data = counties, mapping = aes(x = long, y = lat, group = group)) + 
  coord_fixed(1.3) + 
  geom_polygon(color = "black", fill = "white")
us_base

IncData <- read.csv("https://www.dropbox.com/s/xo4ddqzyherf44n/county_outcomes_simple.csv?dl=1", header=T)
View(as_data_frame(IncData))
shapefile <- "/Users/daniellee/Downloads/USCounties/UScounties.shp"
usageo <- read_shape(file=shapefile, as.sf = TRUE)
View(as_data_frame(usageo))
IncData$outcome <- IncData$kfr_pooled_pooled_p25
IncData$STATE_FIPS <- IncData$state
IncData$STATE_FIPS <- as.numeric(as.character(IncData$STATE_FIPS))
IncData$STATE_FIPS <- sprintf("%02d",IncData$STATE_FIPS)
IncData$CNTY_FIPS <- IncData$county
IncData$CNTY_FIPS <- as.numeric(as.character(IncData$CNTY_FIPS))
head(IncData$CNTY_FIPS)
IncData$CNTY_FIPS <- sprintf("%03d",IncData$CNTY_FIPS)
head(IncData$CNTY_FIPS)
IncData$FIPS <- paste(IncData$STATE_FIPS,IncData$CNTY_FIPS,sep="")
head(IncData$FIPS)
IncData <- IncData[,c("FIPS", "outcome")]
View(as_data_frame(IncData))
head(IncData)
names(IncData) <- c("FIPS", "outcome")
head(IncData)
IncData$outcome <- as.numeric(as.character((IncData$outcome)))
head(IncData)
cacopa <- inner_join(usageo, IncData, by = NULL)
head(cacopa)
View(as_data_frame(cacopa))

qtm(cacopa, "outcome")

