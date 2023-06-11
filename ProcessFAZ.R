# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/FAZ")

# Clear the environment by removing any defined objects/functions
rm(list = ls())

#library
library(dplyr)
library(readxl)
library(lubridate)
library(stringr)


#define function for preprocessing

preprocess_FAZ <- function(data, categoryString){
  
  #removing unwanted columns
  #"web.scraper.order"     "web.scraper.start.url" "Title"                 "Date"                 
  #"URL"                   "URL.href"              "X"  
  data <- data %>%
    select('URL.href', Title, Date)
  
  #rename columns
  data <- data %>%
    rename(date = Date, 
           title = Title, 
           url ='URL.href')
  
  #modify date column
  
  #transform date into date format
  data<- data %>% 
    mutate(date = as.Date(date, format ="%d.%m.%Y")) #transform to date format
  
  
  #filter by date
  data <- filter(data, data$date >= '2013-01-01')
  data <- filter(data, data$date <= '2023-04-30')
  
  #add year column
  year<- data %>% 
    transmute(year(date))
  names(year) <- "year"
  
  data <- cbind(data, year)
  
  #add column month 
  month <- data %>% 
    transmute(month(date))
  names(month) <- "month"
  
  data <- cbind(data, month)
  
  #add category label
  category <- rep(categoryString, nrow(data))
  
  data <- cbind(data, category)
  
  
  #add label outlet ZeitOnline
  outlet <- rep("FAZ", nrow(data))
  
  data <- cbind(data, outlet)
  
  
  #transform title special characters
  #replace('Ã¼','ü')
  #replace('Ã¶','ö')
  #replace('Ã¤','ä')
  #replace('ÃŸ','ß')
  #replace('â€™','’')
  #replace('Ã–','Ö')
  #replace('Ãœ','Ü')
  #replace('Ã„','Ä')
  #replace(â€ž, ")
  #replace(â€œ, ")
  #replace('â€“','–')
  
  titleNew <- data %>% 
    transmute(title = str_replace_all(title, "Ã¼", "ü")) %>%
    transmute(title = str_replace_all(title, "Ã¶", "ö")) %>%
    transmute(title =str_replace_all(title, "Ã¤", "ä")) %>%
    transmute(title =str_replace_all(title, "ÃŸ", "ß")) %>%
    transmute(title =str_replace_all(title, "â€™", "’")) %>%
    transmute(title =str_replace_all(title, "Ã–", "Ö")) %>%
    transmute(title =str_replace_all(title, "Ãœ", "Ü")) %>%
    transmute(title =str_replace_all(title, "Ã„", "Ä")) %>%
    transmute(title =str_replace_all(title, "â€ž", "’")) %>%
    transmute(title =str_replace_all(title, "â€œ", "’")) %>%
    transmute(title =str_replace_all(title, "Â", "")) %>%
    transmute(title =str_replace_all(title, "â€“", "-")) 
  
  data <- data[-2] #remove old title
  data <- cbind(data, titleNew) #add new title
  
  
  #reorder columns
  #"url"      "date"     "year"     "month"    "category" "outlet"   "title"  
  data <- data[, c(6,5,7,2,4,3,1)]
  
  return(data)
  
}



#read in datafiles

klimawandel <- read.csv("KlimawandelFAZ.csv", sep =";")
migration <- read.csv("MigrationFAZ.csv", sep =";")
covid <- read.csv("CovidFAZ.csv", sep =";")
ukraine <- read_xlsx("UkraineFAZ.xlsx")
arbeitsmarkt <- read.csv("ArbeitsmarktFAZ.csv", sep =";")
digi <- read.csv("DigitalisierungFAZ.csv", sep =";")
bildung <- read.csv("BildungFAZ.csv", sep =";")
rassismus <- read.csv("RassismusFAZ.csv", sep =";")

homo <- read.csv("HomoEheFAZ.csv", sep =";")
geld <- read.csv("BuergergeldFAZ.csv", sep =";")


#preprocess datafiles
klimawandel <- preprocess_FAZ(klimawandel, "Klimawandel")
migration <- preprocess_FAZ(migration, "Migration")
covid <- preprocess_FAZ(covid, "Coronavirus")
ukraine <- preprocess_FAZ(ukraine, "Ukraine")
arbeitsmarkt <- preprocess_FAZ(arbeitsmarkt, "Arbeitsmarkt")
digi <- preprocess_FAZ(digi, "Digitalisierung")
bildung <- preprocess_FAZ(bildung, "Bildung")
rassismus <- preprocess_FAZ(rassismus, "Rassismus")

homo <- preprocess_FAZ(homo, "Homo-Ehe")
homo <- filter(homo, homo$date >= '2017-06-26')
homo <- filter(homo, homo$date <= '2017-07-10')

geld <- preprocess_FAZ(geld, "Bürgergeld")
geld <- filter(geld, geld$date >= '2022-09-01')
geld <- filter(geld, geld$date <= '2023-01-08')


#write datafiles to file 

# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/HeadlinesFinal")

write.csv(klimawandel, file ="KlimawandelFAZ.csv")
write.csv(migration, file ="MigrationlFAZ.csv")
write.csv(covid, file ="CovidFAZ.csv")
write.csv(ukraine, file ="UkraineFAZ.csv")
write.csv(arbeitsmarkt, file ="ArbeitsmarktFAZ.csv")
write.csv(digi, file ="DigitalisierungFAZ.csv")
write.csv(bildung, file ="BildungFAZ.csv")
write.csv(rassismus, file ="RassismusFAZ.csv")
write.csv(homo, file ="HomoEheFAZ.csv")
write.csv(geld, file ="BuergergeldFAZ.csv")
