# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/HeadlinesFinalArticle")

# Clear the environment by removing any defined objects/functions
rm(list = ls())


library(rvest)
library(tidyverse)
library(jsonlite)
library(xml2)
library(readr)
library(stringr)
library(quanteda)
library(quanteda.textmodels)
library(quanteda.textplots)
library(purrr)
library(readxl)



##############Functions for each Outlet###################################################################


getSpiegel <- function(url) {
  
  #url <- "https://www.spiegel.de/politik/deutschland/cdu-chef-friedrich-merz-lehnt-buergergeld-trotz-aenderungen-weiter-ab-a-eb43b166-b564-42a0-b543-84ae5d60a574#ref=rss"
  print(url) 
  #//*[@id="Inhalt"]/article/div/section[2]/div[2]/div[1]/div[1]/div/p
  tsXpath <- "//*[@id='Inhalt']/*"
  
  #read the url
  htmlPage <- read_html(url)
  
  #get the text lines from the article
  textLines <- htmlPage %>% html_elements(xpath =tsXpath)
  
  #identify all nodes with text
  textNodes <- textLines %>% xml_find_all('.//p') 
  
  #identify elements of specific class, we don't need
  textNodesRemove1 <-  html_elements(htmlPage, ".font-sansUI")
  
  #now remove unwanted nodes
  textNodes <- textNodes[!(textNodes %in% textNodesRemove1)]
  
  
  #get the final text
  text <- textNodes %>% xml2::xml_text()
  
  #remove header/tail
  textFinal <- text[2:(length(text))]
  
  #collaps all nodes together in one single string
  final <- paste(textFinal,collapse= " ")
  return(final)
} #getSpiegel

getTagesspiegel <- function(url) {
  
  #htmlPage <- "https://www.tagesspiegel.de/politik/eine-einigung-die-keine-ist-so-reagieren-die-kommunen-auf-den-bund-lander-gipfel-9802388.html"
  #//*[@id="story-elements"]/p[1]
  
  tsXpath <- "//*[@id='story-elements']/*"
  #print(url)
  
  #read the url
  htmlPage <- read_html(url)
  
  #get the text lines from the article
  textLines <- htmlPage %>% html_elements(xpath =tsXpath)
  
  #identify all nodes with text
  textNodesAll <- textLines %>% xml_find_all('//p') 
  
  #identify nodes we don't want in our analysis
  textNodesRemove <- textLines %>% xml_find_all('.//p')
  
  #neuX <- xa[!(xa %in% xr)]
  #remove unwanted nodeset 
  textNodesFinal <- textNodesAll[!(textNodesAll %in% textNodesRemove)] 
  
  #get the final text
  text <- textNodesFinal %>% xml2::xml_text()
  
  #remove header/tail
  textFinal <- text[3:(length(text)-2)]
  
  #collaps all nodes together in one single string
  final <- paste(textFinal,collapse= " ")
  return(final)
} #getTagesspiegel

isBildPlus <- function(s) {
  return(grepl("Lesen Sie .*mit BILDplus",s))
}

getBild <- function(url) {
  
  #url <- "https://www.bild.de/geld/wirtschaft/wirtschaft/handwerker-kritik-an-heils-buergergeld-plaenen-hartz-hammer-81297570.bild.html"
  print(url) 
  
  #//*[@id="__layout"]/div/div/div[2]/main/article/div[4]/p[3]/text()
  tsXpath <- "//*[@id='__layout']/*"
  
  
  #read the url
  htmlPage <- read_html(url)
  
  #get the text lines from the article
  textLines <- htmlPage %>% html_elements(xpath =tsXpath)
  
  #identify all nodes with text
  textNodesAll <- textLines %>% xml_find_all('//p')
  
  #identify "BILDPlus article
  ibv <- isBildPlus(textNodesAll %>% xml2::xml_text())
  textNodesRemoveFirst <-  keep(textNodesAll, ibv)
  
  #identify elements of specific class, we don't need
  textNodesRemove1 <-  html_elements(htmlPage, ".red-breaking-news__text")
  textNodesRemove2 <-  html_elements(htmlPage, ".teaser__text")
  textNodesRemove3 <-  html_elements(htmlPage, ".mtl__heading")
  
  
  #now remove unwanted nodes
  textNodes <- textNodesAll[!(textNodesAll %in% textNodesRemoveFirst)]
  textNodes <- textNodes[!(textNodes %in% textNodesRemove1)]
  textNodes <- textNodes[!(textNodes %in% textNodesRemove2)]
  textNodes <- textNodes[!(textNodes %in% textNodesRemove3)]
  
  #get the text
  text <- textNodes %>% xml2::xml_text()
  
  #remove header/tail
  textFinal <- text[2:(length(text))]
  
  #collaps all nodes together in one single string
  final <- paste(textFinal,collapse= " ")
  return(final)
} #getBild

