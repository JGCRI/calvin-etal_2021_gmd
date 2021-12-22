# *******************************************************************
# * Quantify effect of changing logits
# *
# * Description: this file systematically tests the effect of changing
# *              the three logit exponents not explicitly included in
# *              the analysis for their effect on results.
# *
# * Author: Kate Calvin
# * Date: August 23, 2021
# *******************************************************************

# =========
# Read in header
source("./header.R")

# =========
# Read in best models and filter for the default, which will be used for subsequent testing
best_models <- read.csv("./2-process/best_models.csv") 
best_models %>%
  filter(expectation.type == "Adaptive", calibration.year == 1990, comparison.landTypes == "All Crops", assumption == "Default", objfun == "nrms") ->
  default_model

# =========
# Run the default
scenInfo <- ScenarioInfo(aExpectationType = "Adaptive", 
                           aLaggedShareOld1 = default_model$share.old1,
                           aLaggedShareOld2 = default_model$share.old2,
                           aLaggedShareOld3 = default_model$share.old3,
                           aLogitUseDefault = FALSE,
                           aLogitAgroForest = default_model$logit.agforest,
                           aLogitAgroForest_NonPasture = default_model$logit.afnonpast,
                           aLogitCropland = default_model$logit.crop, 
                           aIncludeSubsidies = FALSE,
                           aScenarioType = "Hindcast1990", 
                           aScenarioName = "Default", 
                           aFileName = "Default", 
                           aOutputDir = "./outputs")
run_model(scenInfo, aVerbose = TRUE)

# =========
# Double grassland logit
scenInfo <- ScenarioInfo(aExpectationType = "Adaptive", 
                         aLaggedShareOld1 = default_model$share.old1,
                         aLaggedShareOld2 = default_model$share.old2,
                         aLaggedShareOld3 = default_model$share.old3,
                         aLogitUseDefault = FALSE,
                         aLogitAgroForest = default_model$logit.agforest,
                         aLogitAgroForest_NonPasture = default_model$logit.afnonpast,
                         aLogitCropland = default_model$logit.crop, 
                         aIncludeSubsidies = FALSE,
                         aScenarioType = "Hindcast1990", 
                         aScenarioName = "DoubleGrassShrubLogit", 
                         aFileName = "DoubleGrassShrubLogit", 
                         aOutputDir = "./outputs")
scenInfo$mLogitGrassShrub <- 0.1
run_model(scenInfo, aVerbose = TRUE)

# =========
# Double forest logit
scenInfo <- ScenarioInfo(aExpectationType = "Adaptive", 
                         aLaggedShareOld1 = default_model$share.old1,
                         aLaggedShareOld2 = default_model$share.old2,
                         aLaggedShareOld3 = default_model$share.old3,
                         aLogitUseDefault = FALSE,
                         aLogitAgroForest = default_model$logit.agforest,
                         aLogitAgroForest_NonPasture = default_model$logit.afnonpast,
                         aLogitCropland = default_model$logit.crop, 
                         aIncludeSubsidies = FALSE,
                         aScenarioType = "Hindcast1990", 
                         aScenarioName = "DoubleForestLogit", 
                         aFileName = "DoubleForestLogit", 
                         aOutputDir = "./outputs")
scenInfo$mLogitForestland <- 3.15
run_model(scenInfo, aVerbose = TRUE)

# =========
# Double pasture logit
scenInfo <- ScenarioInfo(aExpectationType = "Adaptive", 
                         aLaggedShareOld1 = default_model$share.old1,
                         aLaggedShareOld2 = default_model$share.old2,
                         aLaggedShareOld3 = default_model$share.old3,
                         aLogitUseDefault = FALSE,
                         aLogitAgroForest = default_model$logit.agforest,
                         aLogitAgroForest_NonPasture = default_model$logit.afnonpast,
                         aLogitCropland = default_model$logit.crop, 
                         aIncludeSubsidies = FALSE,
                         aScenarioType = "Hindcast1990", 
                         aScenarioName = "DoublePastureLogit", 
                         aFileName = "DoublePastureLogit", 
                         aOutputDir = "./outputs")
scenInfo$mLogitPastureland <- 5.4
run_model(scenInfo, aVerbose = TRUE)

# =========
# Combine data, calculate difference from default, and write outputs
bind_rows(readRDS("./outputs/output_Default.rds"),
          readRDS("./outputs/output_DoubleGrassShrubLogit.rds"),
          readRDS("./outputs/output_DoubleForestLogit.rds"),
          readRDS("./outputs/output_DoublePastureLogit.rds")) %>%
  rename(GCAM_commodity = name) %>%
  select(GCAM_commodity, year, land.allocation, scenario) %>%
  spread(scenario, land.allocation) %>%
  mutate(diffForestLogit = 100*(DoubleForestLogit - Default)/Default,
         diffGrassShrubLogit = 100*(DoubleGrassShrubLogit - Default)/Default,
         diffPastureLogit = 100*(DoublePastureLogit - Default)/Default) %>%
  na.omit() %>%
  select(GCAM_commodity, year, diffForestLogit, diffGrassShrubLogit, diffPastureLogit) ->
  logit_output

write_csv(logit_output, paste0("./3-analyze/logit_compare.csv"))

# =========
# Summarize cropland data
logit_output %>%
  filter(GCAM_commodity %in% c( "Corn", "FiberCrop", "MiscCrop", "OilCrop",
                                "OtherGrain", "PalmFruit", "Rice", "Root_Tuber",
                                "SugarCrop",  "Wheat")) ->
  crop_logit_output
print(summary(crop_logit_output))


# =========
# Check effect on total forest
bind_rows(readRDS("./outputs/output_Default.rds"),
          readRDS("./outputs/output_DoubleGrassShrubLogit.rds"),
          readRDS("./outputs/output_DoubleForestLogit.rds"),
          readRDS("./outputs/output_DoublePastureLogit.rds")) %>%
  rename(GCAM_commodity = name) %>%
  filter(GCAM_commodity %in% c("Forest", "UnmanagedForest")) %>%
  group_by(year, scenario) %>%
  summarize(land.allocation = sum(land.allocation)) %>%
  ungroup() %>%
  spread(scenario, land.allocation) %>%
  mutate(diffForestLogit = 100*(DoubleForestLogit - Default)/Default,
         diffGrassShrubLogit = 100*(DoubleGrassShrubLogit - Default)/Default,
         diffPastureLogit = 100*(DoublePastureLogit - Default)/Default) %>%
  na.omit() %>%
  select(year, diffForestLogit, diffGrassShrubLogit, diffPastureLogit) ->
  logit_output_forest
