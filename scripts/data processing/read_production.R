library(readxl)
library(here)
library(lubridate)

source(here::here("scripts/data processing/country_coffee_types.R"))

read_production = function(filepath){
  production = data.table(read_xlsx(here::here(filepath), skip=3))
  colnames(production)[1:2] = c("Country", "CoffeeType")
  production = production[!is.na(Country)]
  production = production[!grepl("Total", Country)]
  production = production[!grepl("International", Country)]
  
  yield_groups = c("April group", "July group", "October group")
  production[Country %in% yield_groups, YieldGroup:=Country]
  
  header_indexes = production[, which(!is.na(YieldGroup))]
  header_indexes_lag = c(header_indexes[2:length(header_indexes)], 1000)
  header_lengths = header_indexes_lag - header_indexes
  header_lengths[1] = header_lengths[1]+1
  
  header = unlist(sapply(1:3, function(i) rep(yield_groups[i], header_lengths[i])))
  production[, YieldGroup:=header[1:nrow(production)]]
  
  production = production[!(Country %in% yield_groups)]
  production[, CoffeeType:=NULL]
  
  production_long = melt(
    production, 
    id.vars = c("Country", "YieldGroup"),
    variable.name = "Year", value.name = "TotalProduction"
  )[!is.na(TotalProduction)]
  
  production_long[, Year := substr(as.character(Year),1,4)]
  production_long[, Year := as.integer(Year)]
  
  coffee_types = read_country_coffee_types()
  
    coffee_types_long = 
    melt(
      coffee_types, 
      id.vars = c("Country", "PrimaryCoffeePercentage"), 
      measure.vars = c("PrimaryCoffeeType", "SecondaryCoffeeType"),
      value.name = "CoffeeType"
    )[, .(
      Country, 
      CoffeeType, 
      Percentage = ifelse(variable == "PrimaryCoffeeType", PrimaryCoffeePercentage, 1-PrimaryCoffeePercentage))
    ][!is.na(CoffeeType)]
  
  production_long = merge(
    production_long, coffee_types_long,
    by.x = "Country", by.y="Country",
    all.x = TRUE, all.y = FALSE, allow.cartesian = TRUE
  )
  
  production_long[, TotalProduction := TotalProduction * Percentage]
  production_long[, Percentage := NULL]
  production_long = production_long[Year<=2017]
  return(production_long)
}

read_total_production = function(){
  return(read_production("data/raw/Total production.xlsx"))
}

read_exportable_production = function(){
  return(read_production("data/raw/Exportable production.xlsx"))
}
