# Set up workspace
library(tidyverse)
library(tidylog)
library(lubridate)
library(janitor)

source("scripts/functions/readdat.R")
# Make dataset -----
## Make a list of all the files to read in
FutureClim_file_list = dir("raw_data/FutureClim/FiveMin", pattern = "*.dat", full.names = TRUE, recursive = TRUE)

## Read them in
FutureClim_temp = purrr::map_dfr(FutureClim_file_list, read.dat) # This applies the read.dat function to each file and binds them together into a single dataframe
  
# Work on cleaning the data ----
FutureClim_raw = FutureClim_temp |>
  # Make the datetime readable to R
  mutate(TIMESTAMP = ymd_hms(TIMESTAMP)) |>
  # Filter to appropriate timestamps
  filter(TIMESTAMP %within% interval("2025-11-01", "2025-11-30")) |>
  # Remove empty columns
  janitor::remove_empty("cols") |>
  # Remove duplicate rows
  distinct() |>
  # pivot longer to apply plot metadata
  select(-c(Fuel_Moisture.1.:TC_24)) |> # Remove the columns without useful data
  pivot_longer(Soil_VWC_01_Avg:Soil_Temp_08_Avg, names_to = "variable_long", values_to = "value") |>
  separate(variable_long, into = c("substrate", "variable_short", "unit_nr", "stat"), sep = "_") |> # Extract useful info from variable names
  mutate(unit_nr = as.numeric(unit_nr)) |>
  left_join(read.csv("raw_data/FutureClim/FutureClim_metadata.csv")) |> # add in metadata
  # Extract block info
  mutate(File = basename(File)) |>
  separate(File, into = c("org", "proj", "block", "interval"), sep = "_") |>
  mutate(block = str_extract(block, '[:digit:]'))
  

# Make final clean data ----
# mean hourly temp and moisture for each plot with columns for block, treatment, time, temp and moisture at each depth
FutureClim_clean = FutureClim_raw |>
  # select the relevant data
  filter(variable_short %in% c("VWC", "Temp")) |>
  # Calculate hourly averages
  mutate(date = date(TIMESTAMP),
         hour = hour(TIMESTAMP)) |>
  group_by(date, hour, block, trt, depth_cm, variable_short) |>
  summarize(mean_value = mean(value)) |>
  ungroup() |>
  mutate(datetime = ymd_hm(paste0(date, " ", hour, ":00"))) |>
  select(-c(date, hour)) |>
  # tidy up names
  mutate(variable_short = str_to_lower(variable_short)) |>
  # make wide form for ease of use
  pivot_wider(names_from = variable_short, values_from = mean_value, names_prefix = "soil_") |>
  relocate(datetime)

# Export data ----
write.csv(FutureClim_clean, paste0("outputs/", Sys.Date(), "_FutureClim_soil_data.csv"), row.names = FALSE)
