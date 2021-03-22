# *******************************************************************
# * Summarize outputs
# *
# * Description: this file reads in outputs from all scenarios, 
# * calculates total cropland and the share of cropland. Then,
# * it calculates the max and min across all scenarios.
# *
# * Author: Kate Calvin
# * Date: July 23, 2020
# *******************************************************************

# =========
# Read in header
source("./header.R")

OUTPUT.FOLDER <- "./output_1990/"

# =========
# Read in hindcast data, calculate total cropland 
# and the share of cropland
# Save the min and max in each year only
files <- list.files(OUTPUT.FOLDER, pattern="output_ensemble-")
files <- paste0(OUTPUT.FOLDER, files)

output <- tibble::tibble(year = 0,
                         name = "NONE",
                         min_land = 0,
                         max_land = 0, 
                         min_harvest = 0,
                         max_harvest = 0,
                         min_land_share =0, 
                         max_land_share = 0, 
                         min_harvest_share = 0, 
                         max_harvest_share = 0,
                         min_land_share.wfodder = 0, 
                         max_land_share.wfodder = 0, 
                         min_harvest_share.wfodder = 0, 
                         max_harvest_share.wfodder = 0)
for(f in files) {
  print(f)
  raw.data <- readRDS(f) 
  
  # Calculate total crops -- note Fodder crops are excluded because we don't have them in the FAO data
  raw.data %>%
    filter(name %in% c("Corn", "OilCrop", "Wheat", "OtherGrain", 
                                 "FiberCrop", "MiscCrop", "PalmFruit", "Rice",
                                  "Root_Tuber", "SugarCrop")) %>%
    group_by(scenario, year) %>%
    summarize(harvested.land = sum(harvested.land),
              land.allocation = sum(land.allocation)) %>%
    ungroup() %>%
    mutate(name = "crops_nonfodder") ->
    nofodder
  
  # Calculate total crops -- with Fodder
  raw.data %>%
    filter(name %in% c("Corn", "OilCrop", "Wheat", "OtherGrain", 
                       "FiberCrop", "MiscCrop", "PalmFruit", "Rice",
                       "Root_Tuber", "SugarCrop", "FodderGrass", "FodderHerb")) %>%
    group_by(scenario, year) %>%
    summarize(harvested.land = sum(harvested.land),
              land.allocation = sum(land.allocation)) %>%
    ungroup() %>%
    mutate(name = "crops_nonfodder") ->
    wfodder
  
  # Calculate shares
  raw.data %>%
    select(scenario, name, year, land.allocation, harvested.land) %>%
    filter(name %in% c("Corn", "OilCrop", "Wheat", "OtherGrain", 
                       "FiberCrop", "MiscCrop", "PalmFruit", "Rice",
                       "Root_Tuber", "SugarCrop")) %>%
    rename(crop = name,
           crop.land = land.allocation,
           crop.harvested = harvested.land) %>%
    left_join(nofodder, by=c("scenario", "year")) %>%
    mutate(land.share = crop.land / land.allocation,
           harvest.share = crop.harvested / harvested.land ) %>%
    select(scenario, crop, year, land.share, harvest.share) ->
    land.share
  
  raw.data %>%
    select(scenario, name, year, land.allocation, harvested.land) %>%
    filter(name %in% c("Corn", "OilCrop", "Wheat", "OtherGrain", 
                       "FiberCrop", "MiscCrop", "PalmFruit", "Rice",
                       "Root_Tuber", "SugarCrop", "FodderGrass", "FodderHerb")) %>%
    rename(crop = name,
           crop.land = land.allocation,
           crop.harvested = harvested.land) %>%
    left_join(wfodder, by=c("scenario", "year")) %>%
    mutate(land.share.f = crop.land / land.allocation,
           harvest.share.f = crop.harvested / harvested.land ) %>%
    select(scenario, crop, year, land.share.f, harvest.share.f) %>%
    left_join(land.share, by=c("scenario", "crop", "year")) ->
    land.share
  
  # Merge data sets
  raw.data %>%
    select(scenario, name, year, land.allocation, harvested.land) %>%
    bind_rows(nofodder) %>%
    bind_rows(wfodder) %>%
    left_join(land.share, by=c("scenario", "name" = "crop", "year"))->
    all.data
  
  # Max & Min land for this data set
  all.data %>%
    group_by(year, name) %>%
    summarize(min_land = min(land.allocation), max_land = max(land.allocation),
              min_harvest = min(harvested.land), max_harvest = max(harvested.land),
              min_land_share = min(land.share), max_land_share = max(land.share), 
              min_harvest_share = min(harvest.share), max_harvest_share = max(harvest.share),
              min_land_share.wfodder = min(land.share.f), max_land_share.wfodder = max(land.share.f), 
              min_harvest_share.wfodder = min(harvest.share.f), max_harvest_share.wfodder = max(harvest.share.f)) %>%
    ungroup() ->
    temp_output

  # Merge with prev max/min and recalculate  
  temp_output %>%
    bind_rows(output) %>%
    filter(name != "NONE") %>%
    group_by(year, name) %>%
    summarize(min_land = min(min_land), max_land = max(max_land),
              min_harvest = min(min_harvest), max_harvest = max(max_harvest),
              min_land_share = min(min_land_share), max_land_share = max(max_land_share), 
              min_harvest_share = min(min_harvest_share), max_harvest_share = max(max_harvest_share),
              min_land_share.wfodder = min(min_land_share.wfodder), max_land_share.wfodder = max(max_land_share.wfodder), 
              min_harvest_share.wfodder = min(min_harvest_share.wfodder), max_harvest_share.wfodder = max(max_harvest_share.wfodder)) %>%
    ungroup() ->
    output
}

saveRDS(output, "./output_summarized.rds")