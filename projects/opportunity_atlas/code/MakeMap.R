options(max.print=1000000)
library(ggplot2)
library(dplyr)
library(tmap)
library(tmaptools)
library(sf)
library(leaflet)
library(htmlwidgets)
library(mapview)

#change to user directory
if (Sys.info()[["user"]] == "daniellee") {
  datapath <- "/Users/daniellee/Dropbox/RA_work/data/opportunity_atlas/input"
}
if (Sys.info()[["user"]] == "") {
  datapath <- "/Users/bblockwood/Dropbox/RA_work/data/opportunity_atlas/input"
}

data <- paste(datapath,"/county_outcomes_simple.csv",sep="")
IncData <- read.csv(data, header = T)
shapefile <- paste(datapath,"/UScounties/UScounties.shp",sep="")
usageo <- read_shape(file=shapefile, as.sf = TRUE)

IncData$household_income_mean_percentile_rank <- IncData$kfr_pooled_pooled_p25
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
IncData <- IncData[,c("FIPS", "household_income_mean_percentile_rank")]
head(IncData)
names(IncData) <- c("FIPS", "household_income_mean_percentile_rank")
head(IncData)
IncData$outcome <- as.numeric(as.character((IncData$household_income_mean_percentile_rank)))
head(IncData)
cacopa <- inner_join(usageo, IncData, by = NULL)
head(cacopa)
View(as_data_frame(cacopa))
tmap_mode("view")
usmap <- tm_shape(cacopa) + 
  tm_fill("household_income_mean_percentile_rank", title="Household Income Mean Percentile Rank", palette = "RdBu") +
  tm_borders(alpha=.5)
usmap <- tmap_leaflet(usmap)
usmap <- usmap %>% 
  fitBounds(-124,24,-60,49)
usmap
mapshot(usmap,file="map.pdf")
