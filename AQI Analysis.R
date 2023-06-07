library(datetime)
library(tidyverse)
library(lubridate)
library(data.table)

# Function: input a folder with csv files of AQI data for a city and output a data frame with average monthly AQI
get_monthly_AQI <- function(folder) {
  
  # Read in all data into a single data frame
  df_raw <- 
    list.files(path = folder, pattern = "*.csv", full.names = TRUE) %>% 
    map_df(~fread(.))
  
  # Clean up the data
  df <- 
    df_raw %>%
    select(Year, Month, Day, Hour, AQI) %>% # Drop all columns except Year, Month, Day, Hour
    filter(AQI >= 0) %>% # Drop rows with AQI less than 0
    filter(Year < 2023) # Drop one row with year 2023
  
  # Create new "date" column using Year, Month, Day
  df %<>%
    unite(date, Year, Month, Day, sep = "-") %>%
    mutate(date = as_date(date))
  
  # Get average daily AQI
  df %<>%
    group_by(date) %>%
    summarise(AQI = mean(AQI))
  
  # Create new df for monthly data with unique identifier for year-month
  df_monthly <-
    df %>%
    mutate(year = year(date), month = month(date), day = 1) %>%
    unite(date, year, month, day, sep = "-", remove = FALSE) %>%
    mutate(date = as_date(date))
  
  # Get average monthly AQI
  df_monthly %<>%
    group_by(date) %>%
    summarise(AQI = mean(AQI)) %>%
    arrange(date)
  
  return(df_monthly)
}

# Run get_monthly_AQI function for Beijing data and Delhi data separately
beijing_aqi <- get_monthly_AQI("data/beijing/")
delhi_aqi <- get_monthly_AQI("data/delhi")
  
# Plot Beijing AQI
ggplot(data = beijing_aqi, aes(date, AQI)) +
  geom_line() +
  theme_classic() +
  theme(
    axis.title = element_blank(),
    panel.grid.major = element_line(color = "#eeeeee")
    ) +
  scale_x_date(date_breaks = "year" , date_labels = "%Y") +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 250)) +
  labs(
    title = "Beijing Air Quality (AQI)",
    subtitle = "Data source: U.S. Embassy in Beijing"
    ) +
  theme(
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  )

ggsave("beijing_aqi.png", width = 6, height = 4)

# Plot Delhi AQI
ggplot(data = delhi_aqi, aes(date, AQI)) +
  geom_line() +
  theme_classic() +
  theme(
    axis.title = element_blank(),
    panel.grid.major = element_line(color = "#eeeeee")
  ) +
  scale_x_date(date_breaks = "year" , date_labels = "%Y") +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 400)) +
  labs(
    title = "Delhi Air Quality (AQI)",
    subtitle = "Data source: U.S. Embassy in Delhi"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  )

ggsave("delhi_aqi.png", width = 6, height = 4)

# Create new data frames for Beijing and Delhi with new column names for AQI
beijing_aqi_modified <-
  beijing_aqi %>%
  rename("beijing_AQI" = "AQI")

delhi_aqi_modified <-
  delhi_aqi %>%
  rename("delhi_AQI" = "AQI")

# Merge Beijing and Delhi into a single data frame
beijing_delhi_aqi <- left_join(beijing_aqi_modified, delhi_aqi_modified, by = "date")

ggplot(data = beijing_delhi_aqi) +
  geom_line(aes(x = date, y = beijing_AQI), color = "red") +
  geom_line(aes(x = date, y = delhi_AQI), color = "blue") +
  theme_classic() +
  theme(
    axis.title = element_blank(),
    panel.grid.major = element_line(color = "#eeeeee")
  ) +
  scale_x_date(date_breaks = "year" , date_labels = "%Y") +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 400)) +
  labs(
    title = "Beijing vs. Delhi Air Quality (AQI)",
    subtitle = "Data source: U.S. Embassy"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  )

ggsave("beijing_delhi_aqi.png", width = 6, height = 4)



