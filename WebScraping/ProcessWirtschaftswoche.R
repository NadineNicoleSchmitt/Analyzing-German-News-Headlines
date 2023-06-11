# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/Wirtschaftswoche")

# Clear the environment by removing any defined objects/functions
rm(list = ls())

#library
library(dplyr)
library(readxl)
library(lubridate)
library(stringr)

#define function for preprocessing


preprocess_ww <- function(data, categoryString){
  
  #removing unwanted columns
  #web-scraper-order	web-scraper-start-url	Link	Link.href	Title	Date
  data <- data %>%
    select('Link.href', Title, Date)
  
  #rename columns
  data <- data %>%
    rename(date = Date, 
           title = Title, 
           url ='Link.href')
  
  
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
  
  
  #add label outlet Wirtschaftswoche
  outlet <- rep("Wirtschaftswoche", nrow(data))
  
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

klimawandel <- read.csv("KlimawandelWirtschaftswoche.csv", sep =";", quote="")
migration <- read.csv("MigrationWirtschaftswoche.csv", sep =";", quote="")
covid <- read.csv("CovidWirtschaftswoche.csv", sep =";", quote="")
ukraine <- read.csv("UkraineWirtschaftswoche.csv", sep =";", quote="")
arbeitsmarkt <- read.csv("ArbeitsmarktWirtschaftswoche.csv", sep =";", quote="")
digi <- read.csv("DigitalisierungWirtschaftswoche.csv", sep =";", quote="")
bildung <- read.csv("BildungWirtschaftswoche.csv", sep =";", quote="")
rassismus <- read.csv("RassismusWirtschaftswoche.csv", sep =";", quote="")

homo <- read.csv("HomoEheWirtschaftswoche.csv", sep =";", quote="")
geld <- read.csv("BuergergeldWirtschaftswoche.csv", sep =";", quote="")


#preprocess datafiles
klimawandel <- preprocess_ww(klimawandel, "Klimawandel")
migration <- preprocess_ww(migration, "Migration")
covid <- preprocess_ww(covid, "Coronavirus")
ukraine <- preprocess_ww(ukraine, "Ukraine")
arbeitsmarkt <- preprocess_ww(arbeitsmarkt, "Arbeitsmarkt")
digi <- preprocess_ww(digi, "Digitalisierung")
bildung <- preprocess_ww(bildung, "Bildung")
rassismus <- preprocess_ww(rassismus, "Rassismus")

homo <- preprocess_ww(homo, "Homo-Ehe")
homo <- filter(homo, homo$date >= '2017-06-26')
homo <- filter(homo, homo$date <= '2017-07-10')

geld <- preprocess_ww(geld, "Bürgergeld")
geld <- filter(geld, geld$date >= '2022-09-01')
geld <- filter(geld, geld$date <= '2023-01-08')


#write datafiles to file 

# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/HeadlinesFinal")

write.csv(klimawandel, file ="KlimawandelWirtschaftswoche.csv")
write.csv(migration, file ="MigrationlWirtschaftswoche.csv")
write.csv(covid, file ="CovidWirtschaftswoche.csv")
write.csv(ukraine, file ="UkraineWirtschaftswoche.csv")
write.csv(arbeitsmarkt, file ="ArbeitsmarktWirtschaftswoche.csv")
write.csv(digi, file ="DigitalisierungWirtschaftswoche.csv")
write.csv(bildung, file ="BildungWirtschaftswoche.csv")
write.csv(rassismus, file ="RassismusWirtschaftswoche.csv")
write.csv(homo, file ="HomoEheWirtschaftswoche.csv")
write.csv(geld, file ="BuergergeldWirtschaftswoche.csv")