getWelt <- function(url) {
  
  #url <- "https://www.welt.de/politik/deutschland/article242075165/Umfrage-Mehrheit-der-Deutschen-findet-Buergergeld-eher-schlecht.html"
  print(url) 
  
  #//*[@id="top"]/div[3]/main/article/div[1]/header/div[5]/div/div
  tsXpath <- "//*[@id='top']/*"
  
  #read the url
  htmlPage <- read_html(url)
  
  #get the text lines from the article
  textLines <- htmlPage %>% html_elements(xpath =tsXpath)
  
  #identify all nodes with text
  #textNodesAll <- textLines %>% xml_find_all('.//p')
  articleNodes <- html_elements(htmlPage, ".c-article-text")
  textNodesAll <- articleNodes %>% xml_find_all('.//p')
  
  
  #identify elements of specific class, we don't need
  textNodesRemove1 <-  html_elements(htmlPage, ".c-page-footer__text")
  textNodesRemove2 <-  html_elements(htmlPage, "em")
  
  
  #now remove unwanted nodes
  textNodes <- textNodesAll[!(textNodesAll %in% textNodesRemove1)]
  
  
  #convert all elements but not the last to textP1
  textP1 <- textNodes[1:(length(textNodes)-1)] %>% xml2::xml_text()
  
  #get last entry string textP2
  textP2 <- textNodes[length(textNodes)] %>% xml2::xml_text()
  
  #if we find any textNodesRemove we clear textP2
  found <- FALSE
  if (length(textNodesRemove2) > 0) {
    for (i in 1: length(textNodesRemove2)) {
      pattern <- textNodesRemove2[i] %>% xml2::xml_text()
      if (length(pattern) > 0) {
        if (length(i <- grep(pattern, textP2))) {
          found<-TRUE
        }
      }
    }
    
  }
  
  #remove header &
  if (found) {
    textNeu = paste(textP1[2:(length(textP1))], "")
  } 
  else {
    textNeu = paste( textP1[2:(length(textP1))], textP2)
  }
  
  
  #collaps all nodes together in one single string
  final <- paste(textNeu,collapse= " ")
  return(final)
  
} #getWelt

wwRString <- function(source, pattern) {
  newStr <- gsub(pattern, '', source)
  return(newStr)
} #wwRString

getWirtschaftsWoche <- function(url) {
  
  #url <- "https://www.wiwo.de/politik/deutschland/medienbericht-kuenftiges-buergergeld-soll-fuer-alleinstehende-502-euro-betragen/28673476.html"
  print(url)
  #read the url
  htmlPage <- read_html(url)
  
  #identify all nodes with text
  textNodesAll <- htmlPage %>% xml_find_all('//p') 
  
  #identify elements, we don't need
  textNodesRemove1 <-  html_elements(htmlPage, ".c-leadtext")
  textNodesRemove2 <-  html_elements(htmlPage, ".modalwindow__ctext")
  textNodesRemove3 <-  html_elements(htmlPage, ".modalwindow__footer-caption")
  textNodesRemove4 <-  html_elements(htmlPage, ".modalwindow__cpt")
  textNodesRemove5 <-  html_elements(htmlPage, "em")
  
  #now remove unwanted elements
  textNodes <- textNodesAll[!(textNodesAll %in% textNodesRemove1)]
  textNodes <- textNodes[!(textNodes %in% textNodesRemove2)]
  textNodes <- textNodes[!(textNodes %in% textNodesRemove3)]
  textNodes <- textNodes[!(textNodes %in% textNodesRemove4)]
  textNodes <- textNodes[!(textNodes %in% textNodesRemove5)]
  
  
  #convert elements to text
  textP1 <- textNodes[1:(length(textNodes)-1)] %>% xml2::xml_text()
  
  #get string of last entry
  textp2 <- textNodes[length(textNodes)] %>% xml2::xml_text()
  #now remove all "em" text only if we fouond any em's
  if (length(textNodesRemove5) > 0) {
    for (i in 1: length(textNodesRemove5)) {textp2 <- wwRString(textp2, textNodesRemove5[i] %>% xml2::xml_text())}
  }
  
  #remove header
  textFinal = paste( textP1[2:(length(textP1))], textp2)
  
  #collaps all text together in one single string
  final <- paste(textFinal,collapse= " ")
  
  return(final)
} #getWirtschaftsWoche

