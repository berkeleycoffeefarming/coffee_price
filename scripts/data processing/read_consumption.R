library(readxl)
library(here)
library(lubridate)

source(here::here("scripts/data processing/country_coffee_types.R"))

read_consumption = function(){
  consumption = data.table(read_xlsx(here::here("data/raw/Disappearance.xlsx"), skip = 3))
  colnames(consumption)[1] = "Country"
  consumption = consumption[!is.na(Country)]
  consumption = consumption[!grepl("Total", Country)]
  consumption = consumption[!grepl("International", Country)]
  
  european_countries = get_european_countries()
  consumption = consumption[!(Country %in% european_countries)]
  
  consumption_long = melt(
    consumption,
    id.vars = "Country", variable.name = "Year", value.name = "Consumption"
  )
  consumption_long[is.na(Consumption), Consumption:=0]
  consumption_long[, Year:=as.integer(as.character(Year))]
  
  consumption_proportions = read_consumption_proportion()
  consumption_long = merge(
    consumption_long, consumption_proportions,
    by.x = "Country", by.y = "Country",
    all.x = TRUE, all.y = FALSE, allow.cartesian = TRUE
  )
  
  consumption_long[, Consumption := Consumption * ConsumptionShare]
  consumption_long[, ConsumptionShare := NULL]
}