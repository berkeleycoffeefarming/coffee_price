library(data.table)
library(readxl)
library(here)

read_country_coffee_types = function(){
  
  Colombian_Milds = "Colombia/Kenya/Tanzania"
  
  Other_Milds = "Bolivia/Burundi/Costa Rica/Cuba/Dominican Republic/Ecuador/El Salvador/Guatemala/Haiti/Honduras/India/Jamaica/Malawi/
  Mexico/Nepal/Nicaragua/Panama/Papua New Guinea/Peru/
  Rwanda/Venezuela/Zambia/Zimbabwe"
  
  Brazilian_Naturals = "Brazil/Ethiopia/Paraguay/Timor-Leste/Yemen"
  
  Robustas = "Angola/Benin/Cameroon/Central African Republic/Congo, Dem. Rep. of/Congo, Rep. of/Côte d'Ivoire/Equatorial Guinea/Gabon/
  Ghana/Guinea/Guyana/Indonesia/Lao, People's Dem. Rep. of/
  Liberia/Madagascar/Nigeria/Philippines/Sierra Leone/Sri Lanka/
  Thailand/Togo/Trinidad & Tobago/Uganda/Vietnam"
  
  split_countries = function(str){
    b = unlist(strsplit(str, "/"))
    d = trimws(b)
    e = gsub("\n", "", d)
    return(e)
  }
  
  
  
  country_coffee_types = 
    rbindlist(
      list(
        data.table(
          PrimaryCoffeeType = "Colombian Milds",
          Country = split_countries(Colombian_Milds)
        ),
        data.table(
          PrimaryCoffeeType = "Other Milds",
          Country = split_countries(Other_Milds)
        ),
        data.table(
          PrimaryCoffeeType = "Brazilian Naturals",
          Country = split_countries(Brazilian_Naturals)
        ),
        data.table(
          PrimaryCoffeeType = "Robustas",
          Country = split_countries(Robustas)
        )
      )
    )
  
  dual_production_countries = read_xlsx(here::here("data/raw/Dual production countries.xlsx"))
  
  country_coffee_types_all = merge(
    country_coffee_types, dual_production_countries,
    by.x = "Country", by.y = "Country",
    all.x = TRUE, all.y = TRUE
  )
  
  country_coffee_types_all[, 
    PrimaryCoffeeType := ifelse(is.na(PrimaryCoffeeType.x), PrimaryCoffeeType.y, PrimaryCoffeeType.x)
  ]
  country_coffee_types_all[, `:=`(PrimaryCoffeeType.x = NULL, PrimaryCoffeeType.y = NULL)]
  country_coffee_types_all[!is.na(SecondaryCoffeeType), PrimaryCoffeePercentage := 0.6]
  country_coffee_types_all[is.na(SecondaryCoffeeType), PrimaryCoffeePercentage := 1]
  
  return(country_coffee_types_all)
}
