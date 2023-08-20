This week the data are about spam emails. 

It is the first time I participate in TidyTuesday writing the code in Python and not in R. 

Thanks to [this article](https://www.pythoncharts.com/matplotlib/radar-charts/) by [Alex](https://www.pythoncharts.com/matplotlib/radar-charts/), I was able to learn how to make a radar chart in matplotlib. 
Because it is not possible to subplot a 'polar' chart and other types of chart, I decided to make three different ones and combine them using the 'Pillow library. 

So, first, I created the radar chart, then I moved to the two boxplots and finally I made a new plot with the title and the subtitle of the final plot. 
At the end, I combined all the images to one and this is the result. 

![A chart with the title Characteristics of NO SPAM email. The subtitle says Spam emails tend to be  l o n g e r, mention more the term 'make money' or include symbols like the ! and the $. 
       Below are two plots, on the left a radar chart showing the presence of spetial characters and words in spam and no spam emails and on the right two boxplots each representing spam and no-spam emails' number of caracters- The colors for the SPAM is red and for no spam is green
](https://github.com/Ioannis-D/TidyTuesday/blob/main/2023/2023-week-33/17_08.png)

Spam emails tend to be longer. Apart from that, no-spam emails rarely contain the phrase 'make money' or have large numbers (for example with at least 3 zeros). Of course, exlamation marks and dollar signs are also strong indicators of a spam.
