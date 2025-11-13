# Import and analyses LI600 data

library(tidyverse)
library(tidylog)

source("scripts/functions/Li600Import.R")

# Import data -----
# Make a list of all your LI600 files
LI600_file_list = dir(path = "raw_data/LI600",
                   full.names = TRUE, recursive = TRUE)

# Read them all in
LI600_temp = purrr::map_dfr(LI600_file_list, Li600Import_Bulk) 

# Clean the data ----
LI600_raw = LI600_temp |>
  # Rename columns
  rename(obs = Obs.) |>
  # Remove non-obs
  drop_na(obs) |>
  # Drop duplicated observations
  distinct() |>
  # Flag unusual data
  mutate(flag_data = case_when(
    gsw < 0 ~ "negative_gsw",
    gsw > 1 ~ "high_gsw",
    VPDleaf < 0 ~ "negative_VPD",
    VPDleaf > 3 ~ "high_VPD",
    PhiPS2 < 0 ~ "negative_PhiPS2",
    PhiPS2 > 1 ~ "high_PhiPS2",
    TRUE ~ "okay"
  ))

table(LI600_raw$flag_data)

# Visualise the flags
ggplot(LI600_raw |>
         select(obs, flag_data, gsw, gbw, gtw, VPDleaf, PhiPS2) |>
         pivot_longer(gsw:PhiPS2, names_to = "variable", values_to = "value"),
       aes(x = obs, y = value, colour = flag_data)) +
  geom_point() +
  facet_wrap(~variable, scales = "free") +
  theme_bw()

# Clean the data ----
LI600_clean = LI600_raw |>
  filter(flag_data == "okay")

# Visualise the data without flags
ggplot(LI600_clean |>
         select(obs, flag_data, gsw, gbw, gtw, VPDleaf, PhiPS2) |>
         pivot_longer(gsw:PhiPS2, names_to = "variable", values_to = "value"),
       aes(x = obs, y = value)) +
  geom_point() +
  facet_wrap(~variable, scales = "free") +
  theme_bw()

# Export the data ----
write.csv(LI600_clean, paste0("outputs/", Sys.Date(), "_LI600_clean.csv"))