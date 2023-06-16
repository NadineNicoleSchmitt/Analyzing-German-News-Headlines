# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Project")

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


#HomoEhe

load("articlesHomoEhe.Rdata")

#create corpus and dfm 

#create a corpus
homoEhe_corpus <- corpus(articlesHomoEhe, text_field = "article")

#we make some sensible feature selections 
#(some of the modelling functions take a long time to run if there 
#are too many features in the dfm)

homoEhe_dfm <-homoEhe_corpus%>% 
  tokens(remove_punct = TRUE,
         remove_symbols = TRUE,
         #remove_numbers = TRUE,
         remove_url = TRUE) %>%
  tokens_remove(stopwords("de")) %>%
  dfm()

#trim common and rare words
homoEhe_dfm <- homoEhe_dfm %>%
  dfm_trim(min_docfreq = 0.1, #words that appear in less then 10% of the documents are removed
           max_docfreq = .9, #words that appear in more than 90% of the documents are removed
           docfreq_type = "prop")

homoEhe_dfm


#estimate wordfish model

homoEhe_wordfish <- textmodel_wordfish(x = homoEhe_dfm,
                                           dir =c(which(homoEhe_dfm$outlet == "Spiegel"),
                                                  which(homoEhe_dfm$outlet == "Bild")))

#positions of the outlets
homoEhe_dfm$outlet[order(homoEhe_wordfish$theta, decreasing =T)]
textplot_scale1d(homoEhe_wordfish, sort =T,
                 doclabels = c("bild.de", "Handelsblatt", "Spiegel", "SZ", "Welt", "Wirtschaftswoche", "ZeitOnline"))

#main discriminating words

#most positive
homoEhe_wordfish$features[order(homoEhe_wordfish$beta, decreasing =T)][1:50]

#most negative
homoEhe_wordfish$features[order(homoEhe_wordfish$beta, decreasing =F)][1:50]

#plot
textplot_scale1d(homoEhe_wordfish, margin ="features", 
                 highlighted = c("hochzeiten", "zweifler","schrecklich","fristverkürzung",
                                 "wahlsieg", "jammer", "widersprach", "ja-", "enthaltungen", "verfassungswandels",
                                 "cdu-schwergewichte", "parlamentsvotum", "zustimmten"))



################################################################################################################################
##Bürgergeld

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
                                                  which(buergergeld_dfm$outlet == "Bild")))

#positions of the outlets
buergergeld_dfm$outlet[order(buergergeld_wordfish$theta, decreasing =T)]
textplot_scale1d(buergergeld_wordfish, sort =T,
                 doclabels = c("bild.de", "Handelsblatt", "Spiegel", "SZ", "Welt", "Wirtschaftswoche", "ZeitOnline"))

#main discriminating words

#most positive
buergergeld_wordfish$features[order(buergergeld_wordfish$beta, decreasing =T)][1:50]

#most negative
buergergeld_wordfish$features[order(buergergeld_wordfish$beta, decreasing =F)][1:50]




################################################################################################################################

#Migration (only headlines)

load("Code/Data/headlines.Rdata")

migration <- filter(headlines, headlines$category == "Migration")


#create a corpus
migration_corpus <- corpus(migration, text_field = "title")

#group corpus by outlet to combine all headlines
migration_corpus_grouped <- migration_corpus %>%
  corpus_group(outlet)


#we make some sensible feature selections 
#(some of the modelling functions take a long time to run if there 
#are too many features in the dfm)

migration_dfm <-migration_corpus_grouped%>% 
  tokens(remove_punct = TRUE,
         remove_symbols = TRUE,
         remove_url = TRUE) %>%
  tokens_remove(stopwords("de")) %>%
  dfm()

#trim common and rare words
migration_dfm <- migration_dfm %>%
  dfm_trim(min_docfreq = 0.1, #words that appear in less then 10% of the documents are removed
           max_docfreq = .9, #words that appear in more than 90% of the documents are removed
           docfreq_type = "prop")


#estimate wordfish model

migration_wordfish <- textmodel_wordfish(x = migration_dfm,
                                           dir =c(which(migration_dfm$outlet == "Spiegel"),
                                                  which(migration_dfm$outlet == "bild.de")))

#positions of the outlets
migration_dfm$outlet[order(migration_wordfish$theta, decreasing =T)]
textplot_scale1d(migration_wordfish, sort =T,
                 doclabels = c("bild.de", "FAZ",  "Handelsblatt", "Spiegel", "SZ", "Welt", "Wirtschaftswoche", "ZeitOnline"))

#main discriminating words

#most positive
migration_wordfish$features[order(migration_wordfish$beta, decreasing =T)][1:50]

#most negative
migration_wordfish$features[order(migration_wordfish$beta, decreasing =F)][1:50]


#Klimawandel

klima <- filter(headlines, headlines$category == "Klimawandel")


#create a corpus
klima_corpus <- corpus(klima, text_field = "title")

#group corpus by outlet to combine all headlines
klima_corpus_grouped <- klima_corpus %>%
  corpus_group(outlet)


#we make some sensible feature selections 
#(some of the modelling functions take a long time to run if there 
#are too many features in the dfm)

klima_dfm <-klima_corpus_grouped%>% 
  tokens(remove_punct = TRUE,
         remove_symbols = TRUE,
         remove_url = TRUE) %>%
  tokens_remove(stopwords("de")) %>%
  dfm()

#trim common and rare words
klima_dfm <- klima_dfm %>%
  dfm_trim(min_docfreq = 0.1, #words that appear in less then 10% of the documents are removed
           max_docfreq = .9, #words that appear in more than 90% of the documents are removed
           docfreq_type = "prop")


#estimate wordfish model

klima_wordfish <- textmodel_wordfish(x = klima_dfm,
                                         dir =c(which(migration_dfm$outlet == "Spiegel"),
                                                which(migration_dfm$outlet == "bild.de")))

#positions of the outlets
klima_dfm$outlet[order(klima_wordfish$theta, decreasing =T)]
textplot_scale1d(klima_wordfish, sort =T,
                 doclabels = c("bild.de", "FAZ",  "Handelsblatt", "Spiegel", "SZ", "Welt", "Wirtschaftswoche", "ZeitOnline"))

#main discriminating words

#most positive
klima_wordfish$features[order(klima_wordfish$beta, decreasing =T)][1:50]

#most negative
klima_wordfish$features[order(klima_wordfish$beta, decreasing =F)][1:50]


