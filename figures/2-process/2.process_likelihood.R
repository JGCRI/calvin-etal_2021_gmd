# *******************************************************************
# * Process likelihood data for ensembles
# *
# * Description: this file reads in summary data from the ensemble
# * results and calculates the maximum a-posterior likelihood
# *
# * Author: Kate Calvin
# * Date: July 6, 2020
# *******************************************************************

# =========
# Read in header
source("./header.R")

# =========
# Read in grand tables.
readRDS("./1-data/grand_table_1975.rds") %>%
  rename(region = region.x) %>%
  select(-region.y) ->
  grand_table_1975

readRDS("./1-data/grand_table_recent_1975.rds") %>%
  rename(region = region.x) %>%
  select(-region.y) ->
  grand_table_recent

readRDS("./1-data/grand_table_same.rds") %>%
  rename(region = region.x) %>%
  select(-region.y) ->
  grand_table_same

readRDS("./1-data/grand_table_subsidy.rds") %>%
  rename(region = region.x) %>%
  select(-region.y) ->
  grand_table_subsidy

readRDS("./1-data/grand_table_5yr.rds") %>%
  rename(region = region.x) %>%
  select(-region.y) ->
  grand_table_5yr

readRDS("./1-data/grand_table_1990.rds") %>%
  rename(region = region.x) %>%
  select(-region.y) ->
  grand_table_1990

readRDS("./1-data/grand_table_2005.rds") %>%
  rename(region = region.x) %>%
  select(-region.y) ->
  grand_table_2005


# =========
# Set up shell table to put in the best models. We'll add to this with all of the variants
best_models <- tibble::tibble(expectation.type = "NONE",
                              logit.agforest = 0.00,
                              logit.afnonpast = 0.00,
                              logit.crop = 0.00,
                              share.old1 = 0.00,
                              share.old2 = 0.00,
                              share.old3 = 0.00,
                              linear.years1 = 0.00,
                              linear.years2 = 0.00,
                              linear.years3 = 0.00,
                              objfun = "NONE",
                              landTypeMeanObjFunVal = 0.00,
                              calibration.year = 0.00,
                              comparison.years = "NONE",
                              comparison.landTypes = "NONE",
                              assumption = "NONE")

# =========
# Calculate parameter sets that minimize different objectives, with all land types included
objectiveFunctions <- c("nrms", "rms", "bias", "kge")
for( o in objectiveFunctions) {
  table <- minimize_objective(grand_table_1990, objfun_to_min = o)
  table$calibration.year <- 1990
  table$comparison.years <- "1990-2015"
  table$comparison.landTypes <- "All Crops"
  table$assumption <- "Default"
  
  best_models <- bind_rows(best_models, table)
}

# =========
# Calculate parameter sets that minimize nrms for different combinations of land types
landTypes <- c("Corn", "OilCrop", "Wheat", "OtherGrain", "Crops, excluding PalmFruit", "All dynamic land types")
for( l in landTypes) {
  if( l == "Crops, excluding PalmFruit") {
    table <- minimize_objective(grand_table_1990, objfun_to_min = "nrms", landtypes = c( "Corn", "FiberCrop", "MiscCrop", "OilCrop",
                                                                                         "OtherGrain", "Rice", "Root_Tuber",
                                                                                         "SugarCrop",  "Wheat"))
  } else if( l == "All dynamic land types") {
    table <- minimize_objective(grand_table_1990, objfun_to_min = "nrms", landtypes = c( "Corn", "FiberCrop", "MiscCrop", "OilCrop",
                                                                                         "OtherGrain", "Rice", "Root_Tuber",
                                                                                         "SugarCrop",  "Wheat",
                                                                                         "Grassland", "Shrubland", "Forest"))
  } else {
    table <- minimize_objective(grand_table_1990, objfun_to_min = "nrms", landtypes = c(l))  
  }
  
  table$calibration.year <- 1990
  table$comparison.years <- "1990-2015"
  table$comparison.landTypes <- l
  table$assumption <- "Default"
  
  best_models <- bind_rows(best_models, table)
}

