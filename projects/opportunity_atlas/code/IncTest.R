library(ggplot2)
library(ggmap)
library(maps)
library(mapdata)
library(dplyr)

#map of US counties
counties <- map_data("county")
head(counties)
us_base <- ggplot(data = counties, mapping = aes(x = long, y = lat, group = group)) + 
  coord_fixed(1.3) + 
  geom_polygon(color = "black", fill = "white")
us_base

#map of kfr_pooled_pooled_p25 (not sure what that is, but it's in the Opportunity Atlas data)
IncData <- read.csv("https://www.dropbox.com/s/xo4ddqzyherf44n/county_outcomes_simple.csv?dl=1", header=T)
IncData$outcome <- IncData$kfr_pooled_pooled_p25
IncData$outcome <- IncData$outcome
IncData$subregion <- tolower(IncData$subregion)
IncData <- IncData[,c("subregion", "outcome")]
head(IncData)
names(IncData) <- c("subregion", "outcome")
head(IncData)
IncData$outcome <- as.numeric(as.character((IncData$outcome)))
head(IncData)
cacopa <- inner_join(counties, IncData, by = "subregion")
head(cacopa)
ditch_the_axes <- theme(
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank()
)

elbow_room1 <- us_base + 
  geom_polygon(data = cacopa, aes(fill = outcome), color = "black") +
  geom_polygon(color = "white", fill = NA) +
  theme_bw() +
  ditch_the_axes

elbow_room1
