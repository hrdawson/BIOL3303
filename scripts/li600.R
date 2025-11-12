# Import and analyses LI600 data

library(tidyverse)
library(tidylog)

source("scripts/functions/Li600Import.R")

# Import data -----
# Make a list of all your LI600 files
LI600_file_list = dir(path = "raw_data/LI600",
                   full.names = TRUE, recursive = TRUE)

# Place your cursor in the first line, then click Run
LI600_temp = map_df(set_names(LI600_file_list), function(file) {
  file %>%
    purrr::set_names() %>%
    map_df(~ Li600Import_Bulk(file))
})

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
    gsw < -2.5 ~ "low_gsw",
    gsw > 2.5 ~ "high_gsw",
    VPDleaf < 0 ~ "negative_VPD",
    VPDleaf > 5 ~ "high_VPD",
    TRUE ~ "okay"
  ))

table(LI600_raw$flag_data)

# Visualise the flags
ggplot(LI600_raw |>
         select(obs, flag_data, gsw, gbw, gtw, VPDleaf) |>
         pivot_longer(gsw:VPDleaf, names_to = "variable", values_to = "value"),
       aes(x = obs, y = value, colour = flag_data)) +
  geom_point() +
  facet_wrap(~variable, scales = "free") +
  theme_bw()

# Clean the data ----
LI600_clean = LI600_raw |>
  filter(flag_data == "okay")

# Export the data ----
write.csv(LI600_clean, paste0("outputs/", Sys.Date(), "_LI600_clean.csv"))