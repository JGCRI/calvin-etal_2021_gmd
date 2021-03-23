# ***********************************************************************
# * Correlations between profit and land use by crop
# * 
# * Calculate the correlations between historical expected 
# * profit and land, using different ways of calculating expected profit
# * and with and without subsidies.
# *
# * Author: Kate Calvin
# * Date: April 30, 2020
# *
# ***********************************************************************

source("header.R")

# First, get all data for land and profit
gcam_profit <- read_csv("./3-analyze/gcam_expected_profit.csv")
fao_land <- read_csv("./1-data/FAO_Land.csv")

# Merge Data sets
gcam_profit %>%
  rename(Commodity = sector,
         Year = year) %>%
  gather(Expectation, Profit, -Commodity, -Year) ->
  profit

fao_land %>%
  filter(region == "USA") %>%
  select(year, GCAM_commodity, area) %>%
  rename(Commodity = GCAM_commodity,
         Land = area,
         Year = year) ->
  land

profit %>%
  left_join(land, by=c("Commodity", "Year")) %>%
  na.omit() ->
  all_data

time.periods <- c("1975-2015", "1975-1990", "1990-2015", "1990-2000", "2000-2015")

# Loop through and compute correlations, with all crops in the mix
correlation <- tibble::tibble(time.period = "TEMP",
                              expectation = "TEMP",
                              crop = "TEMP",
                              corr_coef = -100)
for(t in time.periods) {
  for(e in unique(all_data$Expectation)) {
    for(c in unique(all_data$Commodity)) {
      all_data %>%
        filter(Expectation == e,
               Commodity == c) ->
        some_data
      
      if(t == "1975-2015") {
        some_data %>%
          filter(Year >= 1975) ->
          some_data
      } else if (t == "1975-1990") {
        some_data %>%
          filter(Year %in% 1975:1990) ->
          some_data
      } else if (t == "1990-2000") {
        some_data %>%
          filter(Year %in% 1990:2000) ->
          some_data
      } else if (t == "1990-2015") {
        some_data %>%
          filter(Year %in% 1990:2015) ->
          some_data
      } else if (t == "2000-2015") {
        some_data %>%
          filter(Year > 2000) ->
          some_data
      }
      
      if(nrow(some_data) > 0) {
        corr_coef <- cor(some_data$Land, some_data$Profit, method="pearson")
        
        TEMP <- tibble::tibble(time.period = t,
                               expectation = e,
                               crop = c,
                               corr_coef = corr_coef)
        
        bind_rows(correlation, TEMP) -> correlation
      }
    }
  }
}
# Remove dummy row
correlation %>%
  filter(expectation != "TEMP") ->
  correlation

write.csv(correlation, "./3-analyze/gcam_corr_coef.csv")
