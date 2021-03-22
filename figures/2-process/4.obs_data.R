# *******************************************************************
# * Plot time series
# *
# * Description: this file reads in GCAM outputs and historical FAO data. 
# * It then plots time series with both for comparison plots.
# *
# * Author: Kate Calvin
# * Date: September 24, 2018
# *******************************************************************

# =========
# Read in header
source("./header.R")

# =========
# Read in data
fao_data <- read_csv("./1-data/FAO_Land.csv")
landcover_data <- read_csv("./1-data/CCI_LandCover.csv")

# =========
# Prepare observation data
fao_data %>%
  group_by(region, year) %>%
  summarize(area = sum(area)) %>%
  ungroup() %>%
  mutate(GCAM_commodity = "Cropland_Harvested") %>%
  bind_rows(fao_data) %>%
  filter(region == "USA") ->
  fao_data

landcover_data %>%
  rename(GCAM_commodity = Land_Type) %>%
  bind_rows(fao_data) %>%
  filter(region == "USA")  ->
  obs_data

# =========
# Calculate 5-year averages in obs data
obs_data %>%
  mutate(year1 = year,
       year = round(year / 5) * 5) %>%
  group_by(region, GCAM_commodity, year) %>%
  summarize(area = mean(area)) %>%
  ungroup() ->
  obs_data_5yr

# =========
# Write data to file
write_csv(obs_data, "./2-process/obs_data.csv")
write_csv(obs_data_5yr, "./2-process/obs_data_5yr.csv")