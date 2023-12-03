library(tidyverse)
library(showtext)

# ---- FONTS ----
font_add_google(name = 'Barlow')
font_add(family = "Dr_Who_2006",
         regular = "~/.fonts/R/doctor-who-2006-font/DoctorWho2006-pqpy.ttf")

# Reading the font Doctor Who by Jje990 from https://www.dafont.com/doctor-who.font
font_add(family = "Dr_Who",
         regular = "~/.fonts/R/doctor_who/Doctor-Who.ttf")
showtext_auto()

# ---- READ THE DATA ----
tuesdata <- tidytuesdayR::tt_load(2023, week = 48)

drwho_episodes <- tuesdata$drwho_episodes
drwho_directors <- tuesdata$drwho_directors
drwho_writers <- tuesdata$drwho_writers
#rm(tuesdata)

# ---- DATA MANIPULATION ----
dir_writ <- merge(drwho_directors, drwho_writers, by = "story_number", all = TRUE)
collabs_table <- table(dir_writ$writer, dir_writ$director)
collabs_df <- as.data.frame(collabs_table)
collabs_df$Freq <- as.numeric(collabs_df$Freq)


# ---- PLOT ----
dir_writ_heatmap <- ggplot(data = collabs_df[collabs_df$Freq > 1, ], 
       aes(
         Var1,
         Var2
       )) +
  geom_tile(aes(fill = Freq), colour = "white", na.rm = TRUE) +
  scale_fill_gradient(low = "#92c4f8", high = "#124071", guide = guide_legend(title.position = "top")) +
  
  labs(x = "Writers",
       y = "Directors", 
       fill = "Number of Collaborations",
       title = "o") +
  
  
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    
    plot.background = element_rect(fill = "#edf0f3", colour = "#edf0f3"),
    
    legend.direction = "horizontal",
    legend.position = c(.1, .95),
    legend.margin = margin(0, 0, 8, 0, unit = "lines"),
    legend.title = element_text(family = 'Barlow', colour = "#124071"),
    
    plot.title = element_text(family = "Dr_Who_2006", size = 50, colour = "#1f70c6", hjust = 0.5, vjust = -0.5),
    axis.title.x = element_text(family = "Dr_Who", size = 25, colour = "#1f70c6"),
    axis.title.y = element_text(family = "Dr_Who", size = 25, colour = "#1f70c6"),
    axis.text.x = element_text(family = 'Barlow', size = 15, colour = "#124071"),
    axis.text.y = element_text(family = 'Barlow', size = 15, colour = "#124071")
  )

# Show the plot
dir_writ_heatmap
