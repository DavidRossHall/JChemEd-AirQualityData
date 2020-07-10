library(ggplot2)
library(ggpubr)
library(dplyr)
library(openxlsx)

### Specify where to generate the awnser key, I simply created a seperate folder with the CSVs uploaded to Quercus
setwd(paste(getwd(),"/UploadedToQuercus", sep = ""))


data <- read.csv("Toronto_60410_2018_Day2to8.csv", header = TRUE)


data <- data %>%
  mutate(Time = convertToDateTime(data$Date, origin = "1900-01-01")) %>%
  filter(O3 != -999) %>%
  filter(NO2 != -999) %>%
  mutate(OX = NO2 + O3)


ggscatter(data, x = "NO2", y = "O3", add="reg.line") +
  stat_cor( aes(label = paste(..rr.label..)),label.x = 0, label.y = 0)+
  stat_regline_equation(label.x = 0, label.y = 1)