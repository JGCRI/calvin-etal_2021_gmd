# *******************************************************************
# * Combine all grand tables
# *
# * Description: this file reads in gcamland grand tables
# * combines them and then writes the results to a file.
# *
# * Author: Kate Calvin
# * Date: July 21, 2020
# *******************************************************************

# =========
# Read in header and helper functions
source("./header.R")  # libraries, etc.

FOLDER <- "./output_5yr/"

# =========
# Read original grand table
files <- list.files(FOLDER, pattern="grand_table_objective_-")
files <- paste0(FOLDER, files)

i <- 0
for(f in files) {
  print(f)
  if( i == 0 ) {
      output <- readRDS(f)
  } else {
     readRDS(f) %>%
       bind_rows(output) ->
       output
  }
  i <- i + 1
}

# =========
# Write output
saveRDS(output, "./grand_table.rds")

# =========
# Read grand table with recent years only
files <- list.files(FOLDER, pattern="grand_table_objective_recent")
files <- paste0(FOLDER, files)

i <- 0
for(f in files) {
  print(f)
  if( i == 0 ) {
      output <-	readRDS(f)
  } else {
     readRDS(f) %>%
       bind_rows(output) ->
       output
  }
  i <- i + 1
}

# =========
# Write output
saveRDS(output, "./grand_table_recent.rds")