getNZZ <- function(url) {
  
  #url <- "https://www.nzz.ch/wirtschaft/buerger-und-buergergeld-warum-das-buergergeld-nicht-buergerlich-ist-ld.1715404"
  #print(url) 
  
  #read the url
  htmlPage <- read_html(url)
  
  #identify all nodes with text
  textNodesAll <- htmlPage %>% xml_find_all('//p') 
  
  #identify elements of specific class, we don't need
  textNodesRem <-  html_elements(htmlPage, ".comments-item__text")
  
  #now remove unwanted nodes
  textNodes <- textNodesAll[!(textNodesAll %in% textNodesRem)]
  
  #get the final text
  text <- textNodes %>% xml2::xml_text()
  
  #collaps all nodes together in one single string
  final <- paste(text,collapse= " ")
  return(final)
  
} #getNZZ

getSZintern <- function (url, checkMP) {
  
  #//*[@id="top"]/div[3]/main/article/div[1]/header/div[5]/div/div
  #//*[@id="article-app-container"]/article/div[5]/p[1]
  tsXpath <- "//*[@id='article-app-container']/*"
  
  #read the url
  print(url)
  htmlPage <- read_html(url)
  
  #get the text lines from the article
  textLines <- htmlPage %>% html_elements(xpath =tsXpath)
  #do we have multiple pages?
  
  multiPage <- FALSE
  if (checkMP) {
    mp <- html_elements(htmlPage, "nav")
    if (length(mp) > 0) {
      mpNodes <- html_elements(htmlPage,".css-h5fkc8")
      if (length(mpNodes)>0) { multiPage <- TRUE}
    }
  }
  
  #identify all nodes with text
  textNodesAll <- textLines %>% xml_find_all('.//p') 
  
  #identify elements of specific class, we don't need
  textNodesRemove1 <-  html_elements(htmlPage, ".sz-teaser__summary")
  textNodesRemove2 <-  html_elements(htmlPage, ".css-x3s29y")
  textNodesRemove3 <-  html_elements(htmlPage, ".css-1485smx")
  textNodesRemove4 <-  html_elements(htmlPage, ".css-dgxek7")
  textNodesRemove5 <-  html_elements(htmlPage, ".css-1oy28g2")
  textNodesRemove6 <-  html_elements(htmlPage, ".css-1485smx")
  textNodesRemove7 <-  html_elements(htmlPage, ".css-1nw5r4g")
  textNodesRemove8 <-  html_elements(htmlPage, ".sz-teaser__overline-title")
  
  
  #now remove unwanted nodes
  textNodes <- textNodesAll[!(textNodesAll %in% textNodesRemove1)]
  textNodes <- textNodes[!(textNodes %in% textNodesRemove2)]
  textNodes <- textNodes[!(textNodes %in% textNodesRemove3)]
  textNodes <- textNodes[!(textNodes %in% textNodesRemove4)]
  textNodes <- textNodes[!(textNodes %in% textNodesRemove5)]
  textNodes <- textNodes[!(textNodes %in% textNodesRemove6)]
  textNodes <- textNodes[!(textNodes %in% textNodesRemove7)]
  textNodes <- textNodes[!(textNodes %in% textNodesRemove8)]
  
  
  #get the final text
  text <- textNodes %>% xml2::xml_text()
  
  #remove header/tail
  textNeu <- text[2:(length(text))]
  
  #collaps all nodes together in one single string
  page <- paste(textNeu,collapse= " ")
  
  if (multiPage) {
    final <- c("True", page)
  } else {
    final <- c("False", page)
  }
  
  return(final)
  
} #getSZintern

getSZ <- function(url) {
  
  #url <- "https://www.sueddeutsche.de/muenchen/hilfe-zum-lebensunterhalt-hartz-iv-sozialhilfe-energiekosten-muenchen-1.5649332"
  #url <- "https://www.welt.de/politik/deutschland/article166360698/Warum-sich-die-CSU-im-Bundesrat-kampflos-ergibt.html"
  #url <- "https://www.sueddeutsche.de/politik/ehe-fuer-alle-hauptsache-liebe-1.3567789"
  
  #initialize variable
  multiPage <- FALSE
  
  #get the html-page and check for multipage
  result <- getSZintern(url,TRUE)
  
  #do we have an article with multiple pages, then read also page 2
  if (result[1] == "True"){
    #save page 1 without "Seite 1/2"
    page1 <- substr(result[2],1,(nchar(result[2])-11))
    
    #setup new url to access page 2
    newUrl <- paste(url, "-2", sep="")
    
    #get page2 but don't check for another page
    result <- getSZintern(newUrl,FALSE)
    
    #save page 2 without "Seite2/2"
    page2 <- substr(result[2],1,(nchar(result[2])-11))
    
    #set multiPage flag
    multiPage <- TRUE  
  } else {
    #save page1
    page1 <- result[2]
  }
  
  #now build final string
  if (multiPage) {
    #we need to concatenate page1 and page2
    final <- paste(page1, page2, sep = "")
  } else {
    #we justg need to move page1 to final
    final <- page1
  }
  return(final)
  
} #getSZ


##########################Function to do it for one dataframe as a whole#######################

getArticle <- function(dataframe, extractor){
  article <- sapply(dataframe$url, extractor)
  cbind(dataframe, article)
}


#read in dataframes with url to scrape - Bürgergeld
BuergergeldBild <- read_csv("BuergergeldBild.csv")
BuergergeldBild <- na.omit(BuergergeldBild)

BuergergeldSpiegel <- read_csv("BuergergeldSpiegel.csv")
BuergergeldSpiegel <- na.omit(BuergergeldSpiegel)

BuergergeldSZ <- read_csv("BuergergeldSZ.csv")
BuergergeldSZ <- na.omit(BuergergeldSZ)

BuergergeldWelt <- read_csv("BuergergeldWelt.csv")
BuergergeldWelt <- na.omit(BuergergeldWelt)

BuergergeldWirtschaftswoche <- read_csv("BuergergeldWirtschaftswoche.csv")
BuergergeldWirtschaftswoche <- na.omit(BuergergeldWirtschaftswoche)

#we scraped them with webscraper because of paywall
#there are multiple rows for one article
BuergergeldZeit <- read_xlsx("BuergergeldZeit.xlsx")
BuergergeldZeit <- na.omit(BuergergeldZeit)

BuergergeldHandelsblatt <- read_xlsx("BuergergeldHandelsblatt.xlsx")
BuergergeldHandelsblatt <- na.omit(BuergergeldHandelsblatt)

#scrape articles 

BuergergeldBild <- getArticle(BuergergeldBild, getBild)
BuergergeldSpiegel <- getArticle(BuergergeldSpiegel, getSpiegel)
BuergergeldSZ <- getArticle(BuergergeldSZ, getSZ)
BuergergeldWelt <- getArticle(BuergergeldWelt, getWelt)
BuergergeldWirtschaftswoche <- getArticle(BuergergeldWirtschaftswoche, getWirtschaftsWoche)


#put all articles from one outlet into one string and create new dataframe
articleBild <- str_c(BuergergeldBild$article, collapse = " ")
articleHandelsblatt <- str_c(BuergergeldHandelsblatt$Text2, collapse = " ")
articleSpiegel <- str_c(BuergergeldSpiegel$article, collapse = " ")
articleSZ<- str_c(BuergergeldSZ$article, collapse = " ")
articleWelt <- str_c(BuergergeldWelt$article, collapse = " ")
articleWirtschaftswoche <- str_c(BuergergeldWirtschaftswoche$article, collapse = " ")
articleZeit <- str_c(BuergergeldZeit$Text, collapse = " ")

articlesBuergergeld <- data.frame(outlet = c("Bild", "Handelsblatt", "Spiegel", "SZ", "Welt",
                                             "Wirtschaftswoche", "Zeit"))
articlesBuergergeld$article <- NA
articlesBuergergeld[1,2] <- articleBild
articlesBuergergeld[2,2] <- articleHandelsblatt
articlesBuergergeld[3,2] <- articleSpiegel
articlesBuergergeld[4,2] <- articleSZ
articlesBuergergeld[5,2] <- articleWelt
articlesBuergergeld[6,2] <- articleWirtschaftswoche
articlesBuergergeld[7,2] <- articleZeit

row.names(articlesBuergergeld) <- c("bild.de", "Handelsblatt", "Spiegel", 
                                "SZ", "Welt", "Wirtschaftswoche", "ZeitOnline")


save(articlesBuergergeld, file = "articlesBuergergeld.Rdata")
load("articlesBuergergeld.Rdata")

#create corpus and dfm 

#create a corpus
buergergeld_corpus <- corpus(articlesBuergergeld, text_field = "article")

#we make some sensible feature selections 
#(some of the modelling functions take a long time to run if there 
#are too many features in the dfm)

buergergeld_dfm <-buergergeld_corpus%>% 
  tokens(remove_punct = TRUE,
         remove_symbols = TRUE,
         remove_url = TRUE) %>%
  tokens_remove(stopwords("de")) %>%
  dfm()

