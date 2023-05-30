library(tidyverse)
library(rvest)
library(showtext)

# Reading the data
tuesdata <- tidytuesdayR::tt_load(2023, week = 22)

centenarians <- tuesdata$centenarians

# Examining which countries the data include
unique_countries <- as.list(unique(centenarians$place_of_death_or_residence))

# Printing the unique countries and the number of centenarians
for (x in unique_countries) {
  print(paste(x, ": ", sum(centenarians$place_of_death_or_residence==x), sep = ""))
}

# I will make a graph that will include information about the gender and the continent.
# For that, it is neccessary to include a new column with the continent. In order to achive this, I make a list of the countries of each continent.
# I will do it by reading the list of countires of Wikipedia. 


# ----------------------Reading the list of countries for each continent----------------------

# EUROPE
url <- "https://simple.wikipedia.org/wiki/List_of_European_countries"
page <- read_html(url)

# Some countries include references wich means that their name is followed by "[]" with the number of reference. I am cleansing the names of the countries and I only extract the countries' names.
eu_countries <- page %>% 
  html_nodes(css = "table") %>% 
  .[[1]] %>% 
  html_table(header = TRUE, trim = TRUE) %>% 
# Some countries include references wich means that their name is followed by "[]" with the number of reference. I am cleansing the names of the countries and I only extract the countries' names.
  mutate(Country = str_extract(`Name of country orterritory, with flag`, "(?:(?!(\\[)).)*")) %>% 
  select(Country)


# ASIA
url <- "https://en.wikipedia.org/wiki/List_of_Asian_countries_by_population"
page <- read_html(url)

asian_countries <- page %>% 
  html_nodes(css = "table") %>% 
  .[[1]] %>% 
  html_table(header = TRUE, trim = TRUE) %>% 
  select(Country) %>% 
  slice(1:(n() - 1))

  
# OCEANIA
url <- "https://en.wikipedia.org/wiki/List_of_Oceanian_countries_by_population" 
page <- read_html(url)

oceanian_countries <- page %>% 
  html_nodes(css = "table") %>% 
  .[[1]] %>% 
  html_table(header = TRUE, trim = TRUE) %>% 
  # Naming all the columns in order to be able to procceed with the cleaning of territories
  setNames(make.names(names(.))) %>% 
  filter(as.integer(X) >= 1) %>% 
  select(Country...territory) %>% 
  rename(Country = Country...territory)


# NORTH AMERICA
url <- "https://en.wikipedia.org/wiki/List_of_North_American_countries_by_population"
page <- read_html(url)

n_american_countries <- page %>% 
  html_nodes(css = "table") %>% 
  .[[1]] %>% 
  html_table(header = TRUE, trim = TRUE) %>% 
  select(Country) %>% 
  slice(2:(n() - 1))
  
# SOUTH AMERICA
url <- "https://en.wikipedia.org/wiki/List_of_South_American_countries_by_population"
page <- read_html(url)

s_american_countries <- page %>% 
  html_nodes(css = "table") %>% 
  .[[1]] %>% 
  html_table(header = TRUE, trim = TRUE) %>% 
  select(Country) %>% 
  slice(2:(n() - 1))

# As for the African countries, there is no need to extact the list because if no country belongs to the other continets, it belongs to Africa. Also, by looking at the unique countries, we notice that no African country is included. 

# ----------------------Making necessary changes to the main dataframe----------------------
# It is also necessary to make some changes to the countries of the main data. This is because for people who lived for example in French Guinea, the country is "France (French Guinea)". 
# If there are parenthesis in the countries, I extract the text between them and replace the country with it.

centenarians <- rename(centenarians, Country=place_of_death_or_residence)

centenarians$Country <- ifelse(str_detect(centenarians$Country, "\\(.*\\)"),
                               str_extract(centenarians$Country, "(?<=\\()(.*?)(?=\\))"),
                               centenarians$Country)
# Adding the continent
centenarians$Continent <- ifelse(centenarians$Country %in% eu_countries$Country,
                                 "Europe",
                                  ifelse(centenarians$Country %in% asian_countries$Country,
                                          "Asia",
                                         ifelse(centenarians$Country %in% oceanian_countries$Country,
                                                "Oceania",
                                                ifelse(centenarians$Country %in% n_american_countries$Country,
                                                       "North America",
                                                       ifelse(centenarians$Country %in% s_american_countries$Country,
                                                              "South America",
                                 "Africa")))))

# ----------------------PLOTS----------------------

# Adding the font
font_add_google("Smythe")
showtext_auto()

# Adding the colors of the observations
continent_colors <- c("Europe" = "#001489", "Asia" = "yellow", "Oceania" = "lightblue", "North America" = "darkred", "South America" = "lightgreen")
gender_colors <- c("male" = "blue", "female" = "red")

plot1_subtitle <- "This graph shows the eldest people who were born after 1900.
The ones that are less transparent are still alive. It seems that from the early 1910s, the balance between the two genders has changed as you find more men than women"

# The plot will show the ages, the gender, the continent and if they are still alive for the ones borned after 1900 
plot1 <- ggplot(centenarians, aes(x = birth_date)) + 
  geom_segment(aes(xend = birth_date, y = 100, yend = age, color = gender, alpha = still_alive == "alive")) +
  geom_point(aes(y = age, color = Continent, alpha = still_alive == "alive"), size = 3) +
  scale_color_manual(values = c(gender_colors, continent_colors)) +
  scale_alpha_manual(values = c(0.3, 0.9), guide = "none") +
  scale_x_date(date_labels = "%Y", date_breaks = "2 years", limits = c(as.Date("1900-01-01"), NA)) +
  labs(x = "Year of Birth", y = "Age", title = "Eldest people born after 1900", subtitle = plot1_subtitle) +
  theme_minimal() + 
  theme(panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major = element_line(color = "#537188", linewidth = 0.1), 
        plot.background = element_rect("#F6F1F1", linewidth = 0), 
        panel.background = element_rect("#FFFBEB", linewidth = 0), 
        plot.title = element_text(hjust = 0.5, vjust = 1, size = 14, family = "Smythe", face = "bold"),
        axis.title.x = element_text(hjust = 0.5, vjust = 1, size = 12, family = "Smythe"),
        axis.title.y = element_text(hjust = 0.5, vjust = 1, size = 12, family = "Smythe", angle = 90),
        plot.subtitle = element_text(hjust = 0.5, vjust = 1, size = 9), 
        legend.position = "bottom", legend.title = element_blank(), legend.background = element_rect("#EEEEEE", linewidth = 0))

# Showing the plot
plot1