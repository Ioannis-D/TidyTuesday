library(tidyverse)

# reading the data
tuesdata <- tidytuesdayR::tt_load('2023-07-04')

historical_markers <- tuesdata$`historical_markers`
no_markers <- tuesdata$`no_markers`

rm(tuesdata)

# I will make a map with the most "important" markers. I will find the oldest, the newest, the ones that are at the extreme points of the Cardinal direction and the state with the most markers. 
# I will only search for existing markers that neither have been confirmed or reported missing and for plotting reason I will exclude Alaska, Puerto Rico and Hawaii. 

# ---------------DATA MANIPULATION----------------------------------------------
oldest_marker_existing <- historical_markers %>% 
  filter(is.na(missing), !state_or_prov %in% c('Puerto Rico', 'Hawaii', 'Alaska')) %>% 
  arrange(year_erected) %>% 
  head(1, year_erected)

newest_marker_existing <- historical_markers %>% 
  filter(is.na(missing), !state_or_prov %in% c('Puerto Rico', 'Hawaii', 'Alaska')) %>% 
  arrange(desc(year_erected), desc(marker_id)) %>% 
  head(1)


north_south_marker_existing <- historical_markers %>% 
  filter(is.na(missing), !state_or_prov %in% c('Puerto Rico', 'Hawaii', 'Alaska')) %>% 
  arrange(latitude_minus_s)

south_marker_existing <- north_south_marker_existing[1, ]
north_marker_existing <- north_south_marker_existing[nrow(northest_southest_marker_existing), ]

rm(north_south_marker_existing)

west_east_marker_existing <- historical_markers %>% 
  filter(is.na(missing), !state_or_prov %in% c('Puerto Rico', 'Hawaii', 'Alaska')) %>% 
  arrange(longitude_minus_w)

west_marker_existing <- west_east_marker_existing[1, ]
east_marker_existing <- west_east_marker_existing[nrow(west_east_marker_existing), ]

rm(west_east_marker_existing)

state_most_markers <- historical_markers %>% 
  filter(is.na(missing), !state_or_prov %in% c('Puerto Rico', 'Hawaii', 'Alaska')) %>% 
  group_by(state_or_prov) %>% 
  summarise(state_count = n()) %>% 
  top_n(1, state_count) %>% 
  inner_join(historical_markers, by = 'state_or_prov')

state_most_missing_markers <- historical_markers %>% 
  filter(!is.na(missing), !state_or_prov %in% c('Puerto Rico', 'Hawaii', 'Alaska')) %>% 
  group_by(state_or_prov) %>% 
  summarise(state_count = n()) %>% 
  top_n(1, state_count) %>% 
  inner_join(historical_markers, by = 'state_or_prov')

# -------------------PLOT-------------------------------------------------------
library(maps)
library(ggimage)
library(showtext)

# Loading the font
font_add_google("Smythe")
showtext_auto()

# Inserting the map of USA
map_usa <- map_data('state')

