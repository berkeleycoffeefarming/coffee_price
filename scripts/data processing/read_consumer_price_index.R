library(data.table)
library(readxl)
library(here)
library(lubridate)

read_consumer_price_index = function(){
  index = fread(here::here("data/raw/Consumer price index.csv"), skip=4, header=TRUE)
  index = index[`Country Name`=="United States"]
  index[, `:=`(
    `Country Name` = NULL,
    `Country Code` = NULL,
    `Indicator Name` = NULL,
    `Indicator Code` = NULL,
    `V64` = NULL
  )]
  index[,`2010`:=as.double(`2010`)]
  
  index_long = 
    melt(
      index, measure.vars = colnames(index),
      variable.name = "Year", value.name = "PriceIndex"
    )
  
  index_long[, Year:=as.integer(as.character(Year))]
  index_long[is.na(PriceIndex), PriceIndex := max(index_long$PriceIndex, na.rm = TRUE)]
  
  return(index_long)
}
