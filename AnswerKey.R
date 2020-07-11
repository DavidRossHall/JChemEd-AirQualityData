library(ggplot2)
library(ggpubr)
library(ggpmisc)
library(dplyr)
library(tidyr)
library(openxlsx)

### Specify where to generate the awnser key, I simply created a seperate folder with the CSVs uploaded to Quercus
setwd(paste(getwd(),"/UploadedToQuercus", sep = ""))


file.list <- list.files( pattern = "\\.csv$", full.names = TRUE)

### Takes in one CHM135 csv files and outputs a single multiplot with Pollutant time series and O3 vs No2 correlation. 
CHM135Plots <- function(CSVfile){
  
data <- read.csv(CSVfile, header = TRUE)

data <- data %>%
  mutate(time = convertToDateTime(data$Date, origin = "1900-01-01")) %>%
  filter(O3 != -999) %>%
  filter(NO2 != -999) %>%
  mutate(OX = NO2 + O3)

formula <- y ~ x ### Need to keep this so LM regression appears on plot

p <- ggplot(data = data, aes(x = NO2, y = O3)) +
  geom_point() + 
  scale_x_continuous(expand = c(0, 0), limits = c(0, NA)) + 
  scale_y_continuous(expand = c(0, 0), limits = c(0, NA)) +
  theme_classic() +
  xlab(bquote('Conc.' ~NO[2]~', ppb')) +
  ylab(bquote('Conc.' ~O[3]~', ppb')) +
  geom_smooth(method = "lm", formula = formula, se = FALSE) +
  stat_poly_eq(aes(label =  paste(stat(eq.label), stat(rr.label), sep = "*\", \"*")),
               formula = formula, rr.digits = 4 , parse = TRUE, label.y = 0.05)

dataCol <- data %>%
  select(-c("Date", "temperature")) %>%
  pivot_longer(-time, names_to = "pollutant", values_to = "concentration")

q <- ggplot(data = dataCol, aes(x = time, y = concentration, color = pollutant)) +
  geom_line(size = 1) +
  theme_classic() +
  ylab(bquote('Conc., ppb')) +
  xlab(bquote('Time')) 

ggarrange(q, p, 
          labels = c("A", "B"), 
          ncol = 1, nrow = 2)
}
