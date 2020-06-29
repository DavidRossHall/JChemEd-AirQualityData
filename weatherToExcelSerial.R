library(lubridate)

#weather <- read.csv("weatherstats_toronto_hourly.csv")

#yearWeather <- weather[grep("2018", weather$date_time_local), ]
#yearWeather2 <- weather[grep("2018", weather$date_time_local), ]

### From a WeatherStats .csv, returns data.frame with specified year date&times converted to Excel Serial 
weatherExcelSerial <- function(file, year){

weather <- read.csv(file)
yearWeather <- weather[grep(as.character(year), weather$date_time_local), ]

### Converting Date & Time values from WeatherStats into Excel serial number
yearWeather$date_time_local <- anytime(yearWeather$date_time_local, tz = 'EST')
t.lub <- ymd_hms(yearWeather$date_time_local)
h.lub <- hour(t.lub) + minute(t.lub)/60
yearWeather$hour <- h.lub/24

yearWeather$date_time_local <- as.numeric(as.Date(anydate(yearWeather$date_time_local)) -as.Date(0, origin="1899-12-30", tz='UTC'))
yearWeather$date_time_local <- yearWeather$date_time_local + yearWeather$hour # This is now the Excel serial number 

return(yearWeather)
}

x <- weatherExcelSerial(file = "weatherstats_toronto_hourly.csv", year = 2018)