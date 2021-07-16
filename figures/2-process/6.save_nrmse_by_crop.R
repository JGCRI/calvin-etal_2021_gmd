# *******************************************************************
# * Save crop-specific NRMSE 
# *
# * Description: this file reads in summary data from the ensemble
# * results and filters for NRMSE in the Default model
# *
# * Author: Kate Calvin
# * Date: June 16, 2021
# *******************************************************************

# =========
# Read in header
source("./header.R")

# =========
# Read in grand tables.
readRDS("./1-data/grand_table_1990.rds") %>%
  rename(region = region.x) %>%
  select(-region.y) ->
  grand_table_1990

# =========
# Find best models
table <- minimize_objective(grand_table_1990, objfun_to_min = "nrms")
table$best <- TRUE

# =========
# Match information from full table
grand_table_1990 %>%
  left_join(table, by=c("expectation.type", "logit.agforest", "logit.afnonpast",
                                   "logit.crop" , "share.old1",  "share.old2" , "share.old3",
                                   "linear.years1", "linear.years2", "linear.years3", "objfun")) %>%
  filter(best == TRUE) %>%
  select(land.type, expectation.type, objfunval, landTypeMeanObjFunVal) ->
  crop_nrmse

# =========
# Rename expectation types to match updated gcamland
crop_nrmse %>%
  mutate(expectation.type = sub("LaggedCurr", "HybridPerfectAdaptive", expectation.type),
         expectation.type = sub("Lagged", "Adaptive", expectation.type),
         expectation.type = sub("Mixed", "Hybrid Linear Adaptive", expectation.type)) ->
  crop_nrmse

# =========
# Write output
write_csv(crop_nrmse, "./2-process/crop_nrmse.csv")
