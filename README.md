# Coffee prices modeling  

## Project structure 

/data - contains raw and processed data. Some of the files are read "raw", as they don't require lengthly processing  
/data/raw  
/data/raw/weather   
/data/processed  
/data/processed/weather    
/documents - some suplementary documents.    
/reports - contains .Rmd files, that generate analytical reports for this project.  
/scripts - various functions, that are used by the reports and fitting procedures.    

## Modeling approach

It is reasonable to assume that price in a free market is a function of supply and demand.  
In it's own way supply and demand can be modeled somewhat separately, so in the end we have a hierarchical model of coffee prices:  
1. Demand time series model. 
  a. One model for every major consumer market. Bottom up aggregation to total global demand.  
  b. Covariates to test: price, GDP, consumer basket price  
2. Production time series model.
  a. One model for every major production area. Bottom up aggregation to global production. 
  b. Covariates to test: weather indicators, coffee price for previous seasons  
3. Price time series model.
  a. VARMAX model for time series of different coffee type prices.  
  b. Covariates to test: Combine demand and supply predictions from models 1 and 2. Prices for previous periods.  
  
Since price data from International Coffee Organization is available on a monthly basis and vast majority of other information is available on a yearly basis, our forecast models will predict on a monthly basis.  

## Data Sources  

### Files from World Bank Group:
Url: https://data.worldbank.org/
- Consumer price index (2010 = 100). Is used to transform nominal prices of coffee to constant 2010 USD prices.    
  
### Files from International Coffee Organization  
Url: http://www.ico.org/new_historical.asp   
- data/raw/Dissapearance.xlsx - an estimation of consumption (yearly)   
- data/raw/Domestic consumption.xlsx - coffee consumption in coffee growing countries (yearly)  
- data/raw/Exportable production.xlsx - coffee exportable production after internal consumption (yearly)  
- data/raw/Exports - calendar year.xlsx - Exports on calendar years (yearly)  
- data/raw/Exports - crop year.xlsx - Exports by crop growing years (yearly)  
- data/raw/Gross Opening Stocks.xlsx - coffee stocks at the start of a year (yearly)  
- data/raw/Imports.xlsx - import information by countries (yearly)  
- data/raw/Indicator prices.xlsx - monthly indicator prices for coffee (monthly)  
- data/raw/Inventories.xlsx - additional information about stock (yearly)  
- data/raw/Prices paid to growers.xlsx - yearly average prices paid to growers (yearly)  
- data/raw/Re-exports.xlsx  - processed coffee exports (yearly)  
- data/raw/Total production.xlsx - total production by crop year (yearly)  

Documentation: http://www.ico.org/documents/cy2014-15/sc-59e-data-concepts.pdf
- documents/cru_ts4.02.1981.1990.tmp.dat.nc.pdf - statistics glossary for ICO  

### Weather files from Climatic Research Unit  
Url: https://crudata.uea.ac.uk/cru/data/hrg/  
-- data/raw/weather/cru_ts4.02.[YYYY].[YYYY].<b>cld</b>.dat.nc.gz - cloud cover, in %, over a month  
-- data/raw/weather/cru_ts4.02.[YYYY].[YYYY].<b>dtr</b>.dat.nc.gz - diurnal temperature range, in celsius, average over a month      
-- data/raw/weather/cru_ts4.02.[YYYY].[YYYY].<b>frs</b>.dat.nc.gz - frost day frequency, in days in a month  
-- data/raw/weather/cru_ts4.02.[YYYY].[YYYY].<b>pet</b>.dat.nc.gz - potential evapotranspiration, milimiters per day  
-- data/raw/weather/cru_ts4.02.[YYYY].[YYYY].<b>pre</b>.dat.nc.gz - precipitation, milimiters per month  
-- data/raw/weather/cru_ts4.02.[YYYY].[YYYY].<b>rhm</b>.dat.nc.gz - relative humidity, in %  
-- data/raw/weather/cru_ts4.02.[YYYY].[YYYY].<b>tmp</b>.dat.nc.gz - daily mean temperature, in celsius  
-- data/raw/weather/cru_ts4.02.[YYYY].[YYYY].<b>tmn</b>.dat.nc.gz - monthly average daily minimum temperature, in celsius  
-- data/raw/weather/cru_ts4.02.[YYYY].[YYYY].<b>tmx</b>.dat.nc.gz - monthly average daily maximum temperature, in celsius  
-- data/raw/weather/cru_ts4.02.[YYYY].[YYYY].<b>vap</b>.dat.nc.gz - vapour pressure, in hectopascals (hPa)  
-- data/raw/weather/cru_ts4.02.[YYYY].[YYYY].<b>wet</b>.dat.nc.gz - wet day frequency, in days

Weather data is in NetCDF format, which makes it bit tricky to read.  
On a mac the easiest way is to follow this procedure: http://geog.uoregon.edu/bartlein/courses/geog490/install_netCDF.html  
Afterwards you can use R package called RNetCDF. 
/scripts/data processing/extract_filter_weather.R processes the files and prepares tabular representation of the data.  

### Coffee growing regions gps:  

From Harward dataverse, collected by International CEnter for Tropical Agriculture  
Url: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/29634
- data/raw/CoffeePoints_2.csv - 2015 survey of coffee farming locations: 2194 location points (Arabica only).   
- data/raw/CoffeeRegionLATLON_Data_Ratio.xlsx - team sampled coffee region locations. This dataset is not used, since the majority of locations are already included in CoffeePoints_2.csv  

### Coffee harvest and shipment seasonality: 



## Data processing 
-- All indicator prices need to be transformed to constant 2010 USD prices.  

## Code execution sequence  
1. Make sure to install all of the neccessary R packages, by running install_packages.R in the root folder of the project.  
2. Run preprocess_data.R file. It will process and filter weather records into easier to use format.  
3. Run train_models.R file. It will train the production, demand and price models.  
4. Run(knit) files in reports folder: reports/Production modeling.Rmd, reports/Demand modeling.Rmd, reports/Price modeling.Rmd  
5. This will produce *.html reports with the same names.  