# Plotting
ggplot() +
  geom_polygon(data = map_usa, aes(x = long, y = lat, group=group), fill='#D1D0CE', color='gray', linewidth=0.3) + 
  geom_polygon(data = map_usa[! map_usa$region %in% c('texas', 'north dakota', 'washington', 'florida', 'maine', 'north carolina', 'virginia'), ], aes(x = long, y = lat, group = group), fill = 'white', color ='gray', linewidth = 0.3) +
  
  # The state's markers position for the state with most existing and the state with most missing
  # Most existing
  geom_point(data = state_most_markers, aes(x = longitude_minus_w, y = latitude_minus_s), color = 'blue', size = 0.1, alpha = 0.1) + 
  geom_label(data = state_most_markers[150, ],
            aes(x = longitude_minus_w - 10, y = latitude_minus_s - 3.5, label = paste("Texas is the state with the most existing markers. \n", 
                                                                                      state_most_markers[1, "state_count"], "in total")),
            size = 3.5, 
            label.padding = unit(0.2, 'lines')) +
  
  
  # Most missing
  geom_point(data = state_most_missing_markers, aes(x = longitude_minus_w, y = latitude_minus_s), color = 'red', shape = 7, size = 0.1, alpha = 0.1) +
  geom_label(data = state_most_missing_markers[1, ],
            aes(x = longitude_minus_w + 4, y = latitude_minus_s + 2, label = paste(state_most_missing_markers[1, "state_or_prov"], "is the state with the most missing markers. \n", 
                                                                                      state_most_missing_markers[1, "state_count"], "in total")),
            size = 3.5, 
            label.padding = unit(0.2, 'lines')) +
  
  # The marker at the North
  geom_segment(data = north_marker_existing, aes(x = longitude_minus_w, y = latitude_minus_s, xend = longitude_minus_w - 11, yend = latitude_minus_s - 3), colour = 'black') +
  geom_image(data = north_marker_existing, aes(x = longitude_minus_w - 11, y = latitude_minus_s - 3, image ='North.jpg'), size=0.2) + 
  geom_point(data = north_marker_existing, aes(x = longitude_minus_w, y = latitude_minus_s), color = 'black', size = 1.5) + 
  geom_label(data = north_marker_existing, 
            aes(x = longitude_minus_w - 10, y = latitude_minus_s - 6, 
                label = paste(north_marker_existing[1, "title"], " is situated in ", north_marker_existing[1, "city_or_town"], sep = '')),
            size = 3.5) + 
  
  # The marker at the South
  geom_segment(data = south_marker_existing, aes(x = longitude_minus_w, y = latitude_minus_s, xend = longitude_minus_w + 4, yend = latitude_minus_s + 4)) + 
  geom_image(data = south_marker_existing, aes(x = longitude_minus_w + 4, y = latitude_minus_s + 4, image ='South.jpg'), size=0.2) +
  geom_point(data = south_marker_existing, aes(x = longitude_minus_w, y = latitude_minus_s), color = 'black', size = 1.5) + 
  geom_label(data = south_marker_existing, 
            aes(x = longitude_minus_w - 6, y = latitude_minus_s + 3, 
                label = paste(south_marker_existing[1, "title"], " is situated in ", south_marker_existing[1, "city_or_town"], sep = '')),
            size = 3.5) + 
    
    
    # The marker at the East
  geom_segment(data = east_marker_existing, aes(x = longitude_minus_w, y = latitude_minus_s, xend = longitude_minus_w - 10, yend = latitude_minus_s +3)) + 
  geom_image(data = east_marker_existing, aes(x = longitude_minus_w -10, y = latitude_minus_s + 3, image ='East.jpg'), size=0.2) +
  geom_point(data = east_marker_existing, aes(x = longitude_minus_w, y = latitude_minus_s), color = 'black', size = 1.5) + 
  geom_label(data = east_marker_existing, 
            aes(x = longitude_minus_w - 10, y = latitude_minus_s - 0.5, 
                label = paste(east_marker_existing[1, "title"], "\nis situated in ", east_marker_existing[1, "city_or_town"], sep = '')),
            size = 3.5) + 
  
  
  # The marker at the West
  geom_segment(data = west_marker_existing, aes(x = longitude_minus_w, y = latitude_minus_s, xend = longitude_minus_w, yend = latitude_minus_s - 5)) + 
  geom_image(data = west_marker_existing, aes(x = longitude_minus_w, y = latitude_minus_s - 5, image ='West.jpg'), size=0.2) +
  geom_point(data = west_marker_existing, aes(x = longitude_minus_w, y = latitude_minus_s), color = 'black', size = 1.5) + 
  geom_label(data = west_marker_existing,
            aes(x = longitude_minus_w + 1, y = latitude_minus_s - 8.5, label = "Snow Creek is in Neah Bay"),
            size = 3.5, 
            label.padding = unit(0.2, 'lines')) +
  
  # The oldest 
  geom_segment(data = oldest_marker_existing, aes(x = longitude_minus_w, y = latitude_minus_s, xend = longitude_minus_w - 13, yend = latitude_minus_s + 2)) + 
  geom_image(data = oldest_marker_existing, aes(x = longitude_minus_w - 13, y = latitude_minus_s + 2, image ='Oldest.jpg'), size=0.2) +
  geom_point(data = oldest_marker_existing, aes(x = longitude_minus_w, y = latitude_minus_s)) +
  geom_label(data = oldest_marker_existing,
            aes(x = longitude_minus_w - 13, y = latitude_minus_s + 6, 
                label = paste(oldest_marker_existing[1, "title"], "is the oldest marker existing.", "\nIs located in", oldest_marker_existing[1, "city_or_town"], "\n since", oldest_marker_existing[1, "year_erected"])),
            size = 3.5) +
  
  
 labs(title = 'Historical Markers in the USA') +
  
  theme_bw() + 
  theme(plot.title = element_text(size = 16, hjust = 0.5, family = "Smythe"))
