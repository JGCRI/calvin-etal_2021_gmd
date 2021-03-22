# ***********************************************************************
# * Expected Profit
# * 
# * Calculate expected profit for several different expectation 
# * schemes, with and without subsidies.
# *
# * Author: Kate Calvin
# * Date: April 29, 2020
# *
# ***********************************************************************

source("./header.R")

# First, get all data for profit
yield <- filter(gcamland:::YIELDS.HIST, region == "USA")
price <- filter(gcamland:::get_hindcast_prices(),
                sector %in% c(yield$GCAM_commodity, "Pasture", "Forest", "FodderGrass", "FodderHerb"))
read_csv(system.file("extdata", "./initialization-data/L205.AgCost_ag.csv", package = "gcamland"), skip = 3) %>%
  filter(region == "USA", year == 1975) -> 
  costBase
costTC <- read_csv(system.file("extdata", "./initialization-data/AgCostTechChange.csv", package = "gcamland"), skip = 3)
subsidy <- read_csv(system.file("extdata", "./initialization-data/Crop_Subsidy.csv", package = "gcamland"), skip = 3)

# Next, calculate actual cost by applying tech change
cost <- costBase
for(y in unique(costTC$year)) {
  costBase %>%
    select(-year) %>%
    left_join(filter(costTC, year == y), by=c("region", "AgSupplySector", "AgSupplySubsector", "AgProductionTechnology")) %>%
    mutate(nonLandVariableCost = nonLandVariableCost * (1 + nonLandCostTechChange)) %>%
    select(-nonLandCostTechChange) ->
    TEMP
  
  bind_rows(cost, TEMP) -> cost
}

# Next, extend the price time series back to 1961 (when yields start)
price %>%
  spread(year, price) %>%
  mutate(`1961` = `1970`,
         `1962` = `1970`,
         `1963` = `1970`,
         `1964` = `1970`,
         `1965` = `1970`,
         `1966` = `1970`,
         `1967` = `1970`,
         `1968` = `1970`,
         `1969` = `1970`) %>%
  gather(year, price, -sector) -> 
  price

# Calculate expected price for different expectations
# To start, e[t] = a * y[t-1] + (1 - a)*e[t - 1] for a = 0.5, 0.8, 0.9, 0.95, 1 
price %>%
  filter(year == 1961) %>%
  mutate(eP_a0 = price,
         eP_a0p95 = price,
         eP_a0p9 = price,
         eP_a0p8 = price,
         eP_a0p75 = price,
         eP_a0p5 = price,
         eP_a0p4 = price,
         eP_a0p25 = price) ->
  expectedPrice
for(y in seq(1962, 2015, by=1)) {
  expectedPrice %>%
    filter(year == y - 1) %>%
    select(-year) %>%
    rename(prev_price = price,
           prev_eP_a0 = eP_a0,
           prev_eP_a0p95 = eP_a0p95,
           prev_eP_a0p9 = eP_a0p9,
           prev_eP_a0p8 = eP_a0p8,
           prev_eP_a0p75 = eP_a0p75,
           prev_eP_a0p5 = eP_a0p5,
           prev_eP_a0p4 = eP_a0p4,
           prev_eP_a0p25 = eP_a0p25) ->
    prev_info
  
  price %>%
    filter(year == y) ->
    curr_info
  
  curr_info %>%
    left_join(prev_info, by="sector") %>%
    mutate(eP_a0 = prev_price,
           eP_a0p95 = 0.05*prev_price + 0.95*prev_eP_a0p95,
           eP_a0p9 = 0.1*prev_price + 0.9*prev_eP_a0p9,
           eP_a0p8 = 0.2*prev_price + 0.8*prev_eP_a0p8,
           eP_a0p75 = 0.25*prev_price + 0.75*prev_eP_a0p8,
           eP_a0p5 = 0.5*prev_price + 0.5*prev_eP_a0p5,
           eP_a0p4 = 0.6*prev_price + 0.4*prev_eP_a0p4,
           eP_a0p25 = 0.75*prev_price + 0.25*prev_eP_a0p25) %>%
    select(sector, year, price, eP_a0, eP_a0p95, eP_a0p9, eP_a0p8, eP_a0p75, eP_a0p5, eP_a0p4, eP_a0p25) ->
    TEMP
  
  bind_rows(expectedPrice, TEMP) -> expectedPrice
}

# Calculate expected yield for different expectations
# To start, e[t] = a * y[t-1] + (1 - a)*e[t - 1] for a = 0.5, 0.8, 0.9, 0.95, 1 
yield %>%
  filter(year == 1961) %>%
  mutate(eY_a0 = yield,
         eY_a0p95 = yield,
         eY_a0p9 = yield,
         eY_a0p8 = yield,
         eY_a0p75 = yield,
         eY_a0p5 = yield,
         eY_a0p4 = yield,
         eY_a0p25 = yield) ->
  expectedYield
