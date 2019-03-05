library(data.table)

get_coffee_share = function(){
  return(
    rbindlist(
      list(
        list(Country = "European Union", CoffeeType = "Colombian Milds", MarketShare = 0.45),
        list(Country = "USA", CoffeeType = "Colombian Milds", MarketShare = 0.55),
        
        list(Country = "European Union", CoffeeType = "Other Milds", MarketShare = 0.56),
        list(Country = "USA", CoffeeType = "Other Milds", MarketShare = 0.44),
        
        list(Country = "European Union", CoffeeType = "Brazilian Naturals", MarketShare = 0.74),
        list(Country = "USA", CoffeeType = "Brazilian Naturals", MarketShare = 0.26),
        
        list(Country = "European Union", CoffeeType = "Robustas", MarketShare = 0.82),
        list(Country = "USA", CoffeeType = "Robustas", MarketShare = 0.18)
      )
    )
  )
}

get_coffee_consumption_share = function(){
  return(
    rbindlist(
      list(
        list(Country = "European Union", CoffeeType = "")
      )
    )
  )
}

get_european_countries = function(){
  countries = c("Austria
                Belgium
                Belgium/Luxembourg
                Bulgaria
                Croatia
                Cyprus
                Czech Republic
                Denmark
                Estonia
                Finland
                France
                Germany
                Greece
                Hungary
                Ireland
                Italy
                Latvia
                Lithuania
                Luxembourg
                Malta
                Netherlands
                Poland
                Portugal
                Romania
                Slovakia
                Slovenia
                Spain
                Sweden
                United Kingdom")
  
  c = trimws(unlist(strsplit(countries, "\n")), which = "both")
  
  return(c)
}

read_consumption_proportion = function(){
  a = data.table(read_xlsx(here::here("data/raw/Country consumption proportions.xlsx")))
  a[, Bags := NULL]
  return(a)
}