# =========
# Calculate parameter sets that minimize rms for a single crop
table <- minimize_objective(grand_table_1990, objfun_to_min = "rms", landtypes = c("Corn"))
table$calibration.year <- 1990
table$comparison.years <- "1990-2015"
table$comparison.landTypes <- "Corn"
table$assumption <- "Default"

# =========
# Calculate parameter sets that minimize nrms for different model assumptions
table <- minimize_objective(grand_table_same, objfun_to_min = "nrms")
table$calibration.year <- 1990
table$comparison.years <- "1990-2015"
table$comparison.landTypes <- "All Crops"
table$assumption <- "Same Parameters"
best_models <- bind_rows(best_models, table)

table <- minimize_objective(grand_table_subsidy, objfun_to_min = "nrms")
table$calibration.year <- 1990
table$comparison.years <- "1990-2015"
table$comparison.landTypes <- "All Crops"
table$assumption <- "With Subsidy"
best_models <- bind_rows(best_models, table)

table <- minimize_objective(grand_table_5yr, objfun_to_min = "nrms")
table$calibration.year <- 1990
table$comparison.years <- "1990-2015"
table$comparison.landTypes <- "All Crops"
table$assumption <- "5 year timestep"
best_models <- bind_rows(best_models, table)

table <- minimize_objective(grand_table_1975, objfun_to_min = "nrms")
table$calibration.year <- 1975
table$comparison.years <- "1975-2015"
table$comparison.landTypes <- "All Crops"
table$assumption <- "Default"
best_models <- bind_rows(best_models, table)

table <- minimize_objective(grand_table_2005, objfun_to_min = "nrms")
table$calibration.year <- 2005
table$comparison.years <- "2005-2015"
table$comparison.landTypes <- "All Crops"
table$assumption <- "Default"
best_models <- bind_rows(best_models, table)

# =========
# Calculate parameter sets that minimize nrms for recent years only
table <- minimize_objective(grand_table_recent, objfun_to_min = "nrms")
table$calibration.year <- 1975
table$comparison.years <- "1990-2015"
table$comparison.landTypes <- "All Crops"
table$assumption <- "Default"
best_models <- bind_rows(best_models, table)

# =========
# For calibration year and timestep, also calculate optimal parameters for RMS
table <- minimize_objective(grand_table_5yr, objfun_to_min = "rms")
table$calibration.year <- 1990
table$comparison.years <- "1990-2015"
table$comparison.landTypes <- "All Crops"
table$assumption <- "5 year timestep"
best_models <- bind_rows(best_models, table)

table <- minimize_objective(grand_table_1975, objfun_to_min = "rms")
table$calibration.year <- 1975
table$comparison.years <- "1975-2015"
table$comparison.landTypes <- "All Crops"
table$assumption <- "Default"
best_models <- bind_rows(best_models, table)

table <- minimize_objective(grand_table_2005, objfun_to_min = "rms")
table$calibration.year <- 2005
table$comparison.years <- "2005-2015"
table$comparison.landTypes <- "All Crops"
table$assumption <- "Default"
best_models <- bind_rows(best_models, table)

# =========
# Remove dummy row
best_models %>%
  filter(expectation.type != "NONE") ->
  best_models

# =========
# Rename expectation types to match updated gcamland
best_models %>%
  mutate(expectation.type = sub("LaggedCurr", "HybridPerfectAdaptive", expectation.type),
         expectation.type = sub("Lagged", "Adaptive", expectation.type),
         expectation.type = sub("Mixed", "HybridLinearAdaptive", expectation.type)) ->
  best_models

# =========
# Write output
write_csv(best_models, "./2-process/best_models.csv")

best_models[best_models$objfun == "nrms" & best_models$comparison.landTypes == "All Crops" & best_models$calibration.year %in% c(1990, 2005) &
              best_models$assumption == "Default" & grepl("Lagged", best_models$expectation.type), 
            c("calibration.year", "comparison.years", "landTypeMeanObjFunVal", "logit.agforest", "logit.afnonpast", "logit.crop", "share.old1", "share.old2", "share.old3")]