for(y in seq(1962, 2015, by=1)) {
  expectedYield %>%
    filter(year == y - 1) %>%
    select(-year) %>%
    rename(prev_yield = yield,
           prev_eY_a0 = eY_a0,
           prev_eY_a0p95 = eY_a0p95,
           prev_eY_a0p9 = eY_a0p9,
           prev_eY_a0p8 = eY_a0p8,
           prev_eY_a0p75 = eY_a0p75,
           prev_eY_a0p5 = eY_a0p5,
           prev_eY_a0p4 = eY_a0p4,
           prev_eY_a0p25 = eY_a0p25) ->
    prev_info
  
  yield %>%
    filter(year == y) ->
    curr_info
  
  curr_info %>%
    left_join(prev_info, by="GCAM_commodity") %>%
    mutate(eY_a0 = prev_yield,
           eY_a0p95 = 0.05*prev_yield + 0.95*prev_eY_a0p95,
           eY_a0p9 = 0.1*prev_yield + 0.9*prev_eY_a0p9,
           eY_a0p8 = 0.2*prev_yield + 0.8*prev_eY_a0p8,
           eY_a0p75 = 0.25*prev_yield + 0.75*prev_eY_a0p75,
           eY_a0p5 = 0.5*prev_yield + 0.5*prev_eY_a0p5,
           eY_a0p4 = 0.6*prev_yield + 0.4*prev_eY_a0p4,
           eY_a0p25 = 0.75*prev_yield + 0.25*prev_eY_a0p25) %>%
    select(GCAM_commodity, year, yield, eY_a0, eY_a0p95, eY_a0p9, eY_a0p8, eY_a0p75, eY_a0p5, eY_a0p4, eY_a0p25) ->
    TEMP
  
  bind_rows(expectedYield, TEMP) -> expectedYield
}

# Now, bind all dataframes together and calculate profit
expectedPrice %>%
  mutate(year = as.integer(year)) %>%
  left_join(expectedYield, by=c("year", "sector" = "GCAM_commodity")) %>%
  replace_na(list(region = "USA", yield = 1, eY_a0 = 1, eY_a0p95 = 1, eY_a0p9 = 1, eY_a0p8 = 1, eY_a0p75 = 1, eY_a0p5 = 1, eY_a0p4 = 1, eY_a0p5 = 25)) %>%
  left_join(cost, by=c("year", "sector" = "AgSupplySector")) %>%
  replace_na(list(nonLandVariableCost = 0)) %>%
  mutate(ePr_perf = yield * (price - nonLandVariableCost) * 1e9,
         ePr_a0 = eY_a0 * (eP_a0 - nonLandVariableCost) * 1e9,
         ePr_a0p95 = eY_a0p95 * (eP_a0p95 - nonLandVariableCost) * 1e9,
         ePr_a0p9 = eY_a0p9 * (eP_a0p9 - nonLandVariableCost) * 1e9,
         ePr_a0p8 = eY_a0p8 * (eP_a0p8 - nonLandVariableCost) * 1e9,
         ePr_a0p75 = eY_a0p75 * (eP_a0p75 - nonLandVariableCost) * 1e9,
         ePr_a0p5 = eY_a0p5 * (eP_a0p5 - nonLandVariableCost) * 1e9,
         ePr_a0p4 = eY_a0p4 * (eP_a0p4 - nonLandVariableCost) * 1e9,
         ePr_a0p25 = eY_a0p25 * (eP_a0p25 - nonLandVariableCost) * 1e9)->
  all_data

  all_data %>%
    select(sector, year, ePr_perf, ePr_a0, ePr_a0p95, ePr_a0p9, ePr_a0p8, ePr_a0p75, ePr_a0p5, ePr_a0p4, ePr_a0p25) ->
    profit

  # Save price, yield, and profit in both absolute terms and relative to 1975
  all_data %>%
    select(sector, year, price, yield, ePr_perf) %>%
    filter(year == 1975) %>%
    rename(price1975 = price, yield1975 = yield, profit1975 = ePr_perf) %>%
    select(-year) ->
    data1975
  
  all_data %>%
    select(sector, year, price, yield, ePr_perf) %>%
    rename(profit = ePr_perf) %>%
    left_join(data1975, by=c("sector")) %>%
    mutate(price.ratio = price / price1975,
           yield.ratio = yield / yield1975,
           profit.ratio = profit / profit1975) %>%
    select(-yield1975, -price1975, -profit1975) ->
    data
  

# Write results to file
write.csv(profit, "./3-analyze/gcam_expected_profit.csv", row.names = FALSE)
write.csv(data, "./3-analyze/gcam_priceyieldprofit.csv", row.names = FALSE)