# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/Welt")

# Clear the environment by removing any defined objects/functions
rm(list = ls())

#library
library(dplyr)
library(readxl)
library(lubridate)
library(stringr)

#define function for preprocessing

preprocess_welt <- function(data, categoryString){
  
  #removing unwanted columns
  ##web-scraper-order	web-scraper-start-url	Pagination	Link	Link-href	Title	Date
  data <- data %>%
    select('Link-href', Title, Date)
  
  #rename columns
  data <- data %>%
    rename(date = Date, 
           title = Title, 
           url ='Link-href')
  
  #modify data column
  #a <- "Veröffentlicht am 19.03.2022"
  #a <- substr(a,19,28)
  #a <- as.Date(a, format ="%d.%m.%Y")
  
  data<- data %>% 
    mutate(substr(date,19,28)) #remove "Veröffentlicht am"
  
  data <- data[-3] #remove old date
  data <- rename(data, date =`substr(date, 19, 28)`)
  
  data <- data %>%  
    mutate(as.Date(date, format="%d.%m.%Y")) #transform to date format
  
  data <- data[-3] #remove old date
  data <- rename(data, date =`as.Date(date, format = \"%d.%m.%Y\")`)
  
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
  
  
  #add label outlet Welt
  outlet <- rep("Welt", nrow(data))
  
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
  
  #filter by date 
  data <- filter(data, data$date >= '2013-01-01')
  data <- filter(data, data$date <= '2023-04-30')
  
  #reorder columns
  #"url"      "date"     "year"     "month"    "category" "outlet"   "title"
  data <- data[, c(6,5,7,2,4,3,1)]
  return(data)
}


#read in datafiles

klimawandel <- read_xlsx("KlimawandelWelt.xlsx")
migration <- read_xlsx("MigrationWelt.xlsx")
covid <- read_xlsx("CovidWelt.xlsx")
ukraine <- read_xlsx("UkraineWelt.xlsx")
arbeitsmarkt <- read_xlsx("ArbeitsmarktWelt.xlsx")
digi <- read_xlsx("DigitalisierungWelt.xlsx")
bildung <- read_xlsx("BildungWelt.xlsx")
rassismus <- read_xlsx("RassismusWelt.xlsx")

homo <- read_xlsx("HomoEheWelt.xlsx")
geld <- read_xlsx("BuergergeldWelt.xlsx")


#preprocess datafiles
klimawandel <- preprocess_welt(klimawandel, "Klimawandel")
migration <- preprocess_welt(migration, "Migration")
covid <- preprocess_welt(covid, "Coronavirus")
ukraine <- preprocess_welt(ukraine, "Ukraine")
arbeitsmarkt <- preprocess_welt(arbeitsmarkt, "Arbeitsmarkt")
digi <- preprocess_welt(digi, "Digitalisierung")
bildung <- preprocess_welt(bildung, "Bildung")
rassismus <- preprocess_welt(rassismus, "Rassismus")

homo <- preprocess_welt(homo, "Homo-Ehe")
homo <- filter(homo, homo$date >= '2017-06-26')
homo <- filter(homo, homo$date <= '2017-07-10')

geld <- preprocess_welt(geld, "Bürgergeld")
geld <- filter(geld, geld$date >= '2022-09-01')
geld <- filter(geld, geld$date <= '2023-01-08')


#write datafiles to file 

# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/HeadlinesFinal")

write.csv(klimawandel, file ="KlimawandelWelt.csv")
write.csv(migration, file ="MigrationlWelt.csv")
write.csv(covid, file ="CovidWelt.csv")
write.csv(ukraine, file ="UkraineWelt.csv")
write.csv(arbeitsmarkt, file ="ArbeitsmarktWelt.csv")
write.csv(digi, file ="DigitalisierungWelt.csv")
write.csv(bildung, file ="BildungWelt.csv")
write.csv(rassismus, file ="RassismusWelt.csv")
write.csv(homo, file ="HomoEheWelt.csv")
write.csv(geld, file ="BuergergeldWelt.csv")

