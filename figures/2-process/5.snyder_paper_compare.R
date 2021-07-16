# *******************************************************************
# * Process NRMS from gcamland and Snyder et al (2017) in 
# * a way that they can be easily compared
# *
# * Author: Kate Calvin
# * Date: August 19, 2020
# *******************************************************************

# =========
# Read in header
source("./header.R")

# =========
# Read in and combine Snyder data
read.csv("./1-data/Snyder2017/NRMSE_GCAM_Hist_Forecast_Bio.csv") %>%
  mutate(Type = "Snyder2017_FYB") ->
  HistForeBio

read.csv("./1-data/Snyder2017/NRMSE_GCAM_History_Bio.csv") %>%
  mutate(Type = "Snyder2017_AYB") ->
  HistBio
          
read.csv("./1-data/Snyder2017/NRMSE_GCAM_Hist_Forecast.csv") %>%
  mutate(Type = "Snyder2017_FY") ->
  HistFore

read.csv("./1-data/Snyder2017/NRMSE_GCAM_History.csv") %>%
  mutate(Type = "Snyder2017_AY") ->
  Hist

bind_rows(HistForeBio, HistBio, HistFore, Hist) %>%
  filter(X == "USA") %>%
  gather(crop, value, -X, -Type) -> 
  snyder.comparison.table

# =========
# Get gcamland data
readRDS("./1-data/grand_table_1990.rds") %>%
  rename(region = region.x) %>%
  select(-region.y) ->
  grand_table_1990

# Determine best model
table <- minimize_objective(grand_table_1990, objfun_to_min = "nrms")
best_allCrop <- table[table$expectation.type == "Lagged", ]

grand_table_1990 %>% 
  filter(expectation.type == best_allCrop$expectation.type[1],
         logit.agforest == best_allCrop$logit.agforest[1],
         logit.afnonpast == best_allCrop$logit.afnonpast[1],
         logit.crop == best_allCrop$logit.crop[1],
         share.old1 == best_allCrop$share.old1[1],
         share.old2 == best_allCrop$share.old2[1],
         share.old3 == best_allCrop$share.old3[1],
         objfun == best_allCrop$objfun[1]) ->
  default_nrms

# Add in NRMS for best model and best crop-specific model
for(c in unique(snyder.comparison.table$crop)) {
  # Add in gcamland data for the default model (minimizing avg NRMS for all crops)
  data.frame(X = "USA",
             Type = "ThisPaper_AllCrops",
             crop = c,
             value = default_nrms$objfunval[default_nrms$land.type == c]) ->
    TEMP
  snyder.comparison.table <- bind_rows(snyder.comparison.table, TEMP)
  
  # Add in gcamland data for the model that minimizes this crops NRMS
  crop_table <- minimize_objective(grand_table_1990, objfun_to_min = "nrms", landtypes = c)
  best_crop <- crop_table[which.min(crop_table$landTypeMeanObjFunVal), ]
  data.frame(X = "USA",
             Type = "ThisPaper_SingleCrop",
             crop = c,
             value = best_crop$landTypeMeanObjFunVal) ->
    TEMP
  snyder.comparison.table <- bind_rows(snyder.comparison.table, TEMP)
}

# ===========
# Save outputs
write.csv(snyder.comparison.table, "./2-process/snyder_comparison_table.csv")
