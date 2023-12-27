library(tidyverse)
library(showtext)
library(ggthemes)
library(gganimate)

# ---- READ THE DATA ----
life_expectancy <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-12-05/life_expectancy.csv')
life_expectancy_different_ages <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-12-05/life_expectancy_different_ages.csv')
life_expectancy_female_male <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-12-05/life_expectancy_female_male.csv')

# ---- FONT ----
font_add_google("Kaushan Script", "Kaushan")
showtext_auto()

# ---- DATA MANIPULATION ----
# Retrieve the sf data of the countries
world <- rnaturalearth::ne_countries(returnclass = 'sf')

# Change the code of South Sudan to match the one of World dataset
life_expectancy[life_expectancy$Entity=='South Sudan', 2] <- 'SDS'

# Merge the two datasets so the to_plot dataset will have all the columns of the life_expectancy and the geometry of the coutnries.
to_plot <- merge(life_expectancy, world[, 11], by.x = 'Code', by.y= 'adm0_a3')
to_plot <- to_plot %>% 
  filter(Year > 1950) %>% 
  group_by(Year) %>% 
  mutate(avg = median(LifeExpectancy))

# ---- PLOT ----
map <- ggplot() +
  geom_sf(data = to_plot$geometry, 
          aes(fill = to_plot$LifeExpectancy)) +
  
  scale_fill_gradient(low = "#F3EEEA", high = "#776B5D", na.value = "grey") +
  
  labs(title = 'Life Expectancy',
       caption = "Year: {frame_time}") +
  
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "#FFFFF0", colour = NA),
    plot.margin = unit(c(0,0,0,0), "cm"),
    
    plot.title = element_text(family = "Kaushan", 
                              hjust = .5, vjust = .5, 
                              size = 23),
    plot.caption = element_text(family = "Kaushan",
                                hjust = .5, vjust = .5,
                                size = 15),
    
    panel.grid = element_blank(),
    panel.background = element_rect(fill = "#FFFFF0", colour = NA),
    
    legend.position = "top",
    legend.title = element_blank(),
    legend.key.width = unit(10, "line"),
    legend.key.height = unit(0.5, "line"),
    
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank()
  ) +
  
  # Add the animation
  transition_time(time = to_plot$Year)

animate(map, 
        nframes = (max(to_plot$Year) - min(to_plot$Year) + 1), fps = 2,
        height = 1200, width = 1500)

# Save as a .gif
anim_save("Week_49.gif")