# TidyTuesday | Week 41, Year 2023 | Creator: Ioannis Doganos (https://github.com/Ioannis-D)

library(tidyverse)
library(showtext)
library(osmdata)
library(ggfx)
library(ggtext)

# Read the data
tuesdata <- tidytuesdayR::tt_load(2023, week = 41)
haunted_places <- tuesdata$haunted_places
rm(tuesdata)

# Reading the font 'shlop' downloaded from 1001fonts.com
font_add(family = "shlop",
                   regular = "~/.fonts/R/shlop/shlop rg.otf")
#Reading the font 'dark_black' downloaded from datafont.com
font_add(family = "dark_black",
                   regular = "~/.fonts/R/dark-black/Dark & Black D.otf")

#Reading the font 'unfinished scream' downloaded from datafont.com
font_add(family = "unfinished_scream",
         regular = "~/.fonts/R/unfinished_scream/OTF/UnfinishedScreamRegular.otf")

showtext_auto()

# ----DATA MANIPULATION----
# Extract only the description of the Bonaventure Cementery
bonaventure_description <- haunted_places %>% 
  filter(grepl('Bonaventure Cemetery', location, ignore.case = TRUE)) %>% 
  select(description)

bonaventure_description <- as.character(bonaventure_description)
rm(haunted_places)

# ----OPENSTREETMAP DATA----
# Obtain the data from OpenStreetMap with the use of 'osmdata' package

# The BoundingBox Coordinates
bb_coordinates <- c(-81.07333,32.02369,-81.0296,32.05508)
cemetery_bb_coordinates <- c(-81.05046,32.04062,-81.04277,32.04757)

# --Bonaventure Cemetery--
bonaventure_streets <- opq(bbox = cemetery_bb_coordinates) %>% 
  add_osm_feature(
    key = 'highway',
    value = c(
      'track',
      'footway'
      )
  ) %>% 
  osmdata_sf()


# The code below gives exactly the same result as the above code and is written differently only for practising another possible way to retrieve the information.
bb <- getbb('Savannah')

bonaventure_polygon <- bb %>%
  opq() %>% 
  add_osm_feature(
    key = 'landuse',
    value = 'cemetery'
  ) %>% 
  add_osm_feature(
    key = 'name',
    value = 'Bonaventure Cemetery'
  ) %>% 
  osmdata_sf()

# --The data around the cemetery--
water <- opq(bbox = bb_coordinates) %>% 
  add_osm_feature(
    key = 'natural',
    value = 'water'
  ) %>% 
  osmdata_sf()

streets <- opq(bbox = bb_coordinates) %>% 
  add_osm_feature(
    key = 'highway',
  ) %>% 
  osmdata_sf()

primary_highways <- opq(bbox = bb_coordinates) %>% 
  add_osm_feature(
    key = 'highway',
    value = c('motorway', 'primary', 'secondary')
  ) %>% 
  osmdata_sf()

grass <- opq(bbox = bb_coordinates) %>% 
  add_osm_features(
    features = c(
      "\"landuse\"=\"cemetery\"",
      "\"natural\"=\"wetland\"",
      "\"natural\"=\"wood\""
    )
  ) %>% 
  osmdata_sf()

residential_commercial <- opq(bbox = bb_coordinates) %>% 
  add_osm_feature(
    key = "landuse",
    value = c("residential", "commercial")
  ) %>% 
  osmdata_sf()

# ----PLOT----
# The colors
background_color <- 'black'
roads_color <- '#389092'
main_road_color <- '#5FCFC3'
cemetery_road_color <- '#5FCFC3'
cemetery_grass_color <- '#1b4b35'
grass_color <- '#1c352d'
water_color <- '#002147'
land_color <- 'grey20'
title_color <- '#5C58A4'
city_color <- '#FDD001'
text_color <- ''



# The transparencies
tr1 <- 0.3
tr2 <- 1


