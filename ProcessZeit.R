# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/zeit")

# Clear the environment by removing any defined objects/functions
rm(list = ls())

#library
library(dplyr)
library(readxl)
library(lubridate)
library(stringr)

#define function for preprocessing


preprocess_zeit <- function(data, categoryString){
  
  #removing unwanted columns
  #web-scraper-order	web-scraper-start-url	URL	URL-href	Title	Date
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
  outlet <- rep("ZeitOnline", nrow(data))
  
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

klimawandel <- read.csv("KlimawandelZeit.csv", sep =";", quote="")
migration <- read.csv("MigrationZeit.csv", sep =";", quote="")
covid <- read.csv("CovidZeit.csv", sep =";", quote="")
ukraine <- read_xlsx("UkraineZeit.xlsx")
arbeitsmarkt <- read.csv("ArbeitsmarktZeit.csv", sep =";", quote="")
digi <- read.csv("DigitalisierungZeit.csv", sep =";", quote="")
bildung <- read.csv("BildungZeit.csv", sep =";", quote="")
rassismus <- read_xlsx("RassismusZeit.xlsx")

homo <- read.csv("HomoEheZeit.csv", sep =";", quote="")
geld <- read.csv("BuergergeldZeit.csv", sep =";", quote="")


#preprocess datafiles
klimawandel <- preprocess_zeit(klimawandel, "Klimawandel")
migration <- preprocess_zeit(migration, "Migration")
covid <- preprocess_zeit(covid, "Coronavirus")
ukraine <- preprocess_zeit(ukraine, "Ukraine")
arbeitsmarkt <- preprocess_zeit(arbeitsmarkt, "Arbeitsmarkt")
digi <- preprocess_zeit(digi, "Digitalisierung")
bildung <- preprocess_zeit(bildung, "Bildung")
rassismus <- preprocess_zeit(rassismus, "Rassismus")

homo <- preprocess_zeit(homo, "Homo-Ehe")
homo <- filter(homo, homo$date >= '2017-06-26')
homo <- filter(homo, homo$date <= '2017-07-10')

geld <- preprocess_zeit(geld, "Bürgergeld")
geld <- filter(geld, geld$date >= '2022-09-01')
geld <- filter(geld, geld$date <= '2023-01-08')


#write datafiles to file 

# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/HeadlinesFinal")

write.csv(klimawandel, file ="KlimawandelZeit.csv")
write.csv(migration, file ="MigrationlZeit.csv")
write.csv(covid, file ="CovidZeit.csv")
write.csv(ukraine, file ="UkraineZeit.csv")
write.csv(arbeitsmarkt, file ="ArbeitsmarktZeit.csv")
write.csv(digi, file ="DigitalisierungZeit.csv")
write.csv(bildung, file ="BildungZeit.csv")
write.csv(rassismus, file ="RassismusZeit.csv")
write.csv(homo, file ="HomoEheZeit.csv")
write.csv(geld, file ="BuergergeldZeit.csv")

