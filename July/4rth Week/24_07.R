library(tidyverse)
library(showtext)
library(ggtext)

# Read the data
tuesdata <- tidytuesdayR::tt_load(2023, week = 30)
scurvy <- tuesdata$scurvy
rm(tuesdata)

# Reading the fonts downloaded from fontawesome
sysfonts::font_add(family = "fa-solid",
                   regular = "~/.fonts/fontawesome-free-6.4.0-desktop/otfs/Font Awesome 6 Free-Solid-900.otf")
# Reading the 'Treasuremap' font from JoannaVu
sysfonts::font_add(family = 'treasuremap',
                   regular = "~/.fonts/treasure-map-font/Treasuremap-Ea1vj.ttf")
# Reading the 'Treasuremap Deadhand' font from GemFonts
sysfonts::font_add(family = 'deadhand',
                   regular = "~/.fonts/treasure-map-deadhand-font/TreasureMapDeadhand-yLA3.ttf")
# Reading the 'Treasurehunt' font from Måns Grebäck
sysfonts::font_add(family = 'treasurehunt',
                   regular = "~/.fonts/treasurehunt-font/TreasurehuntPersonalUseRegular-3zKgp.otf")
# Reading the 'Freebooter' font from GemFonts
sysfonts::font_add(family = 'freebooter',
                   regular = "~/.fonts/freebooter-font/FreebooterItalic-5Xlv.ttf")
showtext_auto()

# Colors
cured = "lightgreen"
mild = "grey"
moderate = "#ffff66"
severe = "#c40233"
title = "#f7f5f6"
background = "#00022e"

# Subtitle text
sub_text <- "\nIn 1747, James Lind was the first to conduct a test about the efficiency of different acids in treating Scurvy,
a disease from which many seamen were suffering.\n
Below are shown the final results of the 12 sailors' condition after 6 days of treatment with 6 different methods.
Each method applied to 2 seamen"
# -------------DATA MANIPULATION-------------
scurvy <- scurvy %>% 
  mutate(
    # Keep only the number of the values
    across(gum_rot_d6:fit_for_duty_d6, parse_number),
    # Create a new column 'total' with the final "score"
    total = round((rowSums(across(gum_rot_d6:lassitude_d6))) / 4, digits = 0),
    # Name the condition after 6 weeks, depending on the final "score"
    condition = case_when(
      total == 0 ~ 'cured',
      total == 1 ~ 'mild',
      total == 2 ~ 'moderate',
      total == 3 ~ 'severe'
    )) %>% 
  # Sort firstly by total and secondly by treatment
  arrange(total, treatment)

# Create a timble to plot in 2 two columns and 6 rows
to_plot <- expand.grid(x = 1:2, y = 1:6) %>% 
  as_tibble() %>% 
  mutate(
    # Insert the code of each icon from fontawesome
    icons = case_when(
      scurvy$treatment == 'cider' ~ 'f72f', # wine-bottle
      scurvy$treatment == 'dilute_sulfuric_acid' ~ 'f486', # prescription-bottle-medical
      scurvy$treatment == 'vinegar' ~ 'e4c4', # bottle-droplet
      scurvy$treatment == 'sea_water' ~ 'f773', # water
      scurvy$treatment == 'citrus' ~ 'f094', # lemon
      scurvy$treatment == 'purgative_mixture' ~ 'f06c' # leaf
    ),
    # Insert the colours depending on the final "score"
    colors = case_when(
      scurvy$total == 0 ~ cured,
      scurvy$total == 1 ~ mild,
      scurvy$total == 2 ~ moderate,
      scurvy$total == 3 ~ severe
    )
  )

# Legend
legend_icons <- tibble(
  x = 3.5,
  y = seq(2, 3.5, by = 0.3),
  icons_text = c(
      "<span style='font-family:fa-solid'>&#xf72f;</span>",
      "<span style='font-family:fa-solid'>&#xf486;</span>",
      "<span style='font-family:fa-solid'>&#xe4c4;</span>",
      "<span style='font-family:fa-solid'>&#xf773;</span>",
      "<span style='font-family:fa-solid'>&#xf094;</span>",
      "<span style='font-family:fa-solid'>&#xf06c;</span>"
    ),
  icon_meaning = c(
    'Cider',
    'Dilute Sulfuric Acid',
    'Vinegar',
    'Sea Water',
    'Citrus',
    'Purgative Mixture'
  )
)
  
legend_colors <- tibble(
  x = 3.5,
  y = seq(4.5, 5.4, by = 0.3),
  circle_icon = c(
    "<span style='font-family:fa-solid'>&#xf111;</span>",
    "<span style='font-family:fa-solid'>&#xf111;</span>",
    "<span style='font-family:fa-solid'>&#xf111;</span>",
    "<span style='font-family:fa-solid'>&#xf111;</span>"
  ),
  icon_color = c(
    cured,
    mild,
    moderate,
    severe
  ),
  situation = c(
    'Cured',
    'Mild',
    'Moderate',
    'Severe'
  )
)

# ----------PLOTS---------------
ggplot() +
  # The main plot
  geom_richtext(data = to_plot,
                mapping = aes(x = x, y = desc(y)),
                label = paste0("<span style='font-family:fa-solid'>&#x", to_plot$icons,";</span>"),
                size = 18, label.colour = NA, fill = NA, col = to_plot$colors, position = position_dodge(width = 0.5)) +
  
  # The text
  
  # -----The legend-----
  # Icons
  geom_richtext(data = legend_icons, 
                mapping = aes(x = x, y = desc(y)), 
                label = legend_icons$icons_text,
                size = 6, label.colour = NA, fill = NA, col = title, hjust = 0, vjust = 0.5)+
  geom_text(data = legend_icons, 
            mapping = aes(x = x + 0.3, y = desc(y), family = 'deadhand'), 
            label = legend_icons$icon_meaning,
            size = 6, col = 'white', hjust = 0, vjust = 0.5) +
  
  # Colours
  geom_richtext(data = legend_colors, 
                mapping = aes(x = x, y = desc(y)), 
                label = legend_colors$circle_icon,
                size = 5, label.colour = NA, fill = NA, col = legend_colors$icon_color, hjust = 0, vjust = 0.5)+
  geom_text(data = legend_colors, 
           mapping = aes(x = x + 0.3, y = desc(y), family = 'deadhand'),
           label = legend_colors$situation,
           size = 6, col = "white", hjust = 0, vjust = 0.5) +
  # -------------------

  scale_x_continuous(limits = c(0.5, 5)) +
  scale_y_continuous(limits = c(-6.5, -0.5)) +
  
  ggtitle("SCURVY¤ILLNESS", subtitle = sub_text) + 
  
  # Subtitle 
  theme(
    plot.title = element_text(family = 'treasurehunt', face = 'bold', size = 50, hjust = 0.5, colour = title),
    plot.subtitle = element_text(family = 'freebooter', size = 18, hjust = 0.5, colour = title),
    
    plot.background = element_rect(fill = background, colour = NA),
    panel.background = element_rect(fill = background, colour = NA),
    
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
  )