# The surroundings of the cemetery
gsurround <- ggplot()+
  # The concrete land
  geom_sf(data = residential_commercial$osm_polygons,
          color = land_color,
          fill = land_color,
          linewidth = 0,
          alpha = tr1) +
  # The natural land
  geom_sf(data = grass$osm_polygons,
          color = grass_color,
          fill = grass_color,
          linewidth = 0,
          alpha = tr1) +
  # The wetland is as multipolygons
  geom_sf(data = grass$osm_multipolygons,
          color = grass_color,
          linewidth = 0,
          fill = grass_color,
          alpha = tr1) +
  # The river
  geom_sf(data = water$osm_polygons,
         color = water_color,
         linewidth = 0,
         fill = water_color, 
         alpha = tr1) +
  # All the roads
  geom_sf(data = streets$osm_lines,
          color = roads_color,
          alpha = tr2) +
  # The main roads
  geom_sf(data = primary_highways$osm_lines,
          color = main_road_color,
          fill = main_road_color,
          linewidth = 2,
          alpha = tr2) +
  # The city name
  geom_richtext(aes(x = -81.0604, y = 32.0487,
                    label = "**Savannah**<br>**Georgia, US**"),
                family = 'unfinished_scream',
                size = 4,
                color = city_color,
                alpha = 0.6,
                fill = NA,
                angle = -11
                )

# Add the Bonaventure Cemetery details
gcem <- gsurround +
  # The cemetery's polugon (with glow)
  with_outer_glow(
    geom_sf(data = bonaventure_polygon$osm_polygons,
            color = 'green',
            fill = cemetery_grass_color,
            alpha = 0.7
    ),
    colour = 'green',
    sigma = 20,
    expand = 3
  ) +
  # The roads of the cemetery
  geom_sf(data = bonaventure_streets$osm_lines,
          color = cemetery_road_color,
          linewidth = 0.5,
          alpha = tr1)

# Add the statue's coordinates and a glowing dot
statue_coordinates <- data.frame(
  'long' = -81.04484304831558,
  'lat' = 32.04295925638593
)

p1 <- gcem +
  with_outer_glow(
    geom_point(data = statue_coordinates,
               aes(x=long, y=lat),
               color = 'red',
               size = 0.5,
               alpha = tr1),
    colour = 'white',
    sigma = 5, 
    expand = 7)

# ADD THE IMAGE
img <- jpeg::readJPEG('./Images/Little_Gracie_Watson.jpeg', native = FALSE)
g <- grid::rasterGrob(img, 
                      interpolate=TRUE,
                      hjust = 0.5, 
                      vjust = 0.5)
p2 <- p1 +
  # Add the line
  geom_segment(data = statue_coordinates,
               x = statue_coordinates$long, xend = -81.035,
               y = statue_coordinates$lat, yend = 32.027,
               linewidth = 0.5,
               color = 'grey80',
               alpha = 0.5) +
  # Add the image
  annotation_custom(g, 
                    xmin = -81.04, xmax = -81.03,
                    ymin = 32.02369, ymax = 32.03)

# Add the theme and other elements
plot <- p2 +
  scale_x_continuous(limits = c(-81.07333, -81.0296))+
  scale_y_continuous(limits = c(32.02369, 32.05508)) +
  
  theme(
    plot.background = element_rect(fill = background_color, colour = background_color),
    panel.background = element_rect(fill = background_color, colour = background_color),
    
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.line = element_blank(),
    
    panel.grid = element_blank()
  )

plot <- cowplot::ggdraw(plot) +
  ggtitle('Bonaventure Cemetery') +
  theme(
    plot.background = element_rect(fill = background_color, colour = background_color),
    panel.background = element_rect(fill = background_color, colour = background_color),
    
    plot.title = element_text(family = 'shlop', 
                              size = 60,
                              hjust = 0.5, 
                              margin = margin(t = 1,
                                              r = 0,
                                              b = 1,
                                              l = 0),
                              
                              colour = title_color)
    
  )
plot
