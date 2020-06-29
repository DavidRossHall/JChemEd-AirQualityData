library(dplyr)
library(tidyr)
library(stringr)
library(anytime)

### Takes a single ECCC .csv file, and transforms the NAPS station data it into Excel compatibale columnar data & serial Date
cleanupECCC <- function(file,NAPSID){
### Removing the blurb at the top of the ECCC .csv's that expain '-999' values
### & cleaning up default ECCC headers  
df = read.csv(file, skip = 7, header = T)
colnames(df) <- gsub("\\..*","",colnames(df))

df <- subset(df, df$NAPS == NAPSID)

### Transforming ECCC 'matrix' into columnar data, new 'hour' and 'O3' columns. 
df <- df %>%
  pivot_longer(
    cols = starts_with("H"),
    names_to = "hour",
    values_to = df[1,1] # measured pollutant
  )

### Converting 'hour' into their Excel decimal values; 
### subtracted 1 so values are from the top, and not bottom, of the hour. 
df$hour <- as.numeric(str_sub(df$hour,-2,-1))
df$hour <- df$hour - 1
df$hour <- df$hour / 24

df$Date <- as.numeric(as.Date(anydate(df$Date)) -as.Date(0, origin="1899-12-30", tz='UTC'))
df$Date <- df$Date + df$hour

return(df)
}

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
  
  colnames(yearWeather)[1] <- "Date" #changed to match header of ECCC data, and for eventual merge
  yearWeather[is.na(yearWeather)] <- -999 # Changed so NA values would match the '-999' notation used by the ECCC
  return(yearWeather)
}

### Outputs dataframe with date, temp, NO2, and O3 values for the entire year at one station. 
### Break it up into 7 day periods for students. 
studentData <- function(O3,NO2, weather, year, NAPSID){
  
  O3 <- cleanupECCC(file = O3, NAPSID = NAPSID)
  NO2 <- cleanupECCC(file = NO2, NAPSID = NAPSID)
  weather <- weatherExcelSerial(file = weather, year = year)
  
merge_df <- merge(weather, NO2, by="Date")
keep <- c("Date", "temperature", "NO2")
df <- merge_df[keep]

merge_df <- merge(df, O3, by="Date")
keep <- c("Date", "temperature", "NO2", "O3")
df <- merge_df[keep]

return(df)
  
}

### Generates overlapping splits of data.frame; from Github user Joris Meys,https://stackoverflow.com/questions/5653756/
OverlapSplit <- function(x,nsplit=1,overlap=2){
  nrows <- NROW(x)
  nperdf <- ceiling( (nrows + overlap*nsplit) / (nsplit+1) )
  start <- seq(1, nsplit*(nperdf-overlap)+1, by= nperdf-overlap )
  
  if( start[nsplit+1] + nperdf != nrows )
    warning("Returning an incomplete dataframe.")
  
  lapply(start, function(i) x[c(i:(i+nperdf-1)),])
}

### --- SPECIFY EVERYTHING HERE --- 
  O3 <- "O3_2018.csv"
  NO2 <- "NO2_2018.csv"
  weather <- "weatherstats_toronto_hourly.csv"
  year <- 2018
  NAPSID <- 60440
  folder <- 'Toronto_60440_2018/'
  city <- 'Toronto'



df <- studentData(O3, NO2, weather, year, NAPSID)

### Each element in 'lst' is a complete 7-day dataset for a student
lst <- OverlapSplit(df,nsplit=364,overlap=144)

for (i in 1:length(lst)) {
  
  tmp <- lst[[i]]
  tmp[sample(nrow(tmp), 2), 'O3'] <- -999
  fn = paste0(folder,city,"_",NAPSID,"_",year,"_Day",i,"to",(i+6),".csv")
  write.csv(tmp,fn,row.names=FALSE)
  
}
