# CHM135 Experiment 1: *The Chemistry of Air Quality* Source Code
by: David Hall, davidross.hall@mail.utoronto.ca

Due to Covid-19, the tradional laboratory component of the first year CHM 135 course had to shift to virtual experiments. Experiment 1 utilises real hourly measurements of atmospheric pollutants (O<sub>3</sub> and NO<sub>3</sub>) to teach students the basics of data analysis, plotting and Microsoft Excel while they explore concepts related to atmospheric pollution. How to run the code is described below. 

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

All of the hourly atmospheric pollutant measurements are taken from the [ECCC NAPS Data repository](http://data.ec.gc.ca/data/air/monitor/national-air-pollution-surveillance-naps-program/Data-Donnees/?lang=en). There is O<sub>3</sub> and NO<sub>3</sub> hourly (dubbed 'continuous' by ECCC) going back to 1975. You can download whichever .csv file you want. For example [here's a link](http://data.ec.gc.ca/data/air/monitor/national-air-pollution-surveillance-naps-program/Data-Donnees/2018/ContinuousData-DonneesContinu/HourlyData-DonneesHoraires/?lang=en) to the ECCC O<sub>3</sub> and NO<sub>3</sub> data included in this repo.

## Generating your own datasets and answer keys

I made use of relative referencing for this code, as a result you can simply download (or fork) this entire repo and run it on your own computer. As long as the ECCC data of your choice is in the parent directory (alongside the code  files, more below) you should be fine. 

There are three R scripts, but you should only need to worry about one of them:

- **AutoAnswerReports.R** is the main script which you will run to generate the subset .csv files for students and the answer keys for the TAs. 
  - At the top of the script is where you'll specify the details needed to generate reports. These include which O<sub>3</sub> and NO<sub>2</sub> files you're using, the NAPS station ID, the number of data pairs (winter & summer, default is 15) and whether you want to save the data as .csvs (default is TRUE).