#trim common and rare words
buergergeld_dfm <- buergergeld_dfm %>%
  dfm_trim(min_docfreq = 0.1, #words that appear in less then 10% of the documents are removed
           max_docfreq = .9, #words that appear in more than 90% of the documents are removed
           docfreq_type = "prop")

buergergeld_dfm


#estimate wordfish model

buergergeld_wordfish <- textmodel_wordfish(x = buergergeld_dfm,
                                           dir =c(which(buergergeld_dfm$outlet == "Spiegel"),
                                                  which(buergergeld_dfm$outlet == "Welt")))

#positions of the outlets
buergergeld_dfm$outlet[order(buergergeld_wordfish$theta, decreasing =T)]

#main discriminating words

#most positive
buergergeld_wordfish$features[order(buergergeld_wordfish$beta, decreasing =T)][1:50]

#most negative
buergergeld_wordfish$features[order(buergergeld_wordfish$beta, decreasing =F)][1:50]


#plot

textplot_scale1d(homoEhe_wordfish, margin ="features", 
                 highlighted = c("unwahrheit", "widersprach","unbegründet","vertrauensschutzgründen",
                                 "verfassungswandels", "sexualität", "leihmutterschaft"))

textplot_scale1d(buergergeld_wordfish)



#HomoEhe

#read in dataframes with url to scrape - HomoEhe
HomoEheBild <- read_csv("HomoEheBild.csv")
HomoEheBild <- na.omit(HomoEheBild)

HomoEheSpiegel <- read_csv("HomoEheSpiegel.csv")
HomoEheSpiegel <- na.omit(HomoEheSpiegel)

HomoEheSZ <- read_xlsx("HomoEheSZ.xlsx")
HomoEheSZ <- na.omit(HomoEheSZ)

HomoEheWelt <- read_csv("HomoEheWelt.csv")
HomoEheWelt <- na.omit(HomoEheWelt)

HomoEheWirtschaftswoche <- read_xlsx("HomoEheWirtschaftswoche.xlsx")
#HomoEheWirtschaftswoche <- na.omit(HomoEheWirtschaftswoche)

#we scraped them with webscraper because of paywall
#there are multiple rows for one article
HomoEheZeit <- read_xlsx("HomoEheZeit.xlsx")
HomoEheZeit <- na.omit(HomoEheZeit)

HomoEheHandelsblatt <- read_xlsx("HomoEheHandelsblatt2.xlsx")
HomoEheHandelsblatt <- na.omit(HomoEheHandelsblatt)

#scrape articles 

HomoEheBild <- getArticle(HomoEheBild, getBild)
HomoEheSpiegel <- getArticle(HomoEheSpiegel, getSpiegel)
HomoEheSZ <- getArticle(HomoEheSZ, getSZ)
HomoEheWelt <- getArticle(HomoEheWelt, getWelt)
HomoEheWirtschaftswoche <- getArticle(HomoEheWirtschaftswoche, getWirtschaftsWoche)


#put all articles from one outlet into one string and create new dataframe
articleBild <- str_c(HomoEheBild$article, collapse = " ")
articleHandelsblatt <- str_c(HomoEheHandelsblatt$Text2, collapse = " ")
articleSpiegel <- str_c(HomoEheSpiegel$article, collapse = " ")
articleSZ<- str_c(HomoEheSZ$article, collapse = " ")
articleWelt <- str_c(HomoEheWelt$article, collapse = " ")
articleWirtschaftswoche <- str_c(HomoEheWirtschaftswoche$article, collapse = " ")
articleZeit <- str_c(HomoEheZeit$Text, collapse = " ")

articlesHomoEhe <- data.frame(outlet = c("Bild", "Handelsblatt", "Spiegel", "SZ", "Welt",
                                             "Wirtschaftswoche", "Zeit"))
articlesHomoEhe$article <- NA
articlesHomoEhe[1,2] <- articleBild
articlesHomoEhe[2,2] <- articleHandelsblatt
articlesHomoEhe[3,2] <- articleSpiegel
articlesHomoEhe[4,2] <- articleSZ
articlesHomoEhe[5,2] <- articleWelt
articlesHomoEhe[6,2] <- articleWirtschaftswoche
articlesHomoEhe[7,2] <- articleZeit

row.names(articlesHomoEhe) <- c("bild.de", "Handelsblatt", "Spiegel", 
                                "SZ", "Welt", "Wirtschaftswoche", "ZeitOnline")


save(articlesHomoEhe, file = "articlesHomoEhe.Rdata")

