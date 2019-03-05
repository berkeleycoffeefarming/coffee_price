library(data.table)
library(readxl)
library(here)
library(lubridate)

source(here::here("scripts/data processing/coffee_market_share.R"))

read_inventories = function(){
  inventories = data.table(read_xlsx(here::here("data/raw/Inventories.xlsx"), skip=3))
  colnames(inventories)[1] = "Country"
  
  european_countries = get_european_countries()
  
  inventories = inventories[!is.na(Country)]
  inventories = inventories[!grepl("Total", Country)]
  inventories = inventories[!grepl("International", Country)]
  inventories = inventories[!(Country %in% european_countries)]
  inventories = inventories[!grepl("Inventories of ", Country)]
  inventories = inventories[!grepl("Unspecified EU stocks", Country)]
  
  inventories_long = melt(
    inventories,
    id.vars = "Country", variable.name = "Year", value.name = "GreenCoffeeInventory"
  )
  inventories_long[is.na(GreenCoffeeInventory), GreenCoffeeInventory:=0]
  inventories_long[, Year:=as.integer(as.character(Year))]
  
  consumption_share = read_consumption_proportion()
  
  inventories_long = merge(
    inventories_long, consumption_share,
    all.x = TRUE, all.y = FALSE, allow.cartesian = TRUE
  )
  
  inventories_long[, Inventory:=GreenCoffeeInventory*ConsumptionShare]
  inventories_long[, `:=`(GreenCoffeeInventory = NULL, ConsumptionShare = NULL)]
  
  return(inventories_long)
}
  