# CHM135 Experiment 1: *The Chemistry of Air Quality* Source Code
by: David Hall, davidross.hall@mail.utoronto.ca

Due to Covid-19, the tradional laboratory component of the first year CHM 135 course had to shift to virtual experiments. Experiment 1 utilises real hourly measurements of atmospheric pollutants (O<sub>3</sub> and NO<sub>3</sub>) to teach students the basics of data analysis, plotting and Microsoft Excel while they explore concepts related to atmospheric pollution. How to generate your own datasets and answer keys is shown below. 

## What it does

CHM 135 students are asked to analyze O<sub>3</sub> and NO<sub>3</sub> winter and summer concentrations from .csv files containing subsets of ECCC hourly data. The code in this repo will (1) generate .csv files containg 7-days worth of continuous measurements from both the winter and summer, (2) save these files in a new directory/folder, and (3) generate an answer key containing a time series and O3 vs. NO2 correlation plots, and some summary statistics. 

This repo contains:
- the R code used to generate:
  - subsets of Environment and Climate Change Canada (ECCC) hourly O<sub>3</sub> and NO<sub>3</sub> measurements from any National Atmospheric Pollution Surveillance (NAPS) station
  - an answer key of each ECCC NAPS data subset
- Example hourly ECCC data from 2018
- Example datasets & answer keys for three Toronto NAPS stations

## Requirements 

The entirety of the data subsetting is done in R and the answer reports are written in Rmarkdown & Tex. If you want to generate more datasets/answer keys you'll need to download R, Rstudio, rmarkdown, tinytex etc.

## Data sources

All of the hourly atmospheric pollutant measurements are taken from the [ECCC NAPS Data repository](http://data.ec.gc.ca/data/air/monitor/national-air-pollution-surveillance-naps-program/Data-Donnees/?lang=en). There is O<sub>3</sub> and NO<sub>3</sub> hourly data (dubbed 'continuous' by ECCC) going back to 1975. You can download whichever .csv file you want. For example [here's a link](http://data.ec.gc.ca/data/air/monitor/national-air-pollution-surveillance-naps-program/Data-Donnees/2018/ContinuousData-DonneesContinu/HourlyData-DonneesHoraires/?lang=en) to the ECCC O<sub>3</sub> and NO<sub>3</sub> data included in this repo.

You'll notice the original ECCC data is arranged in a matrix, wherein hourly data stored across a row, and each row is a day. This is a pain to work with in Excel, so the data is transformed into 'long' format, i.e. each row is an hourly measurement, for the students. 

## To generate your own datasets
 
 1. Download/fork/copy this entire repo to your personal computer 
  - forking it with Git in RStudio is probably the easiest option
 2. Open the *CHM135_Exp1Data.Rproj* in RStudio then open the *AutoAnswerReports.R* file.
 3. Once opened, change the parameters to suit your needs.
    - At the top of the script is where you'll pass the details needed to generate reports to the listed variables. 
    - Options include:
      - which O<sub>3</sub> and NO<sub>2</sub> files you're using 
      - the NAPS station ID
      - the number of data pairs (winter & summer, the default is 15) 
      - whether you want to save the data as .csvs (default is TRUE)
4. As long as everything is setup, you can just run this entire script and **in a new directory** specific to the NAPS station and ECCC data year you specified, you'll get the following outputs:
  -  containing the number of .csv subset files you requested
  - a PDF answer report for each data frame. 
  
## Merging answer keys for TAs
  
You can potentially generate 364 ind. .csv files, which means 364 ind. pdf files. While each undergrad gets one .csv, your TAs will not want to sift through this many PDFs. R isn't setup that well to merge PDFs, so **if you want to merge the PDFs and generate a TOC check out [PDFSam](https://pdfsam.org/)**. It's free and a pretty painless way to merge all the answer PDFs into a one. 

## Description of Files

I made use of relative referencing for this code, as a result you can simply download (or fork) this entire repo and run it on your own computer. As long as the ECCC data of your choice is in the parent directory (alongside the code files, more below) you should be fine. 

There are four R scripts:

- **CHM135_Exp1Data.Rproj**: the RStudio project, open everything in this to use the relative referencing stuff. 
- **AutoAnswerReports.R** is the main script which you will run to generate the subset .csv files for students and the answer keys for the TAs. 
  - At the top of the script is where you'll specify the details needed to generate reports. These include which O<sub>3</sub> and NO<sub>2</sub> files you're using, the NAPS station ID, the number of data pairs (winter & summer, default is 15) and whether you want to save the data as .csvs (default is TRUE).
  - You just need to run the entirety of this script to get your .csv and reports. 
- **dataSubsets.R** contains several functions used to generate the student datasets. 
  - *cleanUpECCC* basically transforms the matric layout of ECCC data into 'long'/columnar data. It also converts dates/times to yyyy/mm/dd hh:mm Excel compatible formats. 
- **AnswerKey.Rmd** is the markdown file used to generate the answer keys. 
  
