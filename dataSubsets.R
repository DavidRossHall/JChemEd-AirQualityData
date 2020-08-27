### 2020-08-27, David Hall, davidross.hall@mail.utoronto.ca
### Takes a single ECCC .csv file, and transforms the NAPS station data it into Excel compatibale columnar data & serial Date

# 1. Loading packages ----------------

library(tidyverse)
library(stringr)
library(anytime)


O3 <- "O3_2018.csv"
NO2 <- "NO2_2018.csv"
weather <- "weatherstats_toronto_hourly.csv"
year <- 2018
NAPSID <- 60410
folder <- 'Toronto_60410_2018/'
city <- 'Toronto'


# 2. cleanUpECCC: function that converts ECCC files into column w/ Excel Dates ---------------------
cleanUpECCC <- function(file,NAPSID){
  
  # Removing the blurb at the top of the ECCC .csv's that expain '-999' values
  df <- read.csv(file, skip = 7, header = T)
  
  # Cleaning up bilingual headers, and transform to columnar data
  df <- df %>% rename_all(funs(gsub("\\..*","", make.names(names(df))))) %>%
    filter(NAPS == NAPSID) %>%
    pivot_longer(
      cols = starts_with("H"),
      names_to = "Hour",
      values_to = df[1,1] # measured pollutant
    ) 
  
  ### Converting 'hour' into their Excel decimal values; 
  df$Hour <- as.numeric(str_sub(df$Hour,-2,-1))
  df$Hour <- df$Hour - 1  # subtracted 1 so values are from the top, and not bottom, of the hour. 
  df$Hour <- df$Hour / 24
  
  df$Date <- as.numeric(as.Date(anydate(df$Date)) -as.Date(0, origin="1899-12-30", tz='UTC'))
  df$Date <- df$Date + df$Hour # Date is now column with 
  
  
  return(df)
}


#3. studentData: combines O3 & NO2 data and creates a lst of 7 day overlapping datasets -----------
#     Default station is Downtown Toronto 60433
#     nsplits is the number of subsets, default is 364
#     overlap is number of days datasets overlap, default is 144 hrs or 6 days


studentData <- function(O3, NO2, NAPSID = 60433 , nsplit=364,overlap=144){
  
  O3 <- cleanUpECCC(file = O3, NAPSID = NAPSID)
  NO2 <- cleanUpECCC(file = NO2, NAPSID = NAPSID)
  
  merge_df <- merge(NO2, O3, by="Date")
  keep <- c("Date", "NO2", "O3")
  df <- merge_df[keep]

  
  nrows <- NROW(df)
  nperdf <- ceiling( (nrows + overlap*nsplit) / (nsplit+1) )
  start <- seq(1, nsplit*(nperdf-overlap)+1, by= nperdf-overlap )

  if( start[nsplit+1] + nperdf != nrows )
    warning("Returning an incomplete dataframe.")

  lapply(start, function(i) df[c(i:(i+nperdf-1)),])
}

lst <- studentData(O3, NO2, NAPSID)

