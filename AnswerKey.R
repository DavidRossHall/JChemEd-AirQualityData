library(ggplot2)
library(ggpubr)
library(ggpmisc)
library(dplyr)
library(tidyr)
library(openxlsx)
library(RcppRoll)

### Specify where to generate the awnser key, I simply created a seperate folder with the CSVs uploaded to Quercus
setwd(paste(getwd(),"/UploadedToQuercus", sep = ""))


file.list <- list.files( pattern = "\\.csv$", full.names = TRUE)

### Takes in one CHM135 csv files and outputs a single multiplot with Pollutant time series and O3 vs No2 correlation. 
#CHM135Plots <- function(CSVfile){
  
#data <- read.csv(CSVfile, header = TRUE)
data <- read.csv("Toronto_60410_2018_Day9to15.csv", header= TRUE)

data <- data %>%
  mutate(time = convertToDateTime(data$Date, origin = "1900-01-01")) %>%
  filter(O3 != -999) %>%
  filter(NO2 != -999) %>%
  mutate(OX = NO2 + O3)

formula <- y ~ x ### Need to keep this so LM regression appears on plot

### Correlation plot with Linear regression and equation -------------------------
b <- ggplot(data = data, aes(x = NO2, y = O3)) +
  geom_point() + 
  scale_x_continuous(expand = c(0, 0), limits = c(0, NA)) + 
  scale_y_continuous(expand = c(0, 0), limits = c(0, NA)) +
  theme_classic() +
  xlab(bquote('Conc.' ~NO[2]~', ppb')) +
  ylab(bquote('Conc.' ~O[3]~', ppb')) +
  geom_smooth(method = "lm", formula = formula, se = FALSE) +
  stat_poly_eq(aes(label =  paste(stat(eq.label), stat(rr.label), sep = "*\", \"*")),
               formula = formula, rr.digits = 4 , parse = TRUE, label.y = 0.05)
### -----------------------------------------------------------------------------

### Making data tidyR friendly --------------------------------------------------
dataCol <- data %>%
  select(-c("Date", "temperature")) %>%
  pivot_longer(-time, names_to = "pollutant", values_to = "concentration")
### -----------------------------------------------------------------------------


### Time series plot of NO2, O3, and OX ------------------------------------------
a <- ggplot(data = dataCol, aes(x = time, y = concentration, color = pollutant)) +
  geom_line(size = 1) +
  theme_classic() +
  theme(legend.position = "bottom") +
  ylab(bquote('Conc., ppb')) +
  xlab(bquote('Time')) 
### -----------------------------------------------------------------------------



### Summary Stats for 1hr pollutant concentrations ------------------------------
stable <- desc_statby(dataCol, measure.var = "concentration", grps = "pollutant")

stable <- stable[, c("pollutant", "mean", "sd", "median", "min", "max")]

stable.p <- ggtexttable(stable, rows = NULL, theme = ttheme("light"))
c <- stable.p %>%
  tab_add_hline(at.row = c(1, 2), row.side = "top", linewidth = 3, linetype = 1) %>%
  tab_add_hline(at.row = c(4), row.side = "bottom", linewidth = 3, linetype = 1)

### -----------------------------------------------------------------------------



### Min and Max of 8 hr rolling average of 3 pollutants ------------------------

data$NO2_8hr <- roll_mean(data$NO2, 8, na.rm = TRUE, fill = NA, align = 'right')
data$O3_8hr <- roll_mean(data$O3, 8, na.rm = TRUE, fill = NA, align = 'right')
data$OX_8hr <- roll_mean(data$OX, 8, na.rm = TRUE, fill = NA, align = 'right')

data8hrCol <- data %>%
  select(c("time", "NO2_8hr", "O3_8hr", "OX_8hr")) %>%
  pivot_longer(-time, names_to = "pollutant", values_to = "meanConc_8hr") %>%
  filter(!is.na(meanConc_8hr))

title8hr <- "Min and max 8hr mean concentrations"

stable8hr <- desc_statby(data8hrCol, measure.var = "meanConc_8hr", grps = "pollutant")
stable8hr <- stable8hr[, c("pollutant", "min", "max")]
stable8hr.p <- ggtexttable(stable8hr, rows = NULL, theme = ttheme("light"))
d <- stable8hr.p %>%
  tab_add_hline(at.row = c(1, 2), row.side = "top", linewidth = 3, linetype = 1) %>%
  tab_add_hline(at.row = c(4), row.side = "bottom", linewidth = 3, linetype = 1)

### -----------------------------------------------------------------------------


#ggarrange(ggarrange(q, p, ncol = 2, labels = c("A", "B")),
#          stable.p, stable8hr.p,# Second row with box and dot plots
#          nrow = 3
#          )

ggarrange(a,b,c,d, ncol = 2, nrow = 2, labels = c("A", "B", "C", "D"))

#}

