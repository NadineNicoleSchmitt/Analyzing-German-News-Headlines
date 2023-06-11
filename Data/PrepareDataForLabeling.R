# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data")

# Clear the environment by removing any defined objects/functions
rm(list = ls())

library(readr)
library(quanteda)
library(text2vec)
library(quanteda.textstats)
library(umap)
library(readxl)

#merging old labels
#load labels
labelOld <- read_xlsx("labelsOld.xlsx")
labelOld <- labelOld[, c(2,11)]

#duplicates 
#labelOld$title[duplicated(labelOld$title)]

labelOld <- filter(labelOld, labelOld$Label <= 1)
unique(labelOld$Label)

labelOld <- labelOld[!duplicated(labelOld$title),]
#test <- unique(labelOld$title)

#load all 8x8=64 files into one dataframe

list_of_files <- list.files(path="C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/HeadlinesFinal",
                            recursive=TRUE,
                            pattern = "\\.csv$",
                            full.names = TRUE)

#headlines <- readr::read_csv(list_of_files, id="file_name")
headlines <- readr::read_csv(list_of_files)

#check na
na <- headlines[!complete.cases(headlines), ]

#remove NAs
headlines <- na.omit(headlines)

#give every observation an id
headlines <- headlines[-1]
id <- c(1:nrow(headlines)) #create unique id's
headlines$id <- id
headlines <- headlines[, c(8,1,2,3,4,5,6,7)] #put it at first column

save(headlines, file= "headlines.Rdata")


#remove errors after face validating
#there are 6903 errors

errorList <- read_xlsx("ErrorList.xlsx") #dataframe with errors
error <- errorList$id #list with id's who have error

#remove them from headlines
headlines <- filter(headlines, !(headlines$id %in% error))

#create new id
headlines <- headlines[-1]
id <- c(1:nrow(headlines)) #create unique id's
headlines$id <- id
headlines <- headlines[, c(8,1,2,3,4,5,6,7)] #put it at first column



#choosing randomly headlines for labeling

#making results fully replicable
set.seed(12345)

headlines$labeling <- sample(c(TRUE, FALSE),
                            nrow(headlines),
                            replace = TRUE,
                            prob = c(.02,.98))
table(headlines$labeling)

headlinesToLabel <- filter(headlines, headlines$labeling == TRUE)

#merge with headlines already labeled
headlinesToLabelWithOldLabel <- merge(headlinesToLabel, labelOld, by = "title", all.x =TRUE)

sum(is.na(headlinesToLabelWithOldLabel$Label))


write.csv(headlinesToLabel, file="headlinesToLabel.csv")
save(headlinesToLabel, file = "headlinesToLabel.Rdata")

write.csv(headlinesToLabelWithOldLabel, file="headlinesToLabelWithOldLabel.csv")

save(headlines, file="headlines.Rdata")
write.csv(headlines, file="headlines.csv")


#merge labels with headlines
load("headlines.Rdata")

#labels 
labels <- read_xlsx("HeadlinesLabeledFinished.xlsx")
labels <- labels[c(3,11)]

labels$Label <- as.factor(labels$Label)

colnames(labels) <- c("id", "human_coding")

headlines <- merge(headlines, labels, by = "id", all.x = TRUE)
save(headlines, file="headlines.Rdata")
