# *******************************************************************
# * Calc share
# *
# * Description: this file reads in GCAM outputs and historical FAO data. 
# * It then calculates the share of cropland for each crop.
# *
# * Author: Kate Calvin
# * Date: July 15, 2020
# *******************************************************************

# =========
# Read in header
source("./header.R")

# =========
# Prepare FAO data
fao_data <- read_csv("./1-data/FAO_Land.csv")
fao_data %>%
  filter(region == "USA") %>%
  rename(fao = area) %>%
  select(-region) ->
  fao_data

fao_data %>%
  group_by(year) %>%
  summarize(fao_total_area = sum(fao)) %>%
  ungroup() ->
  fao_total

fao_data %>%
  left_join(fao_total, by="year") %>%
  mutate(fao_share = fao / fao_total_area) ->
  fao_data

# =========
# Read in outputs
best_output <- read_csv(paste0("./2-process/best_output.csv"))

# =========
# Calculate gcamland shares
best_output %>%
  select(GCAM_commodity, land.allocation, year, scenario, objfun, calibration.year, comparison.years, comparison.landTypes, assumption) %>%
  filter(GCAM_commodity %in% fao_data$GCAM_commodity) %>%
  rename(gcamland = land.allocation) %>%
  na.omit() %>%
  group_by(scenario, year, objfun, calibration.year, comparison.years, comparison.landTypes, assumption) %>%
  summarize(gcamland_total_area = sum(gcamland)) %>%
  ungroup() ->
  gcamland_total

best_output %>%
  select(GCAM_commodity, land.allocation, year, scenario, objfun, calibration.year, comparison.years, comparison.landTypes, assumption) %>%
  filter(GCAM_commodity %in% fao_data$GCAM_commodity) %>%
  rename(gcamland = land.allocation) %>%
  left_join(gcamland_total, by=c("scenario", "year", "objfun", "calibration.year", "comparison.years", "comparison.landTypes", "assumption")) %>%
  mutate(gcamland_share = gcamland / gcamland_total_area) %>%
  left_join(fao_data, by=c("GCAM_commodity", "year")) %>%
  na.omit() ->
  best_output

# =========
# Save outputs
write_csv(best_output, paste0("./3-analyze/output_share.csv"))
