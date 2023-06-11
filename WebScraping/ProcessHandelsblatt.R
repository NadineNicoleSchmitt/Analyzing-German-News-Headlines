# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/Handelsblatt")

# Clear the environment by removing any defined objects/functions
rm(list = ls())

#library
library(dplyr)
library(readxl)
library(lubridate)
library(stringr)

#define function for preprocessing


preprocess_hb <- function(data, categoryString){
  
  #removing unwanted columns
  #[1] "web.scraper.order"     "web.scraper.start.url" "Headline"              "Date"                 
  #[5] "URL"                   "URL.href"              "X" 
  data <- data %>%
    select('URL.href', Headline, Date)
  
  #rename columns
  data <- data %>%
    rename(date = Date, 
           title = Headline, 
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
  outlet <- rep("Handelsblatt", nrow(data))
  
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

klimawandel <- read.csv("KlimawandelHandelsblatt.csv", sep =";", quote="")
migration <- read.csv("MigrationHandelsblatt.csv", sep =";", quote="")
covid <- read.csv("CovidHandelsblatt.csv", sep =";", quote="")
ukraine <- read.csv("UkraineHandelsblatt.csv", sep =";", quote="")
arbeitsmarkt <- read.csv("ArbeitsmarktHandelsblatt.csv", sep =";", quote="")
digi <- read.csv("DigitalisierungHandelsblatt.csv", sep =";", quote="")
bildung <- read.csv("BildungHandelsblatt.csv", sep =";", quote="")
rassismus <- read.csv("RassismusHandelsblatt.csv", sep =";", quote="")

homo <- read.csv("HomoEheHandelsblatt.csv", sep =";", quote="")
geld <- read.csv("BuergergeldHandelsblatt.csv", sep =";", quote="")


#preprocess datafiles
klimawandel <- preprocess_hb(klimawandel, "Klimawandel")
migration <- preprocess_hb(migration, "Migration")
covid <- preprocess_hb(covid, "Coronavirus")
ukraine <- preprocess_hb(ukraine, "Ukraine")
arbeitsmarkt <- preprocess_hb(arbeitsmarkt, "Arbeitsmarkt")
digi <- preprocess_hb(digi, "Digitalisierung")
bildung <- preprocess_hb(bildung, "Bildung")
rassismus <- preprocess_hb(rassismus, "Rassismus")

homo <- preprocess_hb(homo, "Homo-Ehe")
homo <- filter(homo, homo$date >= '2017-06-26')
homo <- filter(homo, homo$date <= '2017-07-10')

geld <- preprocess_hb(geld, "Bürgergeld")
geld <- filter(geld, geld$date >= '2022-09-01')
geld <- filter(geld, geld$date <= '2023-01-08')


#write datafiles to file 

# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/HeadlinesFinal")

write.csv(klimawandel, file ="KlimawandelHandelsblatt.csv")
write.csv(migration, file ="MigrationlHandelsblatt.csv")
write.csv(covid, file ="CovidHandelsblatt.csv")
write.csv(ukraine, file ="UkraineHandelsblatt.csv")
write.csv(arbeitsmarkt, file ="ArbeitsmarktHandelsblatt.csv")
write.csv(digi, file ="DigitalisierungHandelsblatt.csv")
write.csv(bildung, file ="BildungHandelsblatt.csv")
write.csv(rassismus, file ="RassismusHandelsblatt.csv")
write.csv(homo, file ="HomoEheHandelsblatt.csv")
write.csv(geld, file ="BuergergeldHandelsblatt.csv")

