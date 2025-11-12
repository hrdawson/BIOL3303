file = "raw_data/LI600/Auto gsw+F_LI-COR Default_2025_02_20_15_03_33_1.csv"

Li600Import = function(file) {
  raw = utils::read.csv(file, skip = 1, header = FALSE)
  
  header = raw[1,] |>
    t()
  
  data = utils::read.csv(file, skip = 3, header = FALSE, col.names = header) 
}

Li600Import_Bulk = function(file) {
  data1 = Li600Import(file)
  
  # data2 = data1 |>
  #   pivot_longer(cols = c(gsw:leaf_width, Fo:batt, rh_adj:Ble, P1_dur:z_flr), values_to = "value", names_to = "variable")
}
