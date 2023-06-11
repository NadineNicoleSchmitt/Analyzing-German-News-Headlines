# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/SZ")

# Clear the environment by removing any defined objects/functions
rm(list = ls())

#library
library(dplyr)
library(readxl)
library(lubridate)
library(stringr)

#define function for preprocessing


preprocess_sz <- function(data, categoryString){
  
  #removing unwanted columns
  #web-scraper-order	web-scraper-start-url	URL	URL-href	Title	Date
  data <- data %>%
    select('URL-href', Title, Date)
  
  #rename columns
  data <- data %>%
    rename(date = Date, 
           title = Title, 
           url ='URL-href')
  
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
  outlet <- rep("SZ", nrow(data))
  
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

klimawandel <- read_xlsx("KlimawandelSZ.xlsx")
migration <- read_xlsx("MigrationSZ.xlsx")
covid <- read_xlsx("CovidSZ.xlsx")
ukraine <- read_xlsx("UkraineSZ.xlsx")
arbeitsmarkt <- read_xlsx("ArbeitsmarktSZ.xlsx")
digi <- read_xlsx("DigitalisierungSZ.xlsx")
bildung <- read_xlsx("BildungSZ.xlsx")
rassismus <- read_xlsx("RassismusSZ.xlsx")

homo <- read_xlsx("HomoEheSZ.xlsx")
geld <- read_xlsx("BuergergeldSZ.xlsx")


#preprocess datafiles
klimawandel <- preprocess_sz(klimawandel, "Klimawandel")
migration <- preprocess_sz(migration, "Migration")
covid <- preprocess_sz(covid, "Coronavirus")
ukraine <- preprocess_sz(ukraine, "Ukraine")
arbeitsmarkt <- preprocess_sz(arbeitsmarkt, "Arbeitsmarkt")
digi <- preprocess_sz(digi, "Digitalisierung")
bildung <- preprocess_sz(bildung, "Bildung")
rassismus <- preprocess_sz(rassismus, "Rassismus")

homo <- preprocess_sz(homo, "Homo-Ehe")
homo <- filter(homo, homo$date >= '2017-06-26')
homo <- filter(homo, homo$date <= '2017-07-10')

geld <- preprocess_sz(geld, "Bürgergeld")
geld <- filter(geld, geld$date >= '2022-09-01')
geld <- filter(geld, geld$date <= '2023-01-08')


#write datafiles to file 

# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/HeadlinesFinal")

write.csv(klimawandel, file ="KlimawandelSZ.csv")
write.csv(migration, file ="MigrationlSZ.csv")
write.csv(covid, file ="CovidSZ.csv")
write.csv(ukraine, file ="UkraineSZ.csv")
write.csv(arbeitsmarkt, file ="ArbeitsmarktSZ.csv")
write.csv(digi, file ="DigitalisierungSZ.csv")
write.csv(bildung, file ="BildungSZ.csv")
write.csv(rassismus, file ="RassismusSZ.csv")
write.csv(homo, file ="HomoEheSZ.csv")
write.csv(geld, file ="BuergergeldSZ.csv")

