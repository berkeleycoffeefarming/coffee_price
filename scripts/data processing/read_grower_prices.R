library(data.table)
library(readxl)
library(here)
library(lubridate)
library(zoo)

read_grower_prices = function(){
  prices = data.table(read_xlsx(here::here("data/raw/Prices paid to growers.xlsx"), skip = 3))
  colnames(prices)[1] = "Country"
  
  prices = prices[!is.na(Country)]
  prices = prices[!grepl("International", Country)]
  
  coffee_mixes  = c("Colombian Milds", "Other Milds", "Brazilian Naturals", "Robustas")
  prices[Country %in% coffee_mixes, CoffeeType:=Country]
  
  header_indexes = prices[, which(!is.na(CoffeeType))]
  header_indexes_lag = c(header_indexes[2:length(header_indexes)], 1000)
  header_lengths = header_indexes_lag - header_indexes
  header_lengths[1] = header_lengths[1]+1
  
  header = unlist(sapply(1:4, function(i) rep(coffee_mixes[i], header_lengths[i])))
  prices[, CoffeeType:=header[1:nrow(prices)]]
  
  prices = prices[!(Country %in% coffee_mixes)]
  prices_long = melt(prices,
    id.vars = c("Country", "CoffeeType"),
    variable.name = "Year", value.name = "Price"
  )
  prices_long[, Year := as.integer(as.character(Year))]
  prices_long = prices_long[!is.na(Price)]
  
  price_index = read_consumer_price_index()
  prices_long = merge(
    prices_long, price_index,
    by.x = "Year", by.y = "Year",
    all.x = TRUE, all.y = FALSE
  )
  
  prices_long[, Constant2010Price:=Price/PriceIndex*100]
  
  
  return(prices_long)
}
