# Import and analyses LI600 data

library(tidyverse)
library(tidylog)

source("scripts/functions/Li600Import.R")

# Import data -----
# Make a list of all your LI600 files
LI600_file_list = dir(path = "raw_data/LI600",
                   full.names = TRUE, recursive = TRUE)

LI600_raw = map_df(set_names(LI600_file_list), function(file) {
  file %>%
    purrr::set_names() %>%
    map_df(~ Li600Import_Bulk(file))
})

# Clean the data ----
LI600_clean = LI600_raw |>
  # Remove non-obs
  drop_na(Obs.) |>
  # Flag unusual data
  mutate(flag_data = case_when(
    
  ))