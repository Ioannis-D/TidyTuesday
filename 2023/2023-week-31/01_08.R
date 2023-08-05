library(tidyverse)
library(showtext)
library(sf)
library(ggpubr)
library(geofacet)

# Reading the data
tuesdata <- tidytuesdayR::tt_load(2023, week = 31)

states <- tuesdata$states
state_name_etymology <- tuesdata$state_name_etymology

rm(tuesdata)

# Loading the fonts
font_add_google('Alfa Slab One', family = 'Alfa')
font_add_google('Bungee Outline', family = 'Bungee')
showtext_auto()

# ---- DATA MANIPULATION ----
# Creating the percentage of land and water
states <- states %>% 
  mutate(
    percentage_water = round((water_area_km2 / total_area_km2), 2),
    percentage_land = 1 - percentage_water
  )

# ---- PLOT ----
# Plotting using the real map of USA
# Creating the map of USA
map_usa <- map_data('state')

map_usa <- map_usa %>% 
  mutate(
    region = stringr::str_to_title(region)
  ) %>% 
  left_join(states, by = c('region' = 'state'))

# Selecting only the columns to be used
map_usa <- map_usa %>% 
  select(long, lat, group, region, postal_abbreviation, percentage_water, percentage_land)

# Making the plot
water_percentage <- ggplot(data = map_usa, 
       aes(
         x = long,
         y = lat,
         group = group,
         fill = percentage_water)
       ) +
  geom_polygon(
    color = 'grey',
    linewidth = 0.05
    ) +
  coord_map(projection = 'albers', lat0 = 45, lat1 = 55) + 
  
  scale_fill_gradientn(colors = c('#d9ebf6', '#849baa', '#8395c1', '#435274'), labels = scales::label_percent()) +
  
  ggtitle('WATER') + 
  
  theme_void() +
  theme(
    legend.position = 'bottom',
    legend.key.size = unit(0.5, 'cm'),
    legend.key.height = unit(0.1, 'cm'),
    legend.key.width = unit(1, 'cm'),
    legend.title = element_blank(),
    
    plot.title = element_text(
      family = 'Alfa',
      size = 100,
      colour = '#0b4467', 
      hjust = 0.5)
  )
water_percentage  

land_percentage <- ggplot(data = map_usa, 
       aes(
         x = long,
         y = lat,
         group = group,
         fill = percentage_land)
       ) +
  geom_polygon(
    color = 'grey',
    linewidth = 0.05
    ) +
  coord_map(projection = 'albers', lat0 = 45, lat1 = 55) + 
  
  scale_fill_gradientn(colors = c('#cda678', '#a0764b', '#B87333', '#5f3e24'), labels = scales::label_percent()) +
  
  labs(caption = 'LAND') +
  
  theme_void() +
  theme(
    legend.position = 'top',
    legend.key.size = unit(0.5, 'cm'),
    legend.key.height = unit(0.1, 'cm'),
    legend.key.width = unit(1, 'cm'),
    legend.title = element_blank(),
    
    plot.caption = element_text(
      family = 'Alfa',
      size = 100,
      colour = '#3d2b1f',
      hjust = 0.5,
    )
  )
land_percentage

# The 'VS' text
vs_text <- ggplot() +
  annotate("text",
           x = 1,
           y = 1,
           size = 20,
           family = 'Bungee',
           label = 'VS') +
  theme_void()
vs_text

final_plot <- ggarrange(water_percentage,
          vs_text,
          land_percentage,
          ncol = 3,
          nrow = 1,
          widths = c(5, 1, 5),
          heights = c(5, 1, 5))
final_plot
