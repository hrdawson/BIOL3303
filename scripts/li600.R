# Import and analyses LI600 data

# Import data -----
LI600_header = read.csv("raw_data/LI600/Auto gsw+F_LI-COR Default_2025_02_20_15_03_33_1.csv", skip = 1, header = FALSE) |>
  slice(1) |>
  t() |>
  pull()

LI600_raw = read.csv("raw_data/LI600/Auto gsw+F_LI-COR Default_2025_02_20_15_03_33_1.csv", skip = 1)


LI600_long = LI600_raw |>
  pivot_longer(cols = c(gsw:H2O_leaf, Fs:Qamb))
# Clean the data ----
LI600_clean = LI600_raw |>
  # Remove non-obs
  drop_na(Obs.) |>
  # Flag unusual data
  mutate(flag_data = case_when(
    
  ))