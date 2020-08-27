### Genrating master PDF with answer keys to every CHM135 .csv dataset. 

library(stapler)

setwd(paste0(getwd(),"/UploadedToQuercus_Fall2020", sep=""))

#filelist <- list.files(pattern = "\\.csv$")
filelist <- "Toronto_60410_2018_Day206to212.csv"
for (file in filelist) {



### Markdown file needs to be in the same directory as the Uplaoded CHM135 .csv files.
rmarkdown::render(input = "AnswerKey.Rmd",
                  output_file = paste0(gsub(".csv","", file), ".pdf"),
                  params = list(file = file)
                  )
}

### Once all PDFs are created, I just merge them using the Merge function on the Sejda website
###   it also generates a TOC based on the title of each pdf (the file name)
###   website: https://www.sejda.com/merge-pdf