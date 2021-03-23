# *******************************************************************
# * Run the best models
# *
# * Description: this file reads in the best parameter sets for each
# * expectation type, and then re-runs gcamland in hindcast mode
# * for each of those parameters, saving outputs for future plotting.
# *
# * Author: Kate Calvin
# * Date: September 20, 2018
# *******************************************************************

# =========
# Read in header
source("./header.R")

# =========
# Read in best models and determine the unique combinations
best_models <- read.csv("./2-process/best_models.csv") 
best_models %>%
  distinct(objfun, calibration.year, comparison.years, comparison.landTypes, assumption) ->
  options

# =========
# Loop over types and run gcamland for each
for( o in 1:nrow(options) ) {
  print(o)
  
  # Filter for parameters
  best_models %>%
    filter(objfun == options$objfun[o],
           calibration.year == options$calibration.year[o],
           comparison.years == options$comparison.years[o],
           comparison.landTypes == options$comparison.landTypes[o],
           assumption == options$assumption[o]) ->
    temp_best_models
  
  # Set flag for subsidy
  if ( temp_best_models$assumption[1] == "With Subsidy") {
    includeSubs <- TRUE
  } else {
    includeSubs <- FALSE  
  }
  
  # Determine model type
  if ( temp_best_models$assumption[1] == "5 year timestep" ) {
    scenType <- "Hindcast5yr"
  } else if ( temp_best_models$calibration.year[1] == 1990 ) {
    scenType <- "Hindcast1990"  
  } else if ( temp_best_models$calibration.year[1] == 2005 ) {
    scenType <- "Hindcast2005"  
  } else {
    scenType <- "Hindcast"
  }

  # =========
  # Run perfect expectations model
  params <- filter(temp_best_models, expectation.type == "Perfect")
  scenInfo <- ScenarioInfo(aExpectationType = "Perfect", aLogitUseDefault = FALSE,
                           aLogitAgroForest = params$logit.agforest,
                           aLogitAgroForest_NonPasture = params$logit.afnonpast,
                           aLogitCropland = params$logit.crop, 
                           aIncludeSubsidies = includeSubs,
                           aScenarioType = scenType, 
                           aScenarioName = "Best_Perfect", 
                           aFileName = "Best_Perfect", 
                           aOutputDir = "./outputs")
  run_model(scenInfo, aVerbose = TRUE)
  
  # =========
  # Run adaptive expectations model
  params <- filter(temp_best_models, expectation.type == "Adaptive")
  scenInfo <- ScenarioInfo(aExpectationType = "Adaptive", 
                           aLaggedShareOld1 = params$share.old1,
                           aLaggedShareOld2 = params$share.old2,
                           aLaggedShareOld3 = params$share.old3,
                           aLogitUseDefault = FALSE,
                           aLogitAgroForest = params$logit.agforest,
                           aLogitAgroForest_NonPasture = params$logit.afnonpast,
                           aLogitCropland = params$logit.crop, 
                           aIncludeSubsidies = includeSubs,
                           aScenarioType = scenType, 
                           aScenarioName = "Best_Adaptive", 
                           aFileName = "Best_Adaptive", 
                           aOutputDir = "./outputs")
  run_model(scenInfo, aVerbose = TRUE)
  
  # =========
  # Run linear expectations model
  params <- filter(temp_best_models, expectation.type == "Linear")
  scenInfo <- ScenarioInfo(aExpectationType = "Linear", 
                           aLinearYears1 = params$linear.years1,
                           aLinearYears2 = params$linear.years2,
                           aLinearYears3 = params$linear.years3,
                           aLogitUseDefault = FALSE,
                           aLogitAgroForest = params$logit.agforest,
                           aLogitAgroForest_NonPasture = params$logit.afnonpast,
                           aLogitCropland = params$logit.crop, 
                           aIncludeSubsidies = includeSubs,
                           aScenarioType = scenType, 
                           aScenarioName = "Best_Linear", 
                           aFileName = "Best_Linear", 
                           aOutputDir = "./outputs")
  run_model(scenInfo, aVerbose = TRUE)
  
  # =========
  # Run hybrid linear adaptive expectations model
  params <- filter(temp_best_models, expectation.type == "HybridLinearAdaptive")
  scenInfo <- ScenarioInfo(aExpectationType = "HybridLinearAdaptive", 
                           aLinearYears1 = params$linear.years1,
                           aLinearYears2 = params$linear.years2,
                           aLinearYears3 = params$linear.years3,
                           aLaggedShareOld1 = params$share.old1,
                           aLaggedShareOld2 = params$share.old2,
                           aLaggedShareOld3 = params$share.old3,
                           aLogitUseDefault = FALSE,
                           aLogitAgroForest = params$logit.agforest,
                           aLogitAgroForest_NonPasture = params$logit.afnonpast,
                           aLogitCropland = params$logit.crop, 
                           aIncludeSubsidies = includeSubs,
                           aScenarioType = scenType, 
                           aScenarioName = "Best_HybridLinearAdaptive", 
                           aFileName = "Best_HybridLinearAdaptive", 
                           aOutputDir = "./outputs")
  run_model(scenInfo, aVerbose = TRUE)
  
  
  # =========
  # Summarize best models and write outputs
  bind_rows(readRDS("./outputs/output_Best_Adaptive.rds"),
            readRDS("./outputs/output_Best_Linear.rds"),
            readRDS("./outputs/output_Best_Perfect.rds"),
            readRDS("./outputs/output_Best_HybridLinearAdaptive.rds")) %>%
    rename(GCAM_commodity = name) ->
    temp_output
  
  # ========
  # Add in identifying information
  temp_output %>%
    mutate(objfun = options$objfun[o],
           calibration.year = options$calibration.year[o],
           comparison.years = options$comparison.years[o],
           comparison.landTypes = options$comparison.landTypes[o],
           assumption = options$assumption[o]) ->
    temp_output
  
  # ========
  # Combine data
  if(o == 1) {
    best_output <- temp_output
  } else {
    best_output <- bind_rows(best_output, temp_output)
  }
 
  
}
write_csv(best_output, paste0("./2-process/best_output.csv"))