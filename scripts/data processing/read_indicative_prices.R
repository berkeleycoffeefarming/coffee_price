library(data.table)
library(readxl)
library(here)
library(lubridate)

source(here::here("scripts/data processing/read_consumer_price_index.R"))

read_indicative_prices = function(){
  prices = data.table(read_xlsx(here::here("data/raw/Indicator prices.xlsx"), skip=3))
  colnames(prices)[1] = "YearMonth"
  
  prices = prices[!is.na(YearMonth)]
  prices = prices[!grepl("International", YearMonth)]
  
  prices = prices[grepl("[0-9]", YearMonth), Year:=as.integer(YearMonth)]
  years = prices[!is.na(Year),unique(Year)]
  prices = prices[, Year := sapply(years, function(x) rep(x, times = 13))[1:nrow(prices)]]
  prices = prices[!grepl("[0-9]", YearMonth)]
  rm(years)
  
  months = data.table(
    MonthName = c("January", "February", "March", "April", "May", "June", 
             "July", "August", "September", "October", "November", "December")
  )
  months[, MonthInt:=seq(1,12)]
  
  prices = merge(
    prices, months,
    by.x="YearMonth", by.y="MonthName"
  )
  prices[, Month:=make_date(Year, MonthInt, 1)]
  
  price_index = read_consumer_price_index()
  prices = merge(
    prices, price_index,
    by.x = "Year", by.y = "Year",
    all.x = TRUE, all.y = FALSE
  )
  
  prices[, `:=`(YearMonth = NULL, MonthInt = NULL, Year = NULL)]
  
  prices_long = melt(prices,
                     id.vars = c("Month", "PriceIndex"), variable.name = "CoffeeType", value.name = "Indicative_Price")
  prices_long[, Constant2010Price:=Indicative_Price/PriceIndex*100]
  prices_long[grepl("\r\n", CoffeeType), CoffeeType := gsub("\r\n", "", CoffeeType)]
  return(prices_long)
}
