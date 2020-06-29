library(dplyr)
library(tidyr)
library(stringr)
library(anytime)

### Takes a single ECCC .csv file, and transforms it into Excel compatibale columnar data
cleanupECCC <- function(file){
### Removing the blurb at the top of the ECCC .csv's that expain '-999' values
### & cleaning up default ECCC headers  
df = read.csv(file, skip = 7, header = T)
colnames(df) <- gsub("\\..*","",colnames(df))

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

dfO3 <- cleanupECCC("O3_2018.csv")
dfNO2 <- cleanupECCC("NO2_2018.csv")
head(dfNO2)
head(dfO3)

dfO3