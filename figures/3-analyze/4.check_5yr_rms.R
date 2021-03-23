# *******************************************************************
# * More comparisons between 5 year and 1 year
# *
# * Author: Kate Calvin
# * Date: October 1, 2020
# *******************************************************************

# =========
# Read in header
source("./header.R")

# First, calculate NRMS from the annual model, but only using 5-year timestep output
# This makes it so we can compare the 5-year to the 1-year more directly
read.csv("./2-process/best_models.csv") %>%
  filter(objfun == "rms",
         calibration.year == 1990,
         comparison.years == "1990-2015",
         comparison.landTypes == "All Crops",
         assumption == "Default",
         expectation.type == "Adaptive") ->
  params

scenInfo <- ScenarioInfo(aExpectationType = "Adaptive", 
                         aLaggedShareOld1 = params$share.old1,
                         aLaggedShareOld2 = params$share.old2,
                         aLaggedShareOld3 = params$share.old3,
                         aLogitUseDefault = FALSE,
                         aLogitAgroForest = params$logit.agforest,
                         aLogitAgroForest_NonPasture = params$logit.afnonpast,
                         aLogitCropland = params$logit.crop, 
                         aIncludeSubsidies = FALSE,
                         aScenarioType = "Hindcast1990", 
                         aScenarioName = "Best_Adaptive", 
                         aFileName = "Best_Adaptive", 
                         aOutputDir = "./outputs")
scenOutput <- run_model(scenInfo, aVerbose = TRUE)

scenObjectsEvaluated <- run_objective(list(scenInfo), years = c(1990, 1995, 2000, 2005, 2010, 2015))
GT <- grand_table_objective(aScenarioList = scenObjectsEvaluated)
GT %>%
  rename(region = region.x) %>%
  select(-region.y) ->
  grand_table_Annual5yrIncrements
table_5yr <- minimize_objective(grand_table_Annual5yrIncrements, objfun_to_min = "rms")


# Second, swap parameters.
scenInfo <- ScenarioInfo(aExpectationType = "Adaptive", 
                         aLaggedShareOld1 = params$share.old1,
                         aLaggedShareOld2 = params$share.old2,
                         aLaggedShareOld3 = params$share.old3,
                         aLogitUseDefault = FALSE,
                         aLogitAgroForest = params$logit.agforest,
                         aLogitAgroForest_NonPasture = params$logit.afnonpast,
                         aLogitCropland = params$logit.crop, 
                         aIncludeSubsidies = FALSE,
                         aScenarioType = "Hindcast5yr", 
                         aScenarioName = "Best_Adaptive_1yrParams_5yrModel", 
                         aFileName = "Best_Adaptive_1yrParams_5yrModel", 
                         aOutputDir = "./outputs")
scenOutput <- run_model(scenInfo, aVerbose = TRUE)

read.csv("./2-process/best_models.csv") %>%
  filter(objfun == "rms",
         calibration.year == 1990,
         comparison.years == "1990-2015",
         comparison.landTypes == "All Crops",
         assumption == "5 year timestep",
         expectation.type == "Adaptive") ->
  params

scenObjectsEvaluated <- run_objective(list(scenInfo))
GT <- grand_table_objective(aScenarioList = scenObjectsEvaluated)
GT %>%
  rename(region = region.x) %>%
  select(-region.y) ->
  grand_table
table_5yrMod_1yrParam <- minimize_objective(grand_table, objfun_to_min = "nrms")



scenInfo <- ScenarioInfo(aExpectationType = "Adaptive", 
                         aLaggedShareOld1 = params$share.old1,
                         aLaggedShareOld2 = params$share.old2,
                         aLaggedShareOld3 = params$share.old3,
                         aLogitUseDefault = FALSE,
                         aLogitAgroForest = params$logit.agforest,
                         aLogitAgroForest_NonPasture = params$logit.afnonpast,
                         aLogitCropland = params$logit.crop, 
                         aIncludeSubsidies = FALSE,
                         aScenarioType = "Hindcast1990", 
                         aScenarioName = "Best_Adaptive_5yrParams_1yrModel", 
                         aFileName = "Best_Adaptive_5yrParams_1yrModel", 
                         aOutputDir = "./outputs")
scenOutput2 <- run_model(scenInfo, aVerbose = TRUE)

bind_rows(scenOutput, scenOutput2) -> FiveYrCompare

write_csv(FiveYrCompare, "./3-analyze/fiveYrCompare_output_rms.csv")

scenObjectsEvaluated <- run_objective(list(scenInfo))
GT <- grand_table_objective(aScenarioList = scenObjectsEvaluated)
GT %>%
  rename(region = region.x) %>%
  select(-region.y) ->
  grand_table
table_1yrMod_5yrParam <- minimize_objective(grand_table, objfun_to_min = "nrms")


# Lastly, check whether you get a different set of parameters for RMS than NRMS in 5-year model
readRDS("./1-data/grand_table_5yr.rds") %>%
  rename(region = region.x) %>%
  select(-region.y) ->
  grand_table_5yr
table_rms <- minimize_objective(grand_table_5yr, objfun_to_min = "rms")
table_nrms <- minimize_objective(grand_table_5yr, objfun_to_min = "nrms")


