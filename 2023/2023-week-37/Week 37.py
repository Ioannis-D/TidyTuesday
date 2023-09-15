# TidyTuesday | Week 37, Year 2023 | Creator: Ioannis Doganos (https://github.com/Ioannis-D)

# Import the necessary libraries
import pandas as pd
import numpy as np
import math

import seaborn as sns
import matplotlib.pyplot as plt

import wget
import os
from pathlib import Path 

import cairosvg 
from reportlab.graphics import renderPM
from PIL import Image

from matplotlib.lines import Line2D
from matplotlib.patches import Wedge
from matplotlib.offsetbox import OffsetImage, AnnotationBbox

# ------DATA MANIPULATION---------

# Read the data
all_countries = pd.read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-09-12/all_countries.csv')
country_regions = pd.read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-09-12/country_regions.csv')

# Only select the subcategory 'Sleep & bedrest' and the columns needed (country_iso3 & hourPerDayCombined)
all_countries = all_countries[all_countries['Subcategory'] == 'Sleep & bedrest'][['country_iso3', 'hoursPerDayCombined']]

# Insert the country's name and the region for each observation 
sleep = all_countries.merge(country_regions, on='country_iso3', how='left')

# Only choose the columns 'country_iso3', 'country_iso2' 'country_name', 'region_name' and 'hoursPerDayCombined
sleep = sleep[['country_iso3', 'country_iso2', 'country_name', 'region_name', 'hoursPerDayCombined']]

# Sort by 'hoursPerDayCombined'
sleep.sort_values(by = ['hoursPerDayCombined'], ignore_index=True, inplace=True)

#drop empty values
sleep.replace('', np.nan, inplace=True)
sleep.dropna(axis=0, inplace=True)

print(pd.unique(sleep['region_name']))
# ['Eastern Asia' 'Central America' 'Caribbean' 'Western Africa'
# 'Northern Europe' 'South America' 'Western Pacific Islands'
# 'South-eastern Asia' 'Northern Africa' 'Southern Europe' 'Western Europe'
# 'Central Asia' 'Eastern Europe' 'Eastern Africa'
# 'Australia and New Zealand' 'Southern Asia' 'Northern America'
# 'Western Asia' 'Southern Africa' 'Middle Africa']

# Reduce the categories
sleep.replace(regex={
    r'.*Asia': 'Asia',
    r'.*America|.*Caribbean' :'America',
    r'.*Africa' : 'Africa',
    r'.*Europe' : 'Europe'
}, inplace=True)

print(pd.unique(sleep['region_name']))
# ['Asia' 'America' 'Africa' 'Europe' 'Western Pacific Islands'
# 'Australia and New Zealand']

# In order to get the flags, the iso2 codes have to be lower-case
sleep['country_iso2'] = sleep['country_iso2'].str.lower()

# ------PLOT---------

# Download the flags from https://github.com/HatScripts/circle-flags and save them to the flags directory
for iso2 in pd.unique(sleep['country_iso2']):
    image = iso2 + ".svg"
    url = "https://raw.githubusercontent.com/HatScripts/circle-flags/gh-pages/flags/" + image
    
    path = "./flags"
    fullpath = os.path.join(path, image)
    try:
        wget.download(url, out=fullpath)
    except:
        print(f"Could not find image {image}\n")
        print(f"The country is: {sleep[sleep['country_iso2'] == iso2]['country_name']}")
        continue

# Transform the flags from svg to png
for iso2 in pd.unique(sleep['country_iso2']):
    path = "./flags"
    
    svg = iso2 + ".svg"
    png = iso2 + ".png"
    
    fullpath_svg = os.path.join(path, svg)
    fullpath_png = os.path.join(path, png)
    
    try:
        cairosvg.svg2png(url=fullpath_svg, write_to=fullpath_png)
    except Exception as e:
        print(f"for {iso2}, Exception: {e}")

# Taken from https://towardsdatascience.com/how-to-create-a-polar-histogram-with-python-and-matplotlib-9e266c22c0fa

# Create a base style by defining the background, text color, and font
background_color = "#252B48" #"#F8F1F1"
text_color = "#f8f8ff"

sns.set_style({
    "axes.facecolor": background_color,
    "figure.facecolor": background_color,
    "text.color": text_color,
})

# Global settings
START_ANGLE = 100 # At what angle to start drawing the first wedge
END_ANGLE = 450 # At what angle to finish drawing the last wedge
SIZE = (END_ANGLE - START_ANGLE) / len(sleep) # The size of each wedge
PAD = 0.2 * SIZE # The padding between wedges

INNER_PADDING = 1.1 * sleep.hoursPerDayCombined.min() #creates distance between the origo and the start of each wedge. It opens a space in the middle of the graph where a title can be added
LIMIT = (INNER_PADDING + sleep.hoursPerDayCombined.max()) * 1.3 # Limit of the axes

# A function, which draws a wedge based on angles, length, bar length, and color.
def draw_wedge(ax, start_angle, end_angle, length, bar_length, color):
    ax.add_artist(
        Wedge((0, 0),
            length, start_angle, end_angle,
            color=color, width=bar_length
        )
    )

# A function which adds color to the bars
def color(region):
    if region == "Asia":
        return "#E19898"
    elif region == "America":
        return "#A2678A"
    elif region == "Africa":
        return "#4D3C77"
    elif region == "Europe":
        return "#3F1D38"
    elif region == "Western Pacific Islands":
        return "#EEE2DE"
    else:
        return "#183D3D"

# A function that defines the position
def get_xy_with_padding(length, angle, padding):
    x = math.cos(math.radians(angle)) * (length + padding)
    y = math.sin(math.radians(angle)) * (length + padding)
    return x, y

# A function which adds the flags
def add_flag(ax, x, y, iso2, zoom, rotation):
    image = iso2 + ".png"
    path = "./flags"
    fullpath = os.path.join(path, image)
    
    flag = Image.open(fullpath)
    flag = flag.rotate(rotation if rotation > 270 else rotation - 180)
    im = OffsetImage(flag, zoom=zoom, interpolation="lanczos", resample=True, visible=True)

    ax.add_artist(AnnotationBbox(
        im, (x, y), frameon=False,
        xycoords="data",
    ))

# A function which adds the text
def add_text(ax, x, y, country, score, angle):
    if angle < 270:
        text = "{} ({})".format(country, score)
        ax.text(x, y, text, fontsize=19, rotation=angle-180, ha="right", va="center", rotation_mode="anchor")
    else:
        text = "({}) {}".format(score, country)
        ax.text(x, y, text, fontsize=19, rotation=angle, ha="left", va="center", rotation_mode="anchor")

# A function to add the legend
def add_legend(labels, colors, title):
    lines = [
        Line2D([], [], marker='o', markersize=24, linewidth=0, color=c) 
        for c in colors
    ]

    plt.legend(
        lines, labels,
        fontsize=18, loc="upper left", alignment="left",
        borderpad=1.3, edgecolor="#E4C9C9", labelspacing=1,
        facecolor=background_color, framealpha=1, borderaxespad=1,
        title=title, title_fontsize=20,
    )

fig, ax = plt.subplots(nrows=1, ncols=1, figsize=(40, 40))
ax.set(xlim=(-LIMIT, LIMIT), ylim=(-LIMIT, LIMIT))

for i, row in sleep.iterrows():
    bar_length = row.hoursPerDayCombined
    name = row.country_name
    length = bar_length + INNER_PADDING
    start = 100 + i*SIZE + PAD
    end = 100 + (i+1)*SIZE
    angle = (end + start) / 2
    
    # Create variables
    angle = (end + start) / 2
    flag_zoom = 0.0022 * length
    flag_x, flag_y = get_xy_with_padding(length, angle, 0.03 * length)
    text_x, text_y = get_xy_with_padding(length, angle, 0.05 * length)
    
    # Add functions
    draw_wedge(ax, start, end, length, bar_length, color(row.region_name))
    add_flag(ax, flag_x, flag_y, row.country_iso2, flag_zoom, angle)
    add_text(ax, text_x, text_y, row.country_name, row.hoursPerDayCombined, angle)
    
# Add general functions
add_legend(
    labels=["Asia", "America", "Africa", "Europe", "Western Pacific Islands", "Australia and New Zealand"],
    colors=["#E19898", "#A2678A", "#4D3C77", "#3F1D38", "#EEE2DE", "#183D3D"],
    title="Region\n"
)

# Add the title
plt.title(
  "How many hours,we stay in bed,,sleeping or not".replace(",", "\n"), 
  x=0.5, y=0.54, va="center", ha="center", 
  fontsize=64, linespacing=1.5
)

sleeping_icon = Image.open("icons8-bed-100.png")
im = OffsetImage(sleeping_icon, zoom=2, interpolation="lanczos", resample=True, visible=True)
ax.add_artist(AnnotationBbox(
    im, (0.5, -4), frameon=False,
    xycoords="data"))

plt.axis("off")
plt.tight_layout()

plt.savefig('Week_37.png')
