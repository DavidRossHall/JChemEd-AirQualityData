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

O3 <- readECCC(file = O3_2018)

NO2 <- readECCC(file = NO2_2018)

SO2 <- readECCC(file = SO2_2018)

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
  
  # Create Time column with POSIC timestamp.      
  df <- df %>%
    mutate(Time = paste0(Date, " ", Hour, ":00")) %>%
    mutate(Time = lubridate::parse_date_time(Time, "%Y-%m-%d %H:%M") - lubridate::hours(1)) %>%
    relocate(Time, .after = Longitude) %>%
    select(-c(Date, Hour))
  
  df
    
  }

df

}


# 3. Folder location ------------

folderLocation <- function(x){
  
  city <- x$City[[1]]
  NAPS <- x$NAPS[[1]]
  
  if(is.numeric(x$Time)){
    # if dates stored as Excel timestamp (i.e. numeric)
    date <- as.Date(x$Time[[1]], origin = "1899-12-30")
    year <- as.numeric(format(date,"%Y"))
  } else {
    # getting year if POSIX
    year <- format(x$Time[[1]], format = "%Y")
  }
  # creating directory for saving .csvs
  folder <- paste(city,"_",NAPS,"_", year, "/", sep = "")
  folder
  
}

folderLocation(dfPOSIX)



