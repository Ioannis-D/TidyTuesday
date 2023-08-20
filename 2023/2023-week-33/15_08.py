# Import the libraries
import pandas as pd
import numpy as np
from math import pi

import matplotlib.pyplot as plt
import matplotlib.font_manager as fm

# Load custom fonts
import matplotlib as mpl
from pathlib import Path

arbilpath = Path(mpl.get_data_path(), "./fonts/ttf/AbrilFatface.ttf")
alfaslabpath = Path(mpl.get_data_path(), "./fonts/ttf/AlfaSlabOne-Regular.ttf")
handjetpath = Path(mpl.get_data_path(), "./fonts/ttf/Handjet.ttf")
handjetlightpath = Path(mpl.get_data_path(), "./fonts/ttf/Handjet-Light.ttf")

# Read the data
spam = pd.read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-08-15/spam.csv')

# Make a new df with the presence of symbols in both categories
percentages = pd.DataFrame(index = ['y', 'n'])
for column in spam.columns[1:-1]:
    percentages[column] = round((spam[spam[column] > 0].groupby('yesno')[column].count() / spam.groupby('yesno')[column].count())*100, 2)


#---- PLOT ----
# The colors
green_general = '#00f275'
green_fill = '#26ff8f'
green_whiskers = '#00bf5c'
green_outliers = '#00A550'
green_median = '#008d44'

red_general = '#d22730'
red_fill = '#fb0700'
red_whiskers = '#CD5C5C'
red_outliers = '#CD5C5C'
red_median = '#ff4e49'

labels_color = '#F5FEFD'

title_color = '#F5FEFD'

background_color = '#0C0404'

# ---- Radar Chart ----
# Taken from: https://www.pythoncharts.com/matplotlib/radar-charts/

labels = ['$', '!', 'money', '3 zeros', 'make']

# The number of variables to be shown
num_vars = len(labels)

# Split the circle into even parts and save the angles
# so we know where to put each axis.
angles = np.linspace(0, 2 * np.pi, num_vars, endpoint=False).tolist()

# The plot is a circle, so we need to "complete the loop"
# and append the start value to the end.
angles += angles[:1]
labels += labels[:1]

# ax = plt.subplot(polar=True)
fig1, ax1 = plt.subplots(figsize=(12, 12), subplot_kw=dict(polar=True))

# Helper function to plot each spam and no-spam email on the radar chart.
def add_to_radar(yesno, color):
    values = percentages.loc[yesno].tolist()
    values += values[:1]
    # Draw the outline of the data.
    ax1.plot(angles, values, color=color, linewidth=1, label=yesno)
    # Fill it in.
    ax1.fill(angles, values, color=color, alpha=0.25)

# Add each category to the chart.
add_to_radar('y', red_general)
add_to_radar('n', green_general)


# Fix axis to go in the right order and start at 12 o'clock.
ax1.set_theta_offset(np.pi / 2)
ax1.set_theta_direction(-1)

# Draw axis lines for each angle and label.
ax1.set_thetagrids(np.degrees(angles), labels)

# Go through labels and adjust alignment based on where
# it is in the circle.
for label, angle in zip(ax1.get_xticklabels(), angles):
    if angle in (0, np.pi):
        label.set_horizontalalignment('center')
    elif 0 < angle < np.pi:
        label.set_horizontalalignment('left')
    else:
        label.set_horizontalalignment('right')

# Ensure radar goes from 0 to 100.
ax1.set_ylim(0, 100)

# Set position of y-labels (0-100) to be in the middle
# of the first two axes.
ax1.set_rlabel_position(180 / num_vars)

# Add some custom styling.
# Change the color and the size of the tick labels.
ax1.tick_params(colors=labels_color, labelsize = 30)
# Make the y-axis (0-100) labels smaller.
ax1.tick_params(axis='y', labelsize=10)
# Change the color of the circular gridlines.
ax1.grid(color='#555555', alpha = 0.6)
# Change the color of the outermost gridline (the spine).
ax1.spines['polar'].set_color('#0C0404')
# Change the background color inside the circle itself.
ax1.set_facecolor('#1B1B1B')
# Change the background color of the plot
fig1.patch.set_facecolor(background_color)

# Lastly, give the chart a title
ax1.set_title('Presence of symbols/words', y=1.1, color = labels_color, size = 30)

# Save the plot as an image
plt.savefig('RadarChart.png')


# ---- The boxplots ----

spam_email = spam[(spam['yesno'] == 'y') & (spam['crl.tot'] < 5000)]
no_spam_email = spam[(spam['yesno'] == 'n') & (spam['crl.tot'] < 5000)]


