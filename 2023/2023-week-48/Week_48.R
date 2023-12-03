library(tidyverse)
library(showtext)

# ---- READ THE DATA ----
tuesdata <- tidytuesdayR::tt_load(2023, week = 48)

drwho_episodes <- tuesdata$drwho_episodes
drwho_directors <- tuesdata$drwho_directors
drwho_writers <- tuesdata$drwho_writers
rm(tuesdata)

# ---- FONTS ----

# Reading the font Doctor Who 2006 Font by 24hourfonts from https://www.fontspace.com/doctor-who-2006-font-f12647
font_add(family = "Dr_Who_2006",
         regular = "~/.fonts/R/doctor-who-2006-font/DoctorWho2006-pqpy.ttf")

# Reading the font Doctor Who by Jje990 from https://www.dafont.com/doctor-who.font
font_add(family = "Dr_Who",
         regular = "~/.fonts/R/doctor_who/Doctor-Who.ttf")

showtext_auto()

# ---- DATA MANIPULATION ----

# Change episodes NA con 0 as it appears in IMDB
drwho_episodes$episode_number <- replace_na(drwho_episodes$episode_number, 0)

# Taken from https://r-graph-gallery.com/web-lollipop-plot-with-R-the-office.html (graph made by Cedric Scherer for TidyTuesday)
# Compute the Average rating for each episode
drwho_episodes_avg <-drwho_episodes %>% 
  arrange(season_number, episode_number) %>% 
  mutate(episode_id = row_number()) %>% # Each episode has a unique episode_id with order from the first to the last)
  group_by(season_number) %>% 
  mutate(
    avg_rating = mean(rating),
    episode_mod = if_else(!is.na(season_number), episode_id + (length(unique(drwho_episodes$season_number)) * season_number), episode_id + (length(unique(drwho_episodes$season_number)) ^ 2)),
    mid = mean(episode_mod)
    ) %>% 
  ungroup() 

# Replace the NAs in Seasons as 'Special'
drwho_episodes_avg$season_number[is.na(drwho_episodes_avg$season_number)] <- 'Special'

# Make the seasons_number a factor as for the ggplot2 to not consider ir as a continuous variable
drwho_episodes_avg$season_number <- factor(drwho_episodes_avg$season_number)

# Normalise the values of the duration to be between 0 and 1.
drwho_episodes_avg$duration_norm <- scales::rescale(drwho_episodes_avg$duration)

# -- Create the avg lines -- 
df_lines <- drwho_episodes_avg %>% 
  group_by(season_number) %>% 
  summarise(
    start_x = min(episode_mod) - 7,
    end_x = max(episode_mod) + 7,
    y = unique(avg_rating)
  ) %>% 
  pivot_longer(
    cols = c(start_x, end_x),
    names_to = "type",
    values_to = "x"
  ) %>% 
  mutate(
    x_group = if_else(type == "start_x", x + .1, x - .1),
    x_group = if_else(type == "start_x" & x == min(x), x_group - .1, x_group),
    x_group = if_else(type == "end_x" & x == max(x), x_group + .1, x_group)
  )


# ---- PLOT ----
ratings_plot <- ggplot(data = drwho_episodes_avg, 
       aes(
         episode_mod,
         rating
       )) +
  geom_hline(
    data = tibble(y=seq(70, 95, 5)),
    aes(yintercept = y),
    color = "grey82",
    linewidth = .5
  ) +
  geom_hline(
    data = tibble(y=seq(70, 95)),
    aes(yintercept = y),
    color = "grey85",
    linewidth = .1
  ) +
  
  geom_segment(
    aes(
      xend = episode_mod,
      yend = avg_rating,
      color = season_number,
      color = after_scale(colorspace::lighten(color, .2))
    ),
    linewidth = drwho_episodes_avg$duration_norm + 0.5 #The wider the line, the longer the episode
  ) +
  
  geom_line(
    data = df_lines,
    aes(x, y),
    color = "#6F8EA9"
  ) +
  geom_line(
    data = df_lines,
    aes(
      x_group,
      y,
      color = season_number,
      color = after_scale(colorspace::darken(color, .4))
    ),
    linewidth = 2.5
  ) +

  geom_point(
    aes(size = uk_viewers, color = season_number)
  ) +
  
  geom_label(
    aes(
      mid,
      96,
      label = if_else(season_number != "Special", glue::glue(" Season {season_number} "), "Special"),
      size = 8,
      color = season_number,
      color = after_scale(colorspace::darken(color, .4))
    ),
    fill = NA,
    family = "Dr_Who",
    label.padding = unit(.2, "lines"),
    label.r = unit(.25, "lines"), 
    label.size = .5
  ) +
  
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "#edf0f3", color = "#edf0f3"),
    panel.background = element_rect(fill = NA, color = NA),
    panel.border = element_rect(fill = NA, color = NA),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_text(size = 10),
    axis.ticks = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_text(family = "Dr_Who", size = 13, margin = margin(r = 10)),
    plot.title = element_text(family = "Dr_Who_2006", size = 50, colour = "#1f70c6", hjust = 0.5, vjust = -0.5),
    legend.title = element_text(size = 9),
    plot.caption = element_text(
      size = 10,
      color = "grey70",
      face = "bold",
      hjust = .5,
      margin = margin(5, 0, 20, 0)
    ),
    plot.margin = margin(10, 25, 10, 25)
  ) +
  ylab("UK RATING") +
  ggtitle("o") +
  
  scale_x_continuous(expand = c(.015, .015)) +
  scale_y_continuous(
    expand = c(.1, .1),
    limits = c(70, 98),
    breaks = seq(70, 95, by = 5),
    sec.axis = dup_axis(name = NULL)
  ) +
  
  scale_color_manual(values = c(
    "#0b2847", 
    "#124071", 
    "#154c87", 
    "#18589c",
    "#1c64b1", 
    "#1f70c6", 
    "#2176d1", 
    "#227cdc", 
    "#2588f1",
    "#92c4f8",
    "#1f70c6",
    "#2176d1",
    "#227cdc",
    "#2588f1"
    ), 
    guide = "none") +
  
  scale_size_binned(name = "Uk viewers (millions)") +
  
  guides(
    size = guide_bins(
      show.limits = TRUE,
      direction = "horizontal",
      title.position = "top",
      title.hjust = 0.5
    )
  ) +
  
  theme(
    legend.position = c(.9, .15),
    legend.key.width = unit(1.5, "lines")
  )

# Show the plot
ratings_plot