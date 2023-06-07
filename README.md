# US-embassy-AQI
Analyze air quality index (AQI) data collected by U.S. Embassies around the world

U.S. Embassies have been conducting indepedent air quality monitoring in cities around the world, starting in Beijing in 2008.

This simple R script allows you to read in all raw CSV files in a given folder for a city and then produce plots showing average monthly AQI over time.

In particular, this script focuses on AQI data for Beijing and Delhi. But you can use the function get_monthly_AQI to parse U.S. Embassy AQI data from any city.

Don't forget to begin by setting your working directory and downloading the relevant CSV files from the U.S. Embassy website:
https://www.airnow.gov/international/us-embassies-and-consulates/
