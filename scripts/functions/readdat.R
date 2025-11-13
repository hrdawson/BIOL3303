read.dat = function(file){
  header = read.table(file, skip = 1, sep = c(",", "\t")) |> # Extract the header names
    slice(1)
  
  data = read.table(file, header = FALSE, skip = 4, col.names = header,
                    sep = c(",", "\t"), na.strings = c("", "NA", "NAN")) |># Extract the data and apply header names
    mutate(File = file)
}