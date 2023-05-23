library(tidyverse)
tuesdata <- tidytuesdayR::tt_load(2023, week=21)

squirrel_data <- tuesdata$squirrel_data
rm(tuesdata)

# I am going to check the percentage of Adult and Juvenile squirrels that approach, are indifferent and run away with the presence of humans.

# For that, I create a matrix to host the data and I create a for loop for each column and each age group.

columns_to_examine <- c("Approaches", "Indifferent", "Runs from")
age_to_examine <- c("Adult", "Juvenile")

results <- matrix(nrow = length(columns_to_examine), ncol = length(age_to_examine), dimnames = list(columns_to_examine, age_to_examine))

for (i in 1:length(columns_to_examine)){
  for (k in 1:length(age_to_examine)) {
    result <- sum(squirrel_data[[columns_to_examine[i]]] & squirrel_data$Age == age_to_examine[k], na.rm = TRUE)  / sum(squirrel_data$Age == age_to_examine[k], na.rm = TRUE)
    results[i, k] <- paste0(round(result*100, 2), "%")
  }
}

# Showing the results.
results

# I will see if there are specific areas where squirrels approach and others where they avoid humans.
library(leaflet)

# Normal map
normal_map <- leaflet() %>% 
  addCircleMarkers(data = squirrel_data[squirrel_data$`Runs from`== TRUE, ], lng = ~X, lat = ~Y, color = "red", radius = 2, fillOpacity = 0.1) %>% 
  addCircleMarkers(data=squirrel_data[squirrel_data$Approaches == TRUE, ], lng = ~X, lat = ~Y, color = "blue", radius = 2, fillOpacity = 0.5) %>% 
  addTiles() %>% 
  addLegend(position = "topleft",
            colors = c("red", "blue"),
            labels = c("Running away", "Approaching"),
            title = "Behavior of Squirrels with people")

#Showing the map
normal_map

# Dark map in order to make it ore clear
dark_map <- leaflet() %>% 
  addCircleMarkers(data = squirrel_data[squirrel_data$`Runs from`== TRUE, ], lng = ~X, lat = ~Y, color = "red", radius = 3, fillOpacity = 0.1) %>% 
  addCircleMarkers(data=squirrel_data[squirrel_data$Approaches == TRUE, ], lng = ~X, lat = ~Y, color = "green", radius = 3, fillOpacity = 0.5) %>% 
  addTiles() %>% 
  addLegend(position = "topleft",
            colors = c("red", "green"),
            labels = c("Running away", "Approaching"),
            title = "Behavior of Squirrels with people") %>% 
  addProviderTiles("CartoDB.DarkMatter")

#Showing the map
dark_map

