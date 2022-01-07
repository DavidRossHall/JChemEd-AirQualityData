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



O3 <- readECCC(file = O3_2018)

NO2 <- readECCC(file = NO2_2018)

SO2 <- readECCC(file = SO2_2018)

dat <- NO2 %>%
  inner_join(O3) %>%
  pivot_longer(cols = starts_with("H"),
               names_to = c("Hour", "Pollutant"),
               names_sep = "_",
               values_to = "Concentration")

df5 <- df4 %>%
  pivot_longer(cols = starts_with("H"))





