library(tidyverse)
library(showtext)

tuesdata <- tidytuesdayR::tt_load(2023, week = 20)

tornados <- tuesdata$tornados
rm(tuesdata)

# Selecting only the tornados that injuried people and lead to fatalities
tornados_serious <- tornados %>% 
  filter(inj > 0,
         fat > 0,
         sn == 1) %>% 
  select(st, inj, fat, mag)

# Choosing the 10 states by the total number of tornados
top_10 <- tornados_serious %>% 
  group_by(st) %>% 
  summarise(tornado_count = n()) %>% 
  arrange(desc(tornado_count)) %>% 
  top_n(10)

# Replacing the state codes with the actual names
tornados_final <- tornados_serious %>% 
  filter(st %in% top_10$st) %>% 
  mutate("states" = state.name[match(st, state.abb)])

# Adding the font
font_add_google("Fredericka the Great", "fred")
showtext_auto()

# Making the plot for injuries
injuries <- ggplot(tornados_final, aes(x = inj, y = states)) +
  geom_boxplot(aes(fill = "inj", color = "inj"), position = position_dodge(width = 0.75), outlier.shape = NA, alpha = 0.7) +
  geom_point(aes(color = "inj_points"), position = position_jitterdodge(dodge.width = 0.9), alpha = 0.8) +
  scale_fill_manual(values = c("inj" = "#FFAD05")) +
  scale_color_manual(values = c("inj" = "#FF8305", "inj_points" = "#FFB300")) +
  coord_cartesian(xlim =c(0, 90)) +
  guides(color = "none", fill = "none") +
  labs(title = "Number of injuries from tornados") +
  theme_minimal() + 
  theme(panel.grid.major.y = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(size = 16, hjust = 0.7),
        axis.text.y = element_text(size = 13)) 
injuries

# Making a plot for fatalities
fatalities <- ggplot(tornados_final, aes(x = fat, y = states)) +
  geom_boxplot(aes(fill = "fat", color = "fat"), position = position_dodge(width = 0.75), outlier.shape = NA, alpha = 0.7) +
  geom_point(aes(color = "fat_points"), position = position_jitterdodge(dodge.width = 0.9), alpha = 0.8) +
  scale_fill_manual(values = c("fat" = "#CD5C5C")) +
  scale_color_manual(values = c("fat" = "#ED2939", "fat_points" = "#953234")) +
  coord_cartesian(xlim =c(0, 10)) +
  guides(color = "none", fill = "none") +
  labs(title = "Number of fatalities from tornados") +
  theme_minimal() + 
  theme(panel.grid.major.y = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(size = 15, hjust = 0.7),
        axis.text.y = element_text(size = 13)) 
fatalities  

# Making a combining plot

inj_fat <- ggplot(tornados_final, aes(y = states)) +
  geom_boxplot(aes(x = fat, fill = "fat", color = "fat"), position = position_dodge(width = 0.75), outlier.shape = NA, alpha = 0.5) +
  geom_boxplot(aes(x = inj, fill = "inj", color = "inj"), position = position_dodge(width = 0.75), outlier.shape = NA, alpha = 0.7) +
  geom_point(aes(x = fat, color = "fat_points"), position = position_jitterdodge(dodge.width = 0.9), alpha = 0.8) +
  geom_point(aes(x = inj, color = "inj_points"), position = position_jitterdodge(dodge.width = 0.9), alpha = 0.8) +
  scale_fill_manual(values = c("fat" = "#CD5C5C", "inj" = "#FFAD05")) +
  scale_color_manual(values = c("fat" = "#ED2939", "inj" = "#FF8305", "fat_points" = "#C74848", "inj_points" = "#FFB300")) +
  coord_cartesian(xlim =c(0, 70)) +
  guides(color = "none", fill = "none") +
  labs(title = "Number of injuries and fatalities from tornados") +
  theme_minimal() + 
  theme(panel.grid.major.y = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(size = 17, hjust = 0.6),
        axis.text.y = element_text(size = 13)) 
inj_fat
