library(data.table)
library(here)
library(fpp2)

capwords = function(s, strict = FALSE){
  cap = function(s) paste(
    toupper(substring(s,1,1)),
    {s = substring(s, 2); if (strict) tolower(s) else s},
    sep = "", collapse = " ")
  
  sapply(
    strsplit(s, split= " "), cap, USE.NAMES = !is.null(names(s))
  )
}

unzip_file = function(file_path){
  system(paste0("gunzip -k ", file_path))
}
unzip_file = Vectorize(unzip_file)

get_zipped_weather_files = function(variable = ""){
  list.files(
    path = here::here("data/raw/weather"),
    pattern = paste0(variable, ".*gz$"),
    full.names = TRUE
  )
}

get_unziped_weather_files = function(variable = ""){
  list.files(
    path = here::here("data/raw/weather"),
    pattern = paste0(variable, ".*nc$"),
    full.names = TRUE
  )  
}

cleanup_unziped_files = function(){
  lapply(
    list.files(
      path = here::here("data/raw/weather"),
      pattern = "*.nc$",
      full.names = TRUE
    ),
    file.remove
  )
}