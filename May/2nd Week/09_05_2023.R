library(tidyverse)

data <- tidytuesdayR::tt_load(2023, week = 19)

children_costs <- data$childcare_costs
counties <- data$counties

rm(data)
# REGRESSION

# Calculating the mean values for USA
average_USA <- children_costs %>% 
  group_by(study_year) %>% 
  summarise(across(.cols = 3:ncol(children_costs)-1, .names = "avg_{col}", .fn=mean, na.rm = TRUE))

# Preparing the independet variables which are the ones associated with unemployment and income
# I use regular expressions to separate the columns which include the unemployment and the income
unemployement_cols = grep(pattern="\\w?unr_+\\d*", x=names(average_USA), perl = TRUE, value=TRUE)
income_cols = grep(pattern = "$_2018", x = names(average_USA), perl = TRUE, value = TRUE)

# I create the independet variables and the formula which will be the first part of the regression. 
independent_variables <- paste0(c(unemployement_cols, income_cols))
formula <- formula(paste("avg_mcsa ~", paste(independent_variables, collapse = "+")))

# I train the model and print the results
model <- lm(formula, data = na.omit(average_USA[, c(independent_variables, "avg_mcsa")]))
summary_table <- summary(model)

# Create a table of coefficients
coef_table <- data.frame(summary_table$coefficients)

# Add a column for standard errors
coef_table$SE <- summary_table$sigma

# Format the table using kable
kable(coef_table, digits = 3)


# GRAPHS

# I am going to make a graph which shows the % change of cost in each state between 2008 and 2017

# There are some counties that do not contain data for all the years. in order to find the percentage change, I am using a function that searches if there are data for the 
# first and last four years and takes the first and latest. I am not checking all the data because it would not make so much sense to compare states with one-year 
# cost change and others with 11 years cost change. 

calculate_percentage_change <- function(mcsa) {
  cost_before <- NaN
  for (i in range(1, 4)) {
    if (!is.na(mcsa[i])) {
      cost_before <- mcsa[i]
      break
    } }
  cost_after <- NaN
  for (i in seq(11, 8, -1)) {
    if (!is.na(mcsa[i])) {
      cost_after <- mcsa[i]
      break
    } }
  if (is.na(cost_before) | is.na(cost_after)) {
    return (NaN)
  } else {
    prc_chng <- ((cost_after - cost_before) / cost_before)
    return (prc_chng)
  }
}

# I am using the mfccsa column fo the cost. 
# Calculating the % cost change
by_counties <- children_costs %>% 
  group_by(county_fips_code) %>% 
  mutate(mfccsa_prc_change = calculate_percentage_change(mfccsa)) %>% 
  select(county_fips_code, mfccsa_prc_change, mfccsa, study_year)

# Choosing the cost of 2018
by_counties <- by_counties %>% 
  filter(study_year == 2018) %>% 
  select(county_fips_code, mfccsa_prc_change, mfccsa)

# I will also show the five States (not counties) that have raised the cost of childcare the most. 
# Join the dataframes to have the percentage of every state. 
by_counties <- merge(by_counties, counties, by = "county_fips_code")
by_counties <- by_counties %>% 
  select(county_fips_code, mfccsa_prc_change, mfccsa, state_name)

by_state <- by_counties %>% 
  group_by(state_name) %>% 
  summarise(avg_prc_change = mean(mfccsa_prc_change, na.rm = TRUE),
           avg_mfccsa = mean(mfccsa, na.rm = TRUE)) %>% 
  select(state_name, avg_prc_change, avg_mfccsa)
  

# Graphs
library(sf)
# Reading the counties Shapefile from my systhem instead of using the maps libarry and tranform it so I can plot it better
counties_sf <- st_read("./USA_Counties/USA_Counties.shp") %>% 
  st_transform(crs = "+proj=longlat +datum=WGS84")

# Same for the States
states_sf <- st_read("./States_shapefile/States_shapefile.shp") %>% 
  st_transform(crs = "+proj=longlat +datum=WGS84")
  

# Preparing the data to plot for counties

# Because counties_sf keeps a lot of information, I only keep the columns that I need.
counties_sf <- counties_sf[, c("FIPS", "geometry")]
# I change the type of FIPS in order to be the same in the two datasets.
by_counties$county_fips_code <- as.character(by_counties$county_fips_code)

# Joining the datasets to plot them
counties_by <- join_by(FIPS, county_fips_code)
to_plot_counties <- right_join(x = counties_sf, y = by_counties, by = c("FIPS"="county_fips_code"))

# Joining the datasets for the state
by_state$State_Name <- toupper(by_state$state_name)
to_plot_states <- left_join(x = states_sf, y = by_state)

states <- ggplot(to_plot_states) +
                  geom_sf(aes(fill = avg_prc_change), lwd = 0.2) +
                  scale_fill_gradient2(low = "#5cb85c", mid = "white", high = "#d9534f", midpoint = 0, na.value = "#cccccc",
                                       labels = scales::percent_format(),
                                       breaks = seq(-0.2, 1, 0.25)) +
                  labs(title = "Cost change", fill = "% change") +
                  coord_sf(xlim = c(-125, -68), ylim = c(20, 55)) +
                  theme(panel.background = element_rect(fill = "#f5f5f5"),
                        panel.grid = element_blank(),
                        plot.title = element_text(hjust = 0.5, size = 20),
                        axis.text = element_blank(),
                        axis.title = element_blank(),
                        legend.background = element_rect(fill = "white", color = NA),
                        legend.key.width = unit(1, "cm"),
                        legend.key.height = unit(0.5, "cm"),
                        legend.key = element_rect(color = "white"))

counties <- ggplot(to_plot_counties) +
                    geom_sf(aes(fill = log(mfccsa)), lwd = 0.2) +
                    scale_fill_gradient(low = "white", high = "blue", na.value = "#cccccc",
                                         labels = scales::dollar_format(),
                                         breaks = seq(50, 400, 100), 
                                        trans = "log10")+
                    labs(title = "Childcare Cost (2018)") +
                    coord_sf(xlim = c(-125, -68), ylim = c(20, 55)) +
                    theme(panel.background = element_rect(fill = "#f5f5f5"),
                          panel.grid = element_blank(),
                          plot.title = element_text(hjust = 0.5, size = 18),
                          axis.text = element_blank(),
                          axis.title = element_blank())


library(cowplot)
plot_grid(states, counties, ncol = 1, align = "v", axis = "t")
