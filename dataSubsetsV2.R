library(tidyverse)


O3_2018 <- "raw-data/O3_2018.csv"
O3_2019 <- "raw-data/O3_2019.csv"

NO2_2018 <- "raw-data/NO2_2018.csv"
SO2_2018 <- "raw-data/SO2_2018.csv"

x <- read_csv(O3_2018, 
              skip = 7, 
              locale = readr::locale(encoding = "Latin1"),
              name_repair = "universal")



# 1. Imports hourly ECCC measurements, skips preamble, and cleans headers --------------------
# by removing bilingual part, and renaming province columns as "Province" 
readECCC <- function(file){
  
  # Reading ECCC hourly data and cleaning up headers
  df <- read_csv(file,
                 skip = 7, 
                 locale = readr::locale(encoding = "Latin1"), 
                 name_repair = "universal") %>%
    rename_with(~ gsub("\\..*", "", .x)) 
  
  # Datasets before 2019 record province as "P", check to make consistent to "Province" 
  if(colnames(df[4]) == "P"){

    df <- rename(df, Province = P)

    df
  }
  
  # Append hour with Pollutant type
  chem <- df$Pollutant[1]
  df <-  rename_with(df, ~paste(., chem, sep = "_"), starts_with("H")) %>%
    select(-Pollutant)
  
  df
}


# 2. Combine ECCC for NAPS

  ## Combining data frames via inner_join, so pollutants from both stations
  ## Option of converting datetime to Excel or POSIX timestamps
  ## ? possible for loop over list of files. clean first file, and join all others via loop? 


joinECCC <- function(O3, NO2, NAPSID = 60435, excelTimestamp = TRUE){
  
  # Cleaning eccc files
  O3 <- readECCC(O3)
  NO2 <- readECCC(NO2)
  
  # Subsetted joined dataset
  df <- O3 %>%
    inner_join(NO2) %>%
    filter(NAPS == as.numeric(NAPSID)) %>%
    pivot_longer(cols = starts_with("H"),
                 names_to = c("Hour", "Pollutant"),
                 names_prefix = "H",
                 names_sep = "_", 
                 values_to = "Concentration") %>%
    pivot_wider(names_from = Pollutant, 
                values_from = Concentration) 
  
  # Creating data.time POSIXct column 
  
  if(excelTimestamp == TRUE){
    
    # Create Time column with Excel timestamp
    # note base on 1900 origin, some versions of excel use 1904, cause if off by 4yrs in Excel
    df <- df %>%
      mutate(Hour = (as.numeric(Hour) -1)/24) %>%
      mutate(Date = as.numeric(lubridate::ymd(Date) - lubridate::as_date("1899-12-30"))) %>%
      mutate(Time = Date + Hour) %>%
      relocate(Time, .after = Longitude) %>%
      select(-c(Date, Hour))
    
    df
    
  } else{
  
  # Create Time column with POSIX timestamp.      
  df <- df %>%
    mutate(Time = paste0(Date, " ", Hour, ":00")) %>%
    mutate(Time = lubridate::parse_date_time(Time, "%Y-%m-%d %H:%M") - lubridate::hours(1)) %>%
    relocate(Time, .after = Longitude) %>%
    select(-c(Date, Hour))
  
  df
    
  }

df

}


# 3. Extracts strings specific to joinECCC subset ------------

# Creates new folder location from joinECCC formatted data subset

## 3.1 subset city ------------
subsetCity <- function(x){
  
  city <- x$City[[1]]
  city
}

## 3.2 subset NAPS ------------

subsetNAPS <- function(x){
  
  NAPS <- x$NAPS[[1]]
  NAPS
  
}

## 3.3 subset year ------------

subsetYear <- function(x){
  
  if(is.numeric(x$Time)){
    # if dates stored as Excel timestamp (i.e. numeric)
    date <- as.Date(x$Time[[1]], origin = "1899-12-30")
    year <- as.numeric(format(date,"%Y"))
  } else {
    # getting year if POSIX
    year <- format(x$Time[[1]], format = "%Y")
  }

year
  
}

# 3.4 Subset Day of Year; get's day of year of first line in subset 
subsetDOY <- function(x){
  
  if(is.numeric(x$Time)){
    # if dates stored as Excel timestamp (i.e. numeric)
    date <-as.Date(x$Time[[1]], origin = "1899-12-30")
    doy <- as.numeric(strftime(date, format = "%j"))
  } else {
    # getting year if POSIX
    doy <- format(x$Time[[1]], format = "%j")
  }
  
  doy <- as.numeric(doy)
  doy
}

# 3.5 subsetProv 

subsetProv <- function(x){
  
  Prov <- x$Province[[1]]
  Prov
  
}

# student data ---------------------

studentData <- function(joinedECCC,dataPairs = 15, save = TRUE, nsplit = 364, overlap=144){

  df <- joinedECCC

  # getting metadata from joined eccc
  city <- subsetCity(df)
  year <- subsetYear(df)
  NAPSID <- subsetNAPS(df)
  Prov <- subsetProv(df)
  
  # removing unnessary columns 
  df <- df %>% 
    select(-c("City", "Province", "Latitude", "Longitude"))
  
  # creating directory for saving .csvs
  folder <- paste(city,"_",NAPSID,"_",year,"/", sep = "")
  dir.create(folder)
  
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
      doy <- subsetDOY(tmp)
      
      fn = paste0(folder,city,"_",NAPSID,"_",year,"_Day",doy,"to",(doy+6),".csv")
      write.csv(tmp,fn,row.names=FALSE)
    }
  } else {
    return(lst)
  }
  
}

