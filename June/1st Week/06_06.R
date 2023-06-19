library(tidyverse)

owid_energy <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-06-06/owid-energy.csv')

# I will make a GIF showning the percentage of green energy of the electric production in Europe  

# In order to do it, I have to filter the data and choose only European countries. 
# I will use the same technique as in the 22nd week's TidyTuesday, extracting the information directly from Wikipedia.

library(rvest)
url <- "https://simple.wikipedia.org/wiki/List_of_European_countries"
page <- read_html(url)

# Some countries include references wich means that their name is followed by "[]" with the number of reference. I am cleansing the names of the countries and I only extract the countries' names.
eu_countries <- page %>% 
  html_nodes(css = "table") %>% 
  .[[1]] %>% 
  html_table(header = TRUE, trim = TRUE) %>% 
  # Some countries include references wich means that their name is followed by "[]" with the number of reference. I am cleansing the names of the countries and I only extract the countries' names.
  mutate(country = str_extract(`Name of country orterritory, with flag`, "(?:(?!(\\[)).)*")) %>% 
  select(country)

# I want to include the two-letter code for each country in order to be easier to transform it to a geospatial project with the map of eurostat. 
url <- "https://www.iban.com/country-codes"
page <- read_html(url)

country_codes <- page %>% 
  html_table(header = TRUE, trim = TRUE) %>% 
  .[[1]]

# Creating the necessary dataset. It includes all years, the European countries and the share of green energies.
owid_energy <- owid_energy %>% 
  inner_join(eu_countries, by = "country") %>% 
  left_join(country_codes, by = c("iso_code" = "Alpha-3 code")) %>% 
  group_by(country, year) %>% 
  mutate(green_energy = sum(c(other_renewables_share_energy, renewables_share_energy), na.rm = TRUE)) %>% 
  select(country, CNTR_CODE =`Alpha-2 code`, year, green_energy)
  
# GRAPHS
library(sf)
library(eurostat)
library(ggthemes)
library(gganimate)

european_map <- get_eurostat_geospatial(resolution = 10, nuts_level = 0, year = "2021", output_class = "sf", crs = "4326")

renewable_energy_europe <- owid_energy %>% 
  inner_join(european_map, by = "CNTR_CODE") %>% 
  st_as_sf() 

# More DATA CLEANSING
# We notice that the final sf file does not contain all the countries de to difference country codes used from eurostat and not the ISO 3166   

# Print the countries that are not included
wrong_codes <- as.data.frame(setdiff(eu_countries$country, renewable_energy_europe$country))
wrong_codes
# We notice that Belarus, Bosina and Herzegovina, Greece, Kosovo, Moldova, Ukraine and United Kindom are some of the countires that have to be included. I exclude smaller countries like Monaco, San Marino and Andorra.
# I make a dataframe with the codes of the above countries as they appear in the EU system. 
eu_country_codes <- data.frame(country = c("Belarus", "Bosnia and Herzegovina", "Greece", "Kosovo", "Moldova", "Ukraine", "United Kingdom"),
                               id = c("BY", "BA", "EL", "XK", "MD", "UA", "UK"))
# Replacing the codes
owid_energy <- owid_energy %>% 
  left_join(eu_country_codes, by = "country") %>% 
  mutate(CNTR_CODE = ifelse(is.na(id), CNTR_CODE, id)) %>% 
  select(-id)

# Creating the final dataset
renewable_energy_europe <- owid_energy %>% 
  inner_join(european_map, by = "CNTR_CODE") %>% 
  st_as_sf()

# Adding the font
library(showtext)
font_add_google(name = "Roboto", family = "Roboto Serif")

to_plot <- renewable_energy_europe %>% 
  filter(year >= 1990)

# Plotting
plot <- ggplot(data = to_plot, aes(fill = green_energy)) + 
  geom_sf() +
  scale_x_continuous(limits = c(-10, 35)) +
  scale_y_continuous(limits = c(33, 72)) +
  scale_fill_gradientn(colors = c("pink", "#cbc318", "#f5e356", "lightgreen", "#68a225", "#265c00", "#265c00", "#265c00", "#265c00", "#265c00", "#265c00"), labels = scales::label_percent(accuracy = 1, scale = 1, suffix = "%"))+ 
  theme_void() +
  theme(plot.background = element_rect(fill = "#1b1b1b"), 
        plot.title = element_text(color = "#90ee90",
                                  hjust = 0.5, 
                                  family = "Roboto Serif"), 
        plot.subtitle = element_text(color = "#90ee90",
                                    hjust = 0.5, 
                                    family = "Roboto Serif"),
        legend.title = element_blank(),
        legend.text = element_text(color = "#90ee90")) +
  labs(title = "Renewable Energy production as % of total") +
  # Animation
  shadow_mark() + 
  ggtitle("Renewable Energy as the % of total", 
          subtitle = "Year: {frame_time}") +
  transition_time(to_plot$year)

animate(plot, nframes = 33, fps = 2)
# Saving the gif
anim_save("Renewable_Energy_percentage.gif")
