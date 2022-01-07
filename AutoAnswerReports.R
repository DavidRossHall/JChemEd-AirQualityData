### 2020-08-27, David Hall, davidross.hall@mail.utoronto.ca

# This script generates .csv subsets of ECCC O3 and NO2 hourly data.
# An answer key for each .csv is also generated for the CHM 135 Experiment 1. 


# 1. Loading library and functions ---------------------------------
library(tidyverse)
source("dataSubsetsV2.R") # needs to be in the same directory

# 2. Parameters used for the generation of student datasets & answer keys ---------------

O3 <- "raw-data/O3_2018.csv"   # ECCC hourly O3 file
NO2 <- "raw-data/NO2_2018.csv" # ECCC hourly NO2 report
NAPSID <- 60433       # ECCC NAPSID, i.e. location you want data from.
excelTimestamp <- FALSE

dataPairs <- 15       # number of paired winter/summer datasets.
save <- TRUE          # TRUE = save files in new directory, FALSE = output list of student data subsets dfs




# 3. Generating datasets, if save == TRUE, saves datasets as .csv in new folder ---------------

cityECCC <- joinECCC(O3 = O3, 
                     NO2 = NO2, 
                     NAPSID = NAPSID, 
                     excelTimestamp = excelTimestamp)

studentData(joinedECCC =cityECCC,
                   dataPairs = dataPairs,
                   save = save)




# 4. Generating answer keys for saved datasets.

  folder <- folderLocation(cityECCC)
  #setwd(paste0(getwd(),"/",folder, sep=""))
  filelist <- list.files(path = folder, pattern = "\\.csv$", full.names = TRUE)

  
  for (file in filelist) {
    
    
    
    ### Markdown file needs to be in the same directory as the Uplaoded CHM135 .csv files.
    rmarkdown::render(input = "AnswerKeyV2.Rmd",
                      output_file = paste0(gsub(".csv","", file), ".pdf"),
                      params = list(file = file,
                                    title = sub(".*/", "", file))
    )
  }

# 5. To merge PDF use an external application such as PDFSam
    # download here: https://pdfsam.org/
  