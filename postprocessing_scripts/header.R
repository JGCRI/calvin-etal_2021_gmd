# Load Libraries
library(tidyr)
library(dplyr)
library(ggplot2)
library(readr)
library(gcamland)
theme_set(theme_bw())

# -----------------------------------------------------------------------------
#Function "is not an element of" (opposite of %in%)
'%!in%' <- function( x, y ) !( '%in%'( x, y ) )

# -----------------------------------------------------------------------------
# Save a data frame
save_data <- function(df, fname=paste0(deparse(substitute(df)), ".csv"), outdir, ...) {
  fn <- file.path(outdir, fname)
  print( paste( "Saving", fn ) )
  write_csv(df, fn, ...)
} # save_data

shapes <- c("Corn" = "c", "MiscCrop" = "m", "OilCrop" = "o", "OtherGrain" = "g",
            "Rice" = "r", "Root_Tuber" = "t", "SugarCrop" = "s", "Wheat" = "w",
            "FiberCrop" = "f", "PalmFruit" = "p")


