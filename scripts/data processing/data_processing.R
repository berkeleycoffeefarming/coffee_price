library(here)

source_files = list.files(here::here("scripts/data processing"), full.names = TRUE)
source_files = source_files[!grepl("data_processing", source_files)]

for (source_file in source_files){
  source(source_file)
}

rm(source_file, source_files)
