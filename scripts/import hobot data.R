# HOBO processing

# Import the data ----
hobo_column_names = c("obs", "datetime", "T1", "T2", "T3", "T4", "Tdevice", "host", "stopped", "endfile")

HOBO_file_list = dir("raw_data/HOBO", pattern = ".csv", full.names = TRUE, recursive = TRUE)

HOBO_temp = map_dfr(HOBO_file_list, read.csv, skip = 1, col.names = hobo_column_names)

# Mark up the data for cleaning -----
HOBO_raw = HOBO_temp |>
  select(-c("host", "stopped", "endfile")) |>
  mutate(datetime = lubridate::mdy_hms(datetime)) |>
  filter(datetime %within% lubridate::interval("2024-12-05 12:45:00", "2024-12-05 14:20:00")) |> # Set this to be your own times
  pivot_longer(cols = T1:Tdevice, names_to = "temp_location", values_to = "temp_C") |>
  mutate(flag_data = case_when(
    temp_C > 100 ~ "high_temp",
    temp_C < 0 ~ "low_temp",
    TRUE ~ "okay"
  ))

## Visualise which data are flagged -----
ggplot(hobo |>
         pivot_longer(cols = T1:Tdevice, names_to = "variable", values_to = "value"),
       aes(x = datetime, y = value, colour = variable)) +
  geom_point() +
  theme_bw()

# Clean the data ----
HOBO_clean = HOBO_raw |>
  filter(flag_data = "okay")

# Export for use in other programs ----
write.csv(HOBO_clean, paste0("outputs/", Sys.Date(), "_HOBO_clean.csv"), row.names = FALSE)