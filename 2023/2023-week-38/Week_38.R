# TidyTuesday | Week 38, Year 2023 | Creator: Ioannis Doganos (https://github.com/Ioannis-D)

library(tidyverse)

# Read the data
tuesdata <- tidytuesdayR::tt_load(2023, week = 38)

cran <- tuesdata$cran_20230905 # TidyTuesday's page names it as cran_20230905 but for simplicity I rename it as cran.
package_authors <- tuesdata$package_authors
# cran_graph_nodes <- tuesdata$cran_graph_nodes | not used in my case
# cran_graph_edges <- tuesdata$cran_graph_edges | not used in my case
rm(tuesdata)

# Add the fonts
sysfonts::font_add_google(name = 'JetBrains Mono', family = 'JetBrains')
# The font for the legend, in order to include the dots
sysfonts::font_add(family = "fa-solid",
                   regular = "~/.fonts/fontawesome-free-6.4.0-desktop/otfs/Font Awesome 6 Free-Solid-900.otf")
showtext::showtext_auto()

# ---- DATA MANIPULATION ----

# Extract only the name of the Maintainers, without the email address (and without spaces at the end or " and ' at the beggining or the enc)
maintainers <- stringr::str_extract(cran$Maintainer, '["\']?(.*)["\']?\\s<.*', group = TRUE)

# Create a df with the counts of each maintainer
maintainers_df <- as.data.frame(table(maintainers))

# Count the times authors appear
count_authors <- package_authors %>% count(authorsR)

# Join the two df into one
auth_maint <- merge(x = maintainers_df, y = count_authors, by.x = 'maintainers', by.y = 'authorsR', all = TRUE)

# Rename the columns
names(auth_maint) <- c('Name', 'Maintainer', 'Author')

# Create a new column with the sum of numbers of packages that are authors and maintainers and choose the top 10 (excluding RStudio, R Core Team and Posit Software)
auth_maint <- auth_maint %>% 
  filter(Name != 'Rstudio',
         Name != 'R Core Team',
         Name != 'Posit Software') %>% 
  group_by(Name) %>% 
  mutate(total = sum(Maintainer, Author, na.rm = TRUE)) %>% 
  arrange(desc(total))

auth_maint <- auth_maint[1:10, ]

# ---- PLOT ----

# The colors of R's language logo
green_blue <- "#165caa"
celtic_blue <- "#276dc2"
silver_sand <- "#bfc2c5"
spanish_gray <- "#919198"

# The sizes
size = 3
linewidth = 1

# ---- Main plot ----
maintainers <- ggplot(auth_maint) +
  geom_segment(aes(x = reorder(Name, total, decreasing = TRUE), y = Author , xend = Name, yend = total), color = silver_sand, linewidth = linewidth) +
  geom_point(aes(x = Name, y = total), color = spanish_gray, size = size) +
  geom_text(aes(x = Name, y = total, label = Maintainer, vjust = 0.5, hjust = -0.5), color = spanish_gray)
  

p <- maintainers +
  # The number of packages that are authors
  geom_segment(aes(x = Name, y = 0, xend=Name, yend = Author), color = celtic_blue, linewidth = linewidth) +
  geom_point(aes(x = Name, y = Author, size = 3), color = green_blue, size = size, show.legend = TRUE) +
  geom_text(aes(x = Name, y = Author, label = Author, vjust = 0.5, hjust = -0.5), color = green_blue)
  
# Add a title 
title <- ' language: Top contributors'
p <- p +
  geom_text(aes(x = 5, y = 220, label = title, family = 'JetBrains'), size = 10)

# Creating a "legend" 
dot_icon <-  "<span style='font-family:fa-solid'>&#xf111;</span>"
legends <- tibble(
  x = 9.5,
  y = c(177, 170),
  legend = c(paste0(dot_icon, "  Maintainer"), paste0(dot_icon, "  Author")),
  color = c(spanish_gray, green_blue)
)

# Use the ggtex package to plot the dots from font-awesome
p <- p + 
  ggtext::geom_richtext(data = legends, nudge_x = 0,
                        mapping = aes(
                          x = x, 
                          y = y, 
                          label = legend,
                          family = 'JetBrains',
                          label.colour = NA,),
                        fill = NA,
                        col = legends$color,
                        size = 4)

# Change background, grindlines, etc
p <- p +
  # Start the y axis at 0 without any distance from the names
  scale_y_continuous(limits = c(0, 225), expand = c(0,15)) + 
  ylab("Nº of Packages") + 
  # Theme light and make as default font JetBrains
  theme_light(base_family = 'JetBrains') + 
  theme(panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.border = element_blank(),
        axis.title.x = element_blank(),
        # Increase the names of the contributors
        axis.text.x = element_text(size = 12),
        # As the plot is quite simple and clear, add some margin in order to be more 'centered' and beautiful
        plot.margin = unit(c(0, 1, 1, 1), 'cm'))

# ---- Add the R logo ----
# Read it and transform it in order to be able to be plotted
r_logo <- png::readPNG('./Images/Rlogo.png', native = TRUE)
r_logo <- grid::rasterGrob(r_logo, interpolate = TRUE)

# Add the logo just right next to the title
p <- p + 
  annotation_custom(r_logo, xmin = 3, xmax = 3.3, ymin = 215, ymax = 225)


# ---- Add the photos of the contributors ----

# First, transform each photo to be round

# Create a circle
jpeg(tf <- tempfile(fileext = ".jpeg"), 1000, 1000)
par(mar = rep(0,4), yaxs="i", xaxs="i")
plot(0, type = "n", ylim = c(0,1), xlim=c(0,1), axes=F, xlab=NA, ylab=NA)
plotrix::draw.circle(.5,0.5,.5, col="black")
dev.off()

# Make the path 
path = paste0('./Images/', auth_maint$Name, '.jpeg')

# Modify each foto (with the magick package) to be in a circle and save it 
for (photo in path){
  img <- magick::image_read(photo)
  mask <- magick::image_read(tf)
  mask <- magick::image_scale(mask, as.character(magick::image_info(img)$width))
  image <- magick::image_composite(mask, img, "plus") 
  
  magick::image_write(image, path = str_replace(photo, ".jpeg", "_circle.jpeg"), format = "jpeg")
}


# The first x positions for the first photo 
x1 <- 0.5
x2 <- x1 + 1

# Insert each contributor's photo to the plot
for (contributor in p$data$Name) {
  # Take the path for each contributor
  path = paste0("./Images/", contributor, "_circle.jpeg")
  # Read the image and transform it in order to be able to be plotted
  img <- jpeg::readJPEG(path, native = TRUE)
  img <- grid::rasterGrob(img, interpolate = TRUE)
  
  # Add the photo to the plot
  p <- p +
    annotation_custom(img, xmin = x1, xmax = x2, ymin = -15, ymax = -3)
  
  # Adjust the x positions for the next photo
  x1 <- x1 + 1
  x2 <- x1 + 1
  
}

# Show the plot
p
