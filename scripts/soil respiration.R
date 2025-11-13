# Read in LI6400 files

# Load dependencies ----
library(tidyverse)
library(tidylog)

# If you don't already have this script in this folder, download it from GitHub
source("scripts/functions/Li6400Helper--Li6400Import_revised.R")

# Import the data ----
# Make a list of all your LI6400 files
SR_file_list = dir(path = "raw_data/LI6400",
                   full.names = TRUE, recursive = TRUE)

## Read them in
temp_SR_data_raw = purrr::map_dfr(SR_file_list, Li6400Import_Data)  # This applies the read.dat function to each file and binds them together into a single dataframe

# Here's some code to modify if the LICOR insists that it saved a file as only an XLS
# temp_SR_data_xls = read.csv("raw_data/LI6400_SR/field_session_3-3.02.2025/2025.02.06_pi-o-sr_.csv", skip = 9) |>
#   mutate(remark = case_when(
#     Obs == "Remark=" ~ str_remove_all(HHMMSS, "\""),
#     TRUE ~ NA
#   ),
#   File = "raw_data/LI6400_SR/field_session_3-3.02.2025/2025.02.06_pi-o-sr_.csv",
#   HHMMSS = lubridate::ymd_hms(paste0("2025-02-05 ", HHMMSS))) |>
#   fill(remark, .direction = "down") |>
#   filter(str_detect(Obs, '[1:9]')) |>
#   pivot_longer(cols = FTime:Status, values_to = "value", names_to = "variable",
#                values_transform = as.numeric) |>
#   select(Obs, HHMMSS, remark, File, variable, value)

# If all your files are the same type, run this code
temp_SR_data = temp_SR_data_raw |>
  pivot_wider(names_from = variable, values_from = value)

# If you're working with both raw and XLS data, unhash and run this code
# temp_SR_data = bind_rows(temp_SR_data_raw, temp_SR_data_xls) |>
#    pivot_wider(names_from = variable, values_from = value)

# Format and clean the data ----
# Use code to flag outliers and measurements you know are duds
# I've added code for the most common problems but you can supplement with your own
SR_data_raw = temp_SR_data |>
  # Filter out non-obs
  drop_na(EFFLUX) |>
  # Filter to just the averaged efflux (final value)
  filter(Mode == 4) |>
  # Make remarks into useful data
  separate(remark, into = c("remark.timestamp", "plot_remarks"), sep = " ") %>%
  # Deciphering each part of the file name
  # You'll need to modify this based on your own file naming scheme
  mutate(fileName = basename(File)) |>
  separate(fileName, into = c("fileDate", "plot_file"), sep = "_") |>
  # Flag data quality
  mutate(flag_data = case_when(
    EFFLUX > 10 | EFFLUX < 0.7  ~ "efflux_suspect",
    RHirga. > 85 | RHirga. < 35 ~ "RH_suspect",
    Tair > 40 | Tair < 12 ~ "Tair_suspect",
    CO2S > 500  ~ "CO2_suspect",
    TRUE ~ "Okay"
  ))

## Visualise the flagged data ----
ggplot(SR_data_raw,
       aes(x = plot_remarks, y = EFFLUX, colour = flag_data)) +
  geom_point() +
  theme_bw()

# Filter the flagged data ----
SR_clean = SR_data_raw |>
  filter(flag_data == "Okay")

# Export the flagged data ----
write.csv(paste0("outputs/", Sys.Date(), "_SR_clean.csv"), row.names = FALSE)