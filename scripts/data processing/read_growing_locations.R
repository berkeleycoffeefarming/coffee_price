library(data.table)
library(here)
library(readxl)

source(here::here("scripts/data processing/country_coffee_types.R"))
source(here::here("scripts/utils.R"))

read_growing_locations = function(){
  locations = fread(here::here("data/raw/CoffeePoints_2.csv"))
  locations[, Taxon := NULL]
  
  locations[Country == "Democratic Republic of the Congo", Country := "Congo, Dem. Rep. of"]
  locations[Country == "United Republic of Tanzania", Country:= "Tanzania"]
  locations[Country == "Viet Nam", Country:="Vietnam"]
  
  country_coffee_types = read_country_coffee_types()
  coffee_types_long = 
    melt(
      country_coffee_types, 
      id.vars = c("Country", "PrimaryCoffeePercentage"), 
      measure.vars = c("PrimaryCoffeeType", "SecondaryCoffeeType"),
      value.name = "CoffeeType"
    )[, .(
      Country, 
      CoffeeType, 
      Percentage = ifelse(variable == "PrimaryCoffeeType", PrimaryCoffeePercentage, 1-PrimaryCoffeePercentage))
      ][!is.na(CoffeeType)]
  
  locations_countries = unique(locations$Country)
  production_countries = unique(coffee_types_long$Country)
  
  locations = merge(
    locations, coffee_types_long,
    by.x = c("Country"), by.y = c("Country"),
    all.x = TRUE, all.y = FALSE,
    allow.cartesian = TRUE
  )
  
  locations = locations[!is.na(Percentage)]
  
  return(locations)
}  

read_growing_locations_cells = function(){
  growing_locations = read_growing_locations()
  
  if (length(get_unziped_weather_files()) == 0){
    unzip_file(get_zipped_weather_files()[1])
  }
  
  nc_data = open.nc(
    get_unziped_weather_files()[1],
    write = FALSE
  )
  
  nc_data_list = read.nc(nc_data)
  
  for (i in 1:nrow(growing_locations)){
    growing_locations[i, `:=`(
      Lat_index = which.min((nc_data_list$lat - Latitude)^2),
      Lon_index = which.min((nc_data_list$lon - Longitude)^2)
    )]
    
    growing_locations[i, `:=`(
      Lat_weather_map = nc_data_list$lat[Lat_index],
      Lon_weather_map = nc_data_list$lon[Lon_index]
    )]
  }
  
  #remove duplicate records after 0.5 by 0.5 cell map aggregation  
  growing_locations[, rn:=seq_len(.N), by=.(Lat_weather_map, Lon_weather_map, Country, CoffeeType)]
  growing_locations = growing_locations[rn == 1]
  growing_locations[, rn:=NULL]
  
  growing_locations[, `:=`(
    Latitude = Lat_weather_map,
    Longitude = Lon_weather_map,
    Lat_weather_map = NULL,
    Lon_weather_map = NULL
  )]
  
  rm(nc_data_list)
  
  return(growing_locations)
}
  
