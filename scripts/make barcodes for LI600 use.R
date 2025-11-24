source("scripts/functions/make_barcode_labels.R")

source("scripts/functions/get_PFTC_envelope_code.R")

# create list with all envelope codes. And show the first five values ----
all_codes <- get_PFTC_envelope_codes(seed = 3303)
all_codes$hashcode[1:5]

# make PDF of codes ----
make_barcode_labels(all_codes, "outputs/BIOL3303_barcodes")

make_barcode_sheet(all_codes, "outputs/BIOL3303_barcodes")
