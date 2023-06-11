# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/Spiegel")

# Clear the environment by removing any defined objects/functions
rm(list = ls())

#library
library(dplyr)
library(readxl)
library(lubridate)
library(stringr)

#define function for preprocessing

preprocess_spiegel <- function(data, categoryString){
  
  #removing unwanted columns
  data <- data %>%
    select(media_name, publish_date, title, url)
  
  #rename columns
  data <- data %>%
    rename(outlet = media_name, 
           date = publish_date, 
           title = title, 
           url =url)
  
  #change date into date format
  
  #check class of date value
  #dateExample <- bild_Klimawandel[1,"date"]
  #class(dateExample) #it is a string
  
  data<- data %>% 
    mutate(substr(date,1,10)) %>% #remove time
    mutate(as.Date(date, format="%Y-%m-%d")) #transform to date format
  
  #remove some columns and rename
  data <- data %>%
    select(c(1,3,4,6)) %>%
    rename(date = "as.Date(date, format = \"%Y-%m-%d\")")
  
  #add year column
  #example
  #x <- as.Date("01/01/2009", format = "%m/%d/%Y")
  #x <- year(x)
  #class(x) #is numeric
  
  year<- data %>% 
    transmute(year(date))
  names(year) <- "year"
  
  data <- cbind(data, year)
  
  #add month column
  
  #x <- as.Date("01/01/2009", format = "%m/%d/%Y")
  #x <- format(x, "%m-%Y")
  month <- data %>% 
    transmute(month(date))
  names(month) <- "month"
  
  
  data <- cbind(data, month)
  
  #add category label
  category <- rep(categoryString, nrow(data))
  
  data <- cbind(data, category)
  
  
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
  #"outlet","url","date","year", "month", "category","title" 
  data <- data[, c(1,6,7,3,5,4,2)]
  
  
  #filter by date 
  
  #example
  #%y is without 20
  #data <- data.frame("Id" = c(1:5), 
  #"Date" = as.Date(c("22.05.23", "22.04.22", "22.03.21", "01.01.20", "22.03.19"), 
  #format="%d.%m.%y"))
  #dataNew <- filter(data, data$Date >= '2020-01-01')
  
  data <- filter(data, data$date >= '2013-01-01')
  data <- filter(data, data$date <= '2023-04-30')
  
  return(data)
}



#read in datafiles

klimawandel <- read.csv("KlimawandelSpiegel.csv")
migration <- read.csv("MigrationSpiegel.csv")
covid <- read.csv("CovidSpiegel.csv")
ukraine <- read.csv("UkraineSpiegel.csv")
arbeitsmarkt <- read.csv("ArbeitsmarktSpiegel.csv")
digi <- read.csv("DigitalisierungSpiegel.csv")
bildung <- read.csv("BildungSpiegel.csv")
rassismus <- read.csv("RassismusSpiegel.csv")

homo <- read.csv("HomoEheSpiegel.csv")
geld <- read.csv("BuergergeldSpiegel.csv")


#preprocess datafiles
klimawandel <- preprocess_spiegel(klimawandel, "Klimawandel")
migration <- preprocess_spiegel(migration, "Migration")
covid <- preprocess_spiegel(covid, "Coronavirus")
ukraine <- preprocess_spiegel(ukraine, "Ukraine")
arbeitsmarkt <- preprocess_spiegel(arbeitsmarkt, "Arbeitsmarkt")
digi <- preprocess_spiegel(digi, "Digitalisierung")
bildung <- preprocess_spiegel(bildung, "Bildung")
rassismus <- preprocess_spiegel(rassismus, "Rassismus")

homo <- preprocess_spiegel(homo, "Homo-Ehe")
homo <- filter(homo, homo$date >= '2017-06-26')
homo <- filter(homo, homo$date <= '2017-07-10')

geld <- preprocess_spiegel(geld, "Bürgergeld")
geld <- filter(geld, geld$date >= '2022-09-01')
geld <- filter(geld, geld$date <= '2023-01-08')



#additional dataframe scraped directly from webpage

ukraine2 <- read_xlsx("Ukraine2Spiegel.xlsx")

#filter by date
ukraine2 <- filter(ukraine2, ukraine2$date >= '2013-01-01')
ukraine2 <- filter(ukraine2, ukraine2$date <= '2023-04-30')
  
#add year column
year<- ukraine2 %>% 
  transmute(year(date))
names(year) <- "year"
  
ukraine2 <- cbind(ukraine2, year)
  
#add column month 
month <- ukraine2 %>% 
  transmute(month(date))
names(month) <- "month"
  
ukraine2 <- cbind(ukraine2, month)
  
#add category label
category <- rep("Ukraine", nrow(ukraine2))
  
ukraine2 <- cbind(ukraine2, category)
  
  
#add label outlet ZeitOnline
outlet <- rep("Spiegel", nrow(ukraine2))
ukraine2 <- cbind(ukraine2, outlet)
  
  
#transform title special characters
titleNew <- ukraine2 %>% 
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
  
ukraine2 <-ukraine2[-1] #remove old title
ukraine2 <- cbind(ukraine2, titleNew) #add new title
  
  
#reorder columns
#"date"     "url"      "year"     "month"    "category" "outlet"   "title"   
ukraine2 <- ukraine2[, c(6,5,7,1,4,3,2)]
  
 
  
#combine both ukraine
ukraine <- rbind(ukraine, ukraine2)


#write datafiles to file 

# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/HeadlinesFinal")

write.csv(klimawandel, file ="KlimawandelSpiegel.csv")
write.csv(migration, file ="MigrationlSpiegel.csv")
write.csv(covid, file ="CovidSpiegel.csv")
write.csv(ukraine, file ="UkraineSpiegel.csv")
write.csv(arbeitsmarkt, file ="ArbeitsmarktSpiegel.csv")
write.csv(digi, file ="DigitalisierungSpiegel.csv")
write.csv(bildung, file ="BildungSpiegel.csv")
write.csv(rassismus, file ="RassismusSpiegel.csv")
write.csv(homo, file ="HomoEheSpiegel.csv")
write.csv(geld, file ="BuergergeldSpiegel.csv")