fig2, (ax2, ax3) = plt.subplots(1, 2, sharex=True, sharey=True, figsize=(12, 12))

# ----The boxplot for no-spam----
# The attributes for the coloring of the boxplot
boxprops = dict(color=green_general, facecolor=green_fill, linewidth=1, alpha = 0.8)
flierprops = dict(marker='o', markersize=6, markeredgecolor=green_outliers)
whiskerprops=dict(color=green_whiskers)
capprops=dict(color=green_whiskers)
medianprops=dict(color=green_median)

# The boxplot
ax2.boxplot(no_spam_email['crl.tot'], widths=0.4, patch_artist=True, 
            boxprops=boxprops, 
            flierprops=flierprops,
            whiskerprops=whiskerprops,
            capprops=capprops,
            medianprops=medianprops)

# # Remove the x axis
ax2.xaxis.set_visible(False)
# Remove the spines
ax2.spines[['top', 'right', 'bottom', 'left']].set_visible(False)
# Change the color of the labels
ax2.tick_params(axis='y', labelcolor=labels_color)
# Change the fontsize of the ticks
plt.rc('ytick',  labelsize = 15)
# Change the background color
ax2.set_facecolor(background_color)

# ----The boxplot for spam----
# The attributes for the coloring of the boxplot
boxprops = dict(color=red_general, facecolor=red_fill, linewidth=1, alpha = 0.8)
flierprops = dict(marker='o', markersize=6, markeredgecolor=red_outliers)
whiskerprops=dict(color=red_whiskers)
capprops=dict(color=red_whiskers)
medianprops=dict(color=red_median)

# The boxplot
ax3.boxplot(spam_email['crl.tot'], widths=0.4, patch_artist=True, 
            boxprops=boxprops, 
            flierprops=flierprops,
            whiskerprops=whiskerprops,
            capprops=capprops,
            medianprops=medianprops)

# Remove the axis
ax3.xaxis.set_visible(False)
ax3.yaxis.set_visible(False)
# Remove the spines
ax3.spines[['top', 'right', 'bottom', 'left']].set_visible(False)
# Change the background color
ax3.set_facecolor(background_color)

# Adjust the position of ax3 next to ax2
ax3_position = ax3.get_position()
ax2_position = ax2.get_position()
ax3.set_position([ax2_position.x1, ax3_position.y0, ax3_position.width, ax3_position.height])

# Change the figure's background to mach the plots' background
fig2.patch.set_facecolor(background_color)

# Put a title
plt.title('Number of characters', color = labels_color, fontsize = 30, x = 0.055, y = 1.1)

# Save the plot as an image
plt.savefig('Boxplots.png')


# ---- 'TITLE' and 'SUBTITLE' ----
fig3, ax4 = plt.subplots(figsize = (12,3.5))

ax4.text(0.5, 0.9, 'Characteristics of', fontsize = 30, color = labels_color, ha = 'center', font = arbilpath)
ax4.text(0.44, 0.41, 'NO ', fontsize = 100, color = green_general, ha = 'right', font = alfaslabpath)
ax4.text(0.44, 0.41, '$PAM',fontsize = 100, color = red_general, ha = 'left', font = alfaslabpath)
ax4.text(0.5, 0.25, 'e-mails', fontsize = 30, color = labels_color, ha = 'center', font = arbilpath)
ax4.text(0.5, 0.08, '''Spam emails tend to be  l o n g e r,
mention more the term "make money" or include symbols like the ! and the $''',
        fontsize = 20, color = labels_color, ha = 'center', va = 'center', font = handjetlightpath)
# Remove the axis
ax4.xaxis.set_visible(False)
ax4.yaxis.set_visible(False)
# Remove the spines
ax4.spines[['top', 'right', 'bottom', 'left']].set_visible(False)
# Change the background color
ax4.set_facecolor(background_color)

fig3.patch.set_facecolor(background_color)

# Save the plot as animage
plt.savefig('Title.png')

# ---- MERGING THE IMAGES ----

from PIL import Image

# Open up of images
title = Image.open("Title.png")
boxplots = Image.open("Boxplots.png")
radar = Image.open("RadarChart.png")
title.size
boxplots.size
radar.size
title_size = title.resize((4000, 900))
boxplots_size = boxplots.resize((2000, 1800))
radar_size = radar.resize((2000, 1800))

# Create a new image and pasting the images
img = Image.new("RGB", (4000, 2700), background_color)

# Paste the 'title'
img.paste(title_size, (0, 0))
# Paste the boxplots
img.paste(boxplots_size, (2300, 1000))
#Paste the radar chart
img.paste(radar_size, (0, 1000))

# Save and show the final image
img.show()
img.save('17_08.png')
