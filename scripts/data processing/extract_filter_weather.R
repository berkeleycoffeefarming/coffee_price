library(data.table)
library(here)
library(RNetCDF)
library(lubridate)

source(here::here("scripts/data processing/read_growing_locations.R"))
source(here::here("scripts/utils.R"))
source(here::here("scripts/data processing/download_weather.R"))

process_weather = function(){
  download_weather()
  
  growing_locations = read_growing_locations_cells()
  unique_growing_locations = unique(growing_locations[, .(Lat_index, Lon_index)])
  variables = c("cld", "dtr", "frs", "pre", "pet", "tmn", "tmp", "tmx", "vap", "wet")
  
  read_weather_variable = function(variable){
    print(paste0("Processing variable: ", variable))
    zipped_files = get_zipped_weather_files(variable)
    unzip_file(zipped_files)
    weather_files = get_unziped_weather_files(variable)
    
    weather_file = weather_files[1]
    
    nc_data = open.nc(
      weather_file,
      write = FALSE
    )
    
    read_weather_file = function(weather_file){
      nc_data_list = read.nc(open.nc(weather_file))
      location_weather = 
        rbindlist(
          lapply(
            1:nrow(unique_growing_locations),
            function(i){
              data.table(
                Latitude = nc_data_list$lat[unique_growing_locations[i]$Lat_index],
                Longitude = nc_data_list$lon[unique_growing_locations[i]$Lon_index],
                Date = make_date(1900, 1, 1) + days(nc_data_list$time),
                Variable = nc_data_list[[variable]][unique_growing_locations[i]$Lon_index, unique_growing_locations[i]$Lat_index,]
              )
            }
          )
        )
      
      location_weather[, (variable):=Variable]
      location_weather[, Variable:=NULL]
      
      return(location_weather)
    }
    
    weather_data = rbindlist(lapply(weather_files, read_weather_file))
    cleanup_unziped_files()
    return(weather_data)
  }
  
  weather_data = lapply(variables, read_weather_variable)
  cleanup_unziped_files()
  
  merge_tables = function(df1, df2){
    merge(
      df1, df2, 
      by = c("Latitude", "Longitude", "Date"),
      all.x = TRUE, all.y = TRUE
    )
  }
  
  weather_data = Reduce(merge_tables, weather_data)
  weather_data[, Date:=Date-day(Date)+1]
  fwrite(weather_data, here::here("data/processed/weather.csv"))
}

read_weather = function(){
  if(!file.exists(here::here("data/processed/weather.csv"))){
    process_weather()
  }
  
  weather = fread(here::here("data/processed/weather.csv"))
  weather[, Date:=ymd(Date)]
  return(weather)
}
