### 2020-08-27, David Hall, davidross.hall@mail.utoronto.ca
### Takes a single ECCC .csv file, and transforms the NAPS station data it into Excel compatibale columnar data & serial Date

# 1. Loading packages ----------------

library(tidyverse)
library(stringr)
library(anytime)


# O3 <- "O3_2018.csv" # ECCC hourly O3 file
# NO2 <- "NO2_2018.csv" # ECCC hourly NO2 report
# NAPSID <- 60410 # ECCC NAPSID, i.e. location you want data from.
# dataPairs <- 15 # number of paired winter/summer datasets.
# save <- TRUE # TRUE = save files in new directory, FALSE = output list of student data subsets dfs

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

# 3. Outputs location of folder used to save .csv and anwser keys  ---------------------------------------------------------

folderLocation <- function(O3, NAPSID = 60433){

    O3 <- cleanUpECCC(file = O3, NAPSID = NAPSID)
    
    
    # # extracting values for saving .csvs
    city <- O3$City[[1]]
    date <-as.Date(O3$Date[[1]], origin = "1899-12-30")
    year <- as.numeric(format(date,'%Y'))
    
    # creating directory for saving .csvs
    folder <- paste(city,"_",NAPSID,"_",year,"/", sep = "")
    folder
    }

# 4. studentData: combines O3 & NO2 data and creates a lst of 7 day overlapping datasets -----------
  #     Default station is Downtown Toronto 60433
  #     nsplits is the number of subsets, default is 364
  #     overlap is number of days datasets overlap, default is 144 hrs or 6 days


studentData <- function(O3, NO2, NAPSID = 60433, dataPairs = 15, save = TRUE, nsplit=364,overlap=144){
  
  O3 <- cleanUpECCC(file = O3, NAPSID = NAPSID)
  NO2 <- cleanUpECCC(file = NO2, NAPSID = NAPSID)
  
  # # extracting values for saving .csvs
  city <- O3$City[[1]]
  date <-as.Date(O3$Date[[1]], origin = "1899-12-30")
  year <- as.numeric(format(date,'%Y'))

  # creating directory for saving .csvs
  folder <- paste(city,"_",NAPSID,"_",year,"/", sep = "")
  dir.create(folder)
  
  # merging NO2 and O3 dfs  
  merge_df <- merge(NO2, O3, by="Date")
  keep <- c("Date", "NO2", "O3")
  df <- merge_df[keep]

  # generating list of df subsets
      nrows <- NROW(df)
      nperdf <- ceiling( (nrows + overlap*nsplit) / (nsplit+1) )
      start <- seq(1, nsplit*(nperdf-overlap)+1, by= nperdf-overlap )
    
      if( start[nsplit+1] + nperdf != nrows )
        warning("Returning an incomplete dataframe.")
    
      lst <- lapply(start, function(i) df[c(i:(i+nperdf-1)),])
      lst <- lst[c(1:dataPairs, 180:(180+dataPairs))]

  if (save == TRUE){
    for (i in 1:length(lst)) {
      
      tmp <- lst[[i]]
      tmp[sample(nrow(tmp), 2), 'O3'] <- -999 # every dataset gets -999 error
      
      # extracting day of the year for naming files
      date <-as.Date(tmp$Date[[1]], origin = "1899-12-30")
      doy <- as.numeric(strftime(date, format = "%j"))
      
      fn = paste0(folder,city,"_",NAPSID,"_",year,"_Day",doy,"to",(doy+6),".csv")
      write.csv(tmp,fn,row.names=FALSE)
      }
  } else {
    return(lst)
  }
  
}



# 5. Inputs used to test functions. -------------------------

# O3 <- "O3_2018.csv" # ECCC hourly O3 file
# NO2 <- "NO2_2018.csv" # ECCC hourly NO2 report
# NAPSID <- 60410 # ECCC NAPSID, i.e. location you want data from.
# dataPairs <- 15 # number of paired winter/summer datasets.
# save <- TRUE # TRUE = save files in new directory, FALSE = output list of student data subsets dfs
# 
# 
# lst <- studentData(O3 = O3,
#                    NO2 = NO2, 
#                    NAPSID = NAPSID,
#                    dataPairs = dataPairs,
#                    save = save)
