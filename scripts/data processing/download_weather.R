library(here)
library(data.table)

download_weather = function(){
  
  variables = c("cld", "dtr", "frs", "pet", "pre", "tmn", "tmp", "tmx", "vap", "wet")
  periods = c("1981.1990", "1991.2000", "2001.2010", "2011.2017")
  
  to_download = 
    data.table(
      expand.grid(
        variable = variables,
        period = periods
      )
    )
  to_download[, file_path := here::here(paste0("data/raw/weather/", "cru_ts4.02.",period,".",variable,".dat.nc.gz"))]
  
  missing_indexes = !sapply(to_download$file_path, file.exists)
  missing_files = to_download[missing_indexes]
  
  if (nrow(missing_files) > 0){
    for (i in 1:nrow(missing_files)){
      download.file(
        paste0("https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.02/cruts.1811131722.v4.02/",
               missing_files[i]$variable
               ,"/cru_ts4.02.",
               missing_files[i]$period
               ,".",
               missing_files[i]$variable
               ,".dat.nc.gz"),
        destfile = missing_files[i]$file_path
      )
    }
  }
}
