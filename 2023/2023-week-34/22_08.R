library(tidyverse)
library(leaflet)
library(RColorBrewer)

# Read the data
tuesdata <- tidytuesdayR::tt_load(2023, week = 34)
population <- tuesdata$population
rm(tuesdata)

# ---- DATA MANIPULATION ----
# Extract only where the asylum is Greece
population <- population %>% 
  filter(coa_name == 'Greece')

# Put the longitute and latitude for each country

# For Greece
greece <- maps::map('world', regions = "Greece", plot=FALSE, exact=TRUE)
  greece_long <- mean(greece$range[1:2])
  greece_lat <- mean(greece$range[3:4])
  
# First, create a function of tryCatch in order to deal with missing countries
# The longitude and latitude are taken from the 'maps' package. It returns a list of lists (x, y, range, names). I use the 'range' list.
# Check if the country can be found and if not, return a list 'range' with NA instead of the coordinates.
# This is made to ensure that the below if{} else{} statement will work without any workarounds. 
country_info <- function(country) {
  tryCatch(
    {
      result <- maps::map('world', regions = country, plot = FALSE, exact = TRUE)
      return(result)
    },
    error = function(e){
      result <- list(range = NA)
      message('ERROR')
      print(e)
      return(result)
    },
    warning = function(w) {
      result <- list(range = NA)
      message('Warning message')
      print(w)
      return(result)
    }
  )
}

# Insert the longitude and latitude for each country of origin 
for (country in unique(population$coo_name)) {
  country_long_lat <- country_info(country)
  if (!is.na(country_long_lat$range[1])) {
    population[population$coo_name == country, 'coo_long'] <- mean(country_long_lat$range[1:2])
    population[population$coo_name == country, 'coo_lat'] <- mean(country_long_lat$range[3:4])
  } else {
    population[population$coo_name == country, 'coo_long'] <- NA
    population[population$coo_name == country, 'coo_lat'] <- NA
  }
}


# Delete NAs values 
population <- population %>% 
  filter(!is.na(coo_long))

# Create a new column with the sum of refugees and asylum seekers for each year
population2 <- population %>% 
  group_by(year) %>% 
  summarise(Refugees = sum(refugees),
            Asylum_seekers = sum(asylum_seekers)
            )
# ---- PLOT ----

# Create a color pallete
pal_col <- colorFactor(brewer.pal(11, 'Spectral'), population$coo_name)

map <- leaflet() %>% 
  # Add the map
  addProviderTiles('CartoDB.Positron') %>%
  # Add the flows
  leaflet.minicharts::addFlows(lng0 = population$coo_long, 
    lat0 = population$coo_lat, 
    lng1 = greece_long,
    lat1 = greece_lat,
    flow = population$asylum_seekers,
    time = population$year, 
    opacity = 0.8, 
    color = pal_col(population$coo_name),
    popupOptions = list(closeOnClick = FALSE, autoClose = FALSE)
  ) %>% 
  # Add the barchart
   leaflet.minicharts::addMinicharts(
     lng = greece_long ,
     lat = greece_lat + 10, 
     chartdata = select(population2, Refugees, Asylum_seekers),
     time = population2$year,
     colorPalette = c('#FFBA00', '#242124')
   )

# Show the map
map
