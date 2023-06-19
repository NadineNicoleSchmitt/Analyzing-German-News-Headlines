# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Project/Code")

# Clear the environment by removing any defined objects/functions
rm(list = ls())



library(quanteda.sentiment)
library(quanteda)
library(quanteda.dictionaries)
library(tidyverse)
library(googleLanguageR)
library(text2vec)
library(caret)
library(ggpubr)


#stopwords("de")

####################################Rauh######################################################

example <- data.frame(Id = c("text1", "text2", "text3", "text4"), 
                      text = c("Blau und nicht gut", "keine gute Farbe", "schlecht", "quarantäne"))
corpus <- corpus(example, text_field= "text")                      
dfm <- corpus %>%
  tokens() %>%
  tokens_replace(pattern = c("nicht", "nichts", "kein",
                                   "keine", "keinen", "weniger", "wenig", "wenige"),
                 replacement = rep("not", 8)) %>%
  tokens_compound(data_dictionary_Rauh, concatenator = " ")%>% #compound bi-gram negation patterns
  #tokens_ngrams(1:2)%>%
  dfm()

dictionary_rauh <- append(data_dictionary_Rauh$neg_positive, data_dictionary_Rauh$negative) #37,080 words

save(dictionary_rauh, file ="dictionary_rauh.Rdata")


dic <- dictionary(list(negpos = data_dictionary_Rauh$neg_positive, neg=data_dictionary_Rauh$negative, 
                       both = dictionary_rauh  ))

dfm_dic <- dfm_lookup(dfm, dic)
dfm_dic


#################################LSD##############################################################

#translation of Lexicoder Sentiment Dictionary 
gl_auth("key.json")

dictionary_lsd_neg <- NULL
for(i in data_dictionary_LSD2015$negative){
  translation <- gl_translate(i, target = "de", format = "text")
  translation <- translation$translatedText
  translation <- tolower(translation)
  dictionary_lsd_neg <- append(dictionary_lsd_neg, translation)
}
#remove*
for(i in 1:length(dictionary_lsd_neg)){
  dictionary_lsd_neg[i] <- gsub("[*]", "", dictionary_lsd_neg[i])
}
#we did a face validating check were we analysed 
#if the German translated words have a negative sentiment in German language
#if not we removed the word from the dictionary
dic <- read_xlsx("LSD_neg_reviewed.xlsx")
dicNew <- dic %>% 
  transmute(`,"x"` = str_replace_all(`,"x"`, "Ã¼", "ü")) %>%
  transmute(`,"x"` = str_replace_all(`,"x"`, "Ã¶", "ö")) %>%
  transmute(`,"x"` =str_replace_all(`,"x"`, "Ã¤", "ä")) %>%
  transmute(`,"x"` =str_replace_all(`,"x"`, "ÃŸ", "ß")) %>%
  transmute(`,"x"` =str_replace_all(`,"x"`, "â€™", "’")) %>%
  transmute(`,"x"` =str_replace_all(`,"x"`, "Ã–", "Ö")) %>%
  transmute(`,"x"` =str_replace_all(`,"x"`, "Ãœ", "Ü")) %>%
  transmute(`,"x"` =str_replace_all(`,"x"`, "Ã„", "Ä")) %>%
  transmute(`,"x"` =str_replace_all(`,"x"`, "â€ž", "’")) %>%
  transmute(`,"x"` =str_replace_all(`,"x"`, "â€œ", "’")) %>%
  transmute(`,"x"` =str_replace_all(`,"x"`, "Â", "")) %>%
  transmute(`,"x"` =str_replace_all(`,"x"`, "â€“", "-")) 
colnames(dicNew) <- c("word")
dicNew <- dicNew %>% 
  mutate(word = gsub("[\"]", "", word))
dicNew <- dicNew %>% 
  mutate(word = gsub(".*,", "", word))

dictionary_lsd_neg <- dicNew$word #original had 2858; ours now 2334

dictionary_lsd_neg_pos <- NULL
for(i in data_dictionary_LSD2015$neg_positive){
  translation <- gl_translate(i, target = "de", format = "text")
  translation <- translation$translatedText
  translation <- tolower(translation)
  dictionary_lsd_neg_pos <- append(dictionary_lsd_neg_pos, translation)
}
#remove*
for(i in 1:length(dictionary_lsd_neg_pos)){
  dictionary_lsd_neg_pos[i] <- gsub("[*]", "", dictionary_lsd_neg_pos[i])
}


#we did a face validating check were we analysed 
#if the German translated words have a negative sentiment in German language
#if not we removed the word from the dictionary
dic <- read_xlsx("LSD_neg_pos_reviewed.xlsx")
dic <- dic[,3]
dicNew <- dic %>% 
  transmute(modified = str_replace_all(modified, "Ã¼", "ü")) %>%
  transmute(modified = str_replace_all(modified, "Ã¶", "ö")) %>%
  transmute(modified =str_replace_all(modified, "Ã¤", "ä")) %>%
  transmute(modified =str_replace_all(modified, "ÃŸ", "ß")) %>%
  transmute(modified =str_replace_all(modified, "â€™", "’")) %>%
  transmute(modified =str_replace_all(modified, "Ã–", "Ö")) %>%
  transmute(modified =str_replace_all(modified, "Ãœ", "Ü")) %>%
  transmute(modified =str_replace_all(modified, "Ã„", "Ä")) %>%
  transmute(modified =str_replace_all(modified, "â€ž", "’")) %>%
  transmute(modified =str_replace_all(modified, "â€œ", "’")) %>%
  transmute(modified =str_replace_all(modified, "Â", "")) %>%
  transmute(modified =str_replace_all(modified, "â€“", "-")) 
colnames(dicNew) <- c("word")


dictionary_lsd_neg_pos <- dicNew$word #original had 1721; ours now 1564


example <- data.frame(Id = c("text1", "text2", "text3", "text4"), 
                      text = c("Lüge", "Straftaten", "keine fähigkeit", "am besten nicht"))
corpus <- corpus(example, text_field= "text")                      
dfm <- corpus %>%
  tokens() %>%
  tokens_replace(pattern = c("nicht", "nichts", "kein",
                             "keine", "keinen"),
                 replacement = rep("not", 5)) %>%
  tokens_compound(phrase(dictionary_lsd_neg_pos), concatenator = " ")%>%
  #tokens_ngrams(1:2)%>%
  dfm()

dictionary_lsd <- append(dictionary_lsd_neg, dictionary_lsd_neg_pos) #3898
save(dictionary_lsd, file ="dictionary_lsd.Rdata")
load("dictionary_lsd.Rdata")

dic <- dictionary(list(negpos = dictionary_lsd_neg_pos, neg=dictionary_lsd_neg, 
                       both =dictionary_lsd))

dfm_dic <- dfm_lookup(dfm, dic)
dfm_dic

##########################################################################################

#Dictionary expansion with word embeddings (self trained)
load("wordEmbeddingsGloVe.Rdata")
emb <- word_vectors

#extension of rauh-neg dictionary

#1) extract words from emb which are in rauh dictionary
rauh_emb <- emb[rownames(emb) %in% data_dictionary_Rauh$negative,]

#2) calculate mean embedding vector of the rauh dictionary words
rauh_emb_mean <- colMeans(rauh_emb) #is a numeric vector

#3) calculate the similarity between the mean rauh vector and every other word in our embeddings
target_sim <- sim2 (x=emb,
                    y= matrix(rauh_emb_mean, nrow=1))

#4) what are the 500 words that have the highest cosine similarity with the mean rauh vector?
top500 <- names(sort(target_sim[,1], decreasing = TRUE))[1:500]

table(top500 %in% data_dictionary_Rauh$negative) #only 60 of them are in our dictionary

expansion_rauh <- top500[!top500 %in% data_dictionary_Rauh$negative] #440

#extension of lsd-neg dictionary

#1) extract words from emb which are in lsd dictionary
lsd_emb <- emb[rownames(emb) %in% dictionary_lsd_neg,]

#2) calculate mean embedding vector of the lsd dictionary words
lsd_emb_mean <- colMeans(lsd_emb) #is a numeric vector

#3) calculate the similarity between the mean lsd vector and every other word in our embeddings
target_sim <- sim2 (x=emb,
                    y= matrix(lsd_emb_mean, nrow=1))

#4) what are the 500 words that have the highest cosine similarity with the mean rauh vector?
top500 <- names(sort(target_sim[,1], decreasing = TRUE))[1:500]

table(top500 %in% dictionary_lsd_neg) #only 25 of them are in our dictionary

expansion_lsd <- top500[!top500 %in% dictionary_lsd_neg] #475




#Dictionary expansion with word embeddings (pre trained)
load("preTrained.Rdata")
emb <- preTrained

#extension of rauh-neg dictionary

#1) extract words from emb which are in rauh dictionary
rauh_emb <- emb[rownames(emb) %in% data_dictionary_Rauh$negative,]

#2) calculate mean embedding vector of the rauh dictionary words
rauh_emb_mean <- colMeans(rauh_emb) #is a numeric vector

#3) calculate the similarity between the mean rauh vector and every other word in our embeddings
target_sim <- sim2 (x=emb,
                    y= matrix(rauh_emb_mean, nrow=1))

#4) what are the 500 words that have the highest cosine similarity with the mean rauh vector?
top500 <- names(sort(target_sim[,1], decreasing = TRUE))[1:500]

table(top500 %in% data_dictionary_Rauh$negative) #267 of them are in our dictionary

expansion_rauh_pre <- top500[!top500 %in% data_dictionary_Rauh$negative] #233
save(expansion_rauh_pre, file= "expansion_rauh_preTrained.Rdata")

#extension of lsd-neg dictionary

#1) extract words from emb which are in lsd dictionary
lsd_emb <- emb[rownames(emb) %in% dictionary_lsd_neg,]

#2) calculate mean embedding vector of the lsd dictionary words
lsd_emb_mean <- colMeans(lsd_emb) #is a numeric vector

#3) calculate the similarity between the mean lsd vector and every other word in our embeddings
target_sim <- sim2 (x=emb,
                    y= matrix(lsd_emb_mean, nrow=1))

#4) what are the 500 words that have the highest cosine similarity with the mean rauh vector?
top500 <- names(sort(target_sim[,1], decreasing = TRUE))[1:100]

table(top500 %in% dictionary_lsd_neg) #108 of them are in our dictionary

expansion_lsd_pre <- top500[!top500 %in% dictionary_lsd_neg] #392
save(expansion_lsd_pre, file ="expansion_lsd_preTrained.Rdata")



###############################################################
#dictionary scores

load("Data/headlines.Rdata")

#create corpus and dfm
#we removed no stopwords as they are also included in the dictionaries (e.g. "keinem", "gegen")
#we removed numbers and punctuation as they are not included in the dictionaries
#we used unigrams as negative positives are included in dictionary and therefore capture a large amount
#we did no trimming as headlines are quite short (in comparison to large texts/articles/speeches) 
#and therefore one word normally appears only once in one document

corpus <- corpus(headlines, text_field = "title")

#rauh 
dfm_rauh <- corpus %>%
  tokens() %>%
  tokens(remove_punct = TRUE, remove_numbers = TRUE) %>%
  #tokens_remove(stopwords("de")) %>%
  tokens_replace(pattern = c("nicht", "nichts", "kein",
                             "keine", "keinen"),
                 replacement = rep("not", 5)) %>%
  tokens_compound(data_dictionary_Rauh, concatenator = " ")%>%
  dfm()

#dictionary
dic_rauh <- dictionary(list(rauh = dictionary_rauh))

#apply dictionary to the dfm (remaining dfm has only one feature)
dfm_dic_rauh <- dfm_lookup(dfm_rauh, dic_rauh)

#calculate dictionary score (proportion) and store it in headlines
headlines$rauh_dic_score <- as.numeric(dfm_dic_rauh[,1])/ntoken(corpus)


#comparison to human judgement
headlinesLabeled <- filter(headlines, headlines$labeling==TRUE)

headlinesLabeled$classRauh[headlinesLabeled$rauh_dic_score >0] <-"Negative"
headlinesLabeled$classRauh[headlinesLabeled$rauh_dic_score <=0] <-"NotNegative"

confusion_table <- table(Dictionary = headlinesLabeled$classRauh, 
                         Human_coding = headlinesLabeled$human_coding)
statistics <- confusionMatrix(confusion_table, positive ="Negative")
accuracy <- statistics$overall[1]
sensitivity <- statistics$byClass[1]
specificity <- statistics$byClass[2]


result <- data.frame(Rauh = c(4,2,3),
                     LSD = c(2,30,4),
                     RauhExpansion = c(31,12,14),
                     LSDExpansion = c(40,0,0))
rownames(result) <- c("Accuracy", "Sensitivity", "Specificity")

result[1,1] <- accuracy
result[2,1] <- sensitivity
result[3,1] <- specificity

formattable(result, list(
  Rauh = formatter("span", 
                     style = ~ style(color = ifelse(Rauh > LSD & Rauh > RauhExpansion &
                                                    Rauh > LSDExpansion,
                                                    "green", "black"))),
  LSD = formatter("span", 
                     style = ~ style(color = ifelse(LSD > Rauh & LSD > RauhExpansion &
                                                      LSD > LSDExpansion,
                                                    "green", "black"))),
  RauhExpansion = formatter("span", 
                     style = ~ style(color = ifelse(RauhExpansion > Rauh & RauhExpansion > LSD &
                                                    RauhExpansion > LSDExpansion,
                                                    "green", "black"))),
  LSDExpansion = formatter("span", 
                            style = ~ style(color = ifelse(LSDExpansion > Rauh & LSDExpansion > LSD &
                                                           LSDExpansion > RauhExpansion,
                                                           "green", "black")))))

#rauh expansion

#dictionary
dic_rauh_expansion <- dictionary(list(rauh_expansion = c(dictionary_rauh, expansion_rauh_pre)))

#apply dictionary to the dfm (remaining dfm has only one feature)
dfm_dic_rauh_expansion <- dfm_lookup(dfm_rauh, dic_rauh_expansion)

#calculate dictionary score (proportion) and store it in headlines
headlines$rauhExpansion_dic_score <- as.numeric(dfm_dic_rauh_expansion[,1])/ntoken(corpus)

#comparison to human judgement
headlinesLabeled <- filter(headlines, headlines$labeling==TRUE)

headlinesLabeled$classRauhExpansion[headlinesLabeled$rauhExpansion_dic_score >0] <-"Negative"
headlinesLabeled$classRauhExpansion[headlinesLabeled$rauhExpansion_dic_score <=0] <-"NotNegative"

confusion_table <- table(Dictionary = headlinesLabeled$classRauhExpansion, 
                         Human_coding = headlinesLabeled$human_coding)
statistics <- confusionMatrix(confusion_table, positive ="Negative")
accuracy <- statistics$overall[1]
sensitivity <- statistics$byClass[1]
specificity <- statistics$byClass[2]


result[1,3] <- accuracy
result[2,3] <- sensitivity
result[3,3] <- specificity

formattable(result, list(
  Rauh = formatter("span", 
                   style = ~ style(color = ifelse(Rauh > LSD & Rauh > RauhExpansion &
                                                    Rauh > LSDExpansion,
                                                  "green", "black"))),
  LSD = formatter("span", 
                  style = ~ style(color = ifelse(LSD > Rauh & LSD > RauhExpansion &
                                                   LSD > LSDExpansion,
                                                 "green", "black"))),
  RauhExpansion = formatter("span", 
                            style = ~ style(color = ifelse(RauhExpansion > Rauh & RauhExpansion > LSD &
                                                             RauhExpansion > LSDExpansion,
                                                           "green", "black"))),
  LSDExpansion = formatter("span", 
                           style = ~ style(color = ifelse(LSDExpansion > Rauh & LSDExpansion > LSD &
                                                            LSDExpansion > RauhExpansion,
                                                          "green", "black")))))



#LSD
 
dfm_lsd <- corpus %>%
  tokens() %>%
  tokens(remove_punct = TRUE, remove_numbers = TRUE) %>%
  tokens_replace(pattern = c("nicht", "nichts", "kein",
                             "keine", "keinen"),
                 replacement = rep("not", 5)) %>%
  tokens_compound(phrase(dictionary_lsd_neg_pos), concatenator = " ")%>%
  dfm()

#dictionary
dic_lsd <- dictionary(list(lsd = dictionary_lsd))

#apply dictionary to the dfm (remaining dfm has only one feature)
dfm_dic_lsd <- dfm_lookup(dfm_lsd, dic_lsd)

#calculate dictionary score (proportion) and store it in headlines
headlines$lsd_dic_score <- as.numeric(dfm_dic_lsd[,1])/ntoken(corpus)

#comparison to human judgement
headlinesLabeled <- filter(headlines, headlines$labeling==TRUE)

headlinesLabeled$classLSD[headlinesLabeled$lsd_dic_score >0] <-"Negative"
headlinesLabeled$classLSD[headlinesLabeled$lsd_dic_score <=0] <-"NotNegative"

confusion_table <- table(Dictionary = headlinesLabeled$classLSD, 
                         Human_coding = headlinesLabeled$human_coding)
statistics <- confusionMatrix(confusion_table, positive ="Negative")
accuracy <- statistics$overall[1]
sensitivity <- statistics$byClass[1]
specificity <- statistics$byClass[2]


result[1,2] <- accuracy
result[2,2] <- sensitivity
result[3,2] <- specificity

formattable(result, list(
  Rauh = formatter("span", 
                   style = ~ style(color = ifelse(Rauh > LSD & Rauh > RauhExpansion &
                                                    Rauh > LSDExpansion,
                                                  "green", "black"))),
  LSD = formatter("span", 
                  style = ~ style(color = ifelse(LSD > Rauh & LSD > RauhExpansion &
                                                   LSD > LSDExpansion,
                                                 "green", "black"))),
  RauhExpansion = formatter("span", 
                            style = ~ style(color = ifelse(RauhExpansion > Rauh & RauhExpansion > LSD &
                                                             RauhExpansion > LSDExpansion,
                                                           "green", "black"))),
  LSDExpansion = formatter("span", 
                           style = ~ style(color = ifelse(LSDExpansion > Rauh & LSDExpansion > LSD &
                                                            LSDExpansion > RauhExpansion,
                                                          "green", "black")))))

#LSD Expansion

#dictionary
dic_lsd_expansion <- dictionary(list(lsd_expansion = c(dictionary_lsd, expansion_lsd_pre)))

#apply dictionary to the dfm (remaining dfm has only one feature)
dfm_dic_lsd_expansion <- dfm_lookup(dfm_lsd, dic_lsd_expansion)

#calculate dictionary score (proportion) and store it in headlines
headlines$lsd_expansion_dic_score <- as.numeric(dfm_dic_lsd_expansion[,1])/ntoken(corpus)

#comparison to human judgement
headlinesLabeled <- filter(headlines, headlines$labeling==TRUE)

headlinesLabeled$classLSDExpansion[headlinesLabeled$lsd_expansion_dic_score >0] <-"Negative"
headlinesLabeled$classLSDExpansion[headlinesLabeled$lsd_expansion_dic_score <=0] <-"NotNegative"

confusion_table <- table(Dictionary = headlinesLabeled$classLSDExpansion, 
                         Human_coding = headlinesLabeled$human_coding)
statistics <- confusionMatrix(confusion_table, positive ="Negative")
accuracy <- statistics$overall[1]
sensitivity <- statistics$byClass[1]
specificity <- statistics$byClass[2]


result[1,4] <- accuracy
result[2,4] <- sensitivity
result[3,4] <- specificity

formattable(result, list(
  Rauh = formatter("span", 
                   style = ~ style(color = ifelse(Rauh > LSD & Rauh > RauhExpansion &
                                                    Rauh > LSDExpansion,
                                                  "green", "black"))),
  LSD = formatter("span", 
                  style = ~ style(color = ifelse(LSD > Rauh & LSD > RauhExpansion &
                                                   LSD > LSDExpansion,
                                                 "green", "black"))),
  RauhExpansion = formatter("span", 
                            style = ~ style(color = ifelse(RauhExpansion > Rauh & RauhExpansion > LSD &
                                                             RauhExpansion > LSDExpansion,
                                                           "green", "black"))),
  LSDExpansion = formatter("span", 
                           style = ~ style(color = ifelse(LSDExpansion > Rauh & LSDExpansion > LSD &
                                                            LSDExpansion > RauhExpansion,
                                                          "green", "black")))))

#face validating

#directly examing texts that are highly scored negative/ NotNegative 
top30_negative <- headlines$title[order(headlines$rauhExpansion_dic_score, decreasing =TRUE)][1:30]
top30_negative


#directly examing texts that are highly scored NotNegative 
top30_NotNegative <- headlines$title[order(headlines$rauhExpansion_dic_score, decreasing =FALSE)][1:30]
top30_NotNegative


#plots to answer research question
#we calculate the mean average dictionary score per

#sum <- headlines %>%
#group_by(year,category, classificationNaiveBayes) %>%
#summarise(score= n())


sum <- headlines %>% 
  group_by(month_year = floor_date(date, unit ="month"),category, outlet) %>%
  summarise(mean_score= mean(rauhExpansion_dic_score))
  
f <- formattable(sum)
f

#export_formattable(f, file= "test.pdf", width="100%", height="100%")
export_formattable(f, file= "DictionaryResults.pdf", width="25%")


#get insights over time for each category (not grouped by outlet)

sum <- headlines %>% 
  group_by(month_year = floor_date(date, unit ="month"),category) %>%
  summarise(mean_score= mean(rauhExpansion_dic_score))


ggplot(sum, aes(x=month_year, y= mean_score, group=category)) +
  geom_line(aes(color=category))+
  geom_point(aes(color=category))+
  labs(y="Mean Dictionary Score" ,title= "Dictionary Sentiment Analysis")+
  scale_x_date(breaks= "6 month", date_labels =  "%b%Y") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))



##get insights over time (year) for each category (not grouped by outlet)

sum <- headlines %>% 
  group_by(year,category) %>%
  summarise(mean_score= mean(rauhExpansion_dic_score))

sum$year <- as.factor(sum$year)

ggplot(sum, aes(x=year, y= mean_score, group=category)) +
  geom_line(aes(color=category))+
  geom_point(aes(color=category))+
  labs(y="Mean Dictionary Score" ,title= "Dictionary Sentiment Analysis over time grouped by category")
  #scale_x_date(breaks= "6 month", date_labels =  "%b%Y") +
  #theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))


##get insights over time (year) for each outlet (not grouped by category)

sum <- headlines %>% 
  group_by(year,outlet) %>%
  summarise(mean_score= mean(rauhExpansion_dic_score))

sum$year <- as.factor(sum$year)

ggplot(sum, aes(x=year, y= mean_score, group=outlet)) +
  geom_line(aes(color=outlet))+
  geom_point(aes(color=outlet))+
  labs(y="Mean Dictionary Score" ,title= "Dictionary Sentiment Analysis over time grouped by outlet")
#scale_x_date(breaks= "6 month", date_labels =  "%b%Y") +
#theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))


#plot for each category splitted up into outlets

plot_naive <- function(cat, NameCategory){
  cat <- filter(headlines, headlines$category==NameCategory)
  
  sum <- cat %>% 
    group_by(year,outlet) %>%
    summarise(mean_score= mean(rauhExpansion_dic_score))
  
  sum$year <- as.factor(sum$year)
  
  ggplot(sum, aes(x=year, y= mean_score, group=outlet)) +
    geom_line(aes(color=outlet))+
    geom_point(aes(color=outlet))+
    labs(y="Mean Dictionary Score" ,title= paste("Dictionary Sentiment Analysis", NameCategory))
  
}

p1 <- plot_naive(filter(headlines, headlines$category=="Arbeitsmarkt"), "Arbeitsmarkt")
p2 <-plot_naive(filter(headlines, headlines$category=="Bildung"), "Bildung")
p5 <- plot_naive(filter(headlines, headlines$category=="Klimawandel"), "Klimawandel")
p6 <-plot_naive(filter(headlines, headlines$category=="Migration"), "Migration")
p7 <-plot_naive(filter(headlines, headlines$category=="Rassismus"), "Rassismus")
p3 <-plot_naive(filter(headlines, headlines$category=="Coronavirus"), "Coronavirus")
p4 <-plot_naive(filter(headlines, headlines$category=="Digitalisierung"), "Digitalisierung")
p8 <-plot_naive(filter(headlines, headlines$category=="Ukraine"), "Ukraine")


ggarrange(p1, p2, p3, p4, p5, p6, p7, p8 ,
          #labels = c("A", "B", "C"),
          ncol = 2, nrow = 2)


##see trend dictionary score and NToken

nTokens <- ntoken(corpus)

headlines$NToken <- nTokens


sum <- headlines %>% 
  group_by(month_year = floor_date(date, unit ="month"),outlet) %>%
  summarise(mean_score= mean(rauhExpansion_dic_score), mean_Ntoken = mean(NToken))



ggplot(sum, aes(x=mean_score, y= mean_Ntoken)) +
  #geom_line(aes(color=outlet))+
  geom_point(aes(color=outlet))+
  geom_smooth()+
  labs(x= "Mean Dictionary Score", y="Length of headline (NToken)" ,
       title= "Mean Dictionary Score vs. Length of Headlines")


#the same as above but now also grouped by category

sum <- headlines %>% 
    group_by(month_year = floor_date(date, unit ="month"),category) %>%
  summarise(mean_score= mean(rauhExpansion_dic_score), mean_Ntoken = mean(NToken))

ggplot(sum, aes(x=mean_score, y= mean_Ntoken)) +
  #geom_line(aes(color=outlet))+
  geom_point(aes(color=category))+
  geom_smooth()+
  labs(x= "Mean Dictionary Score", y="Length of headline (NToken)" ,
       title= "Mean Dictionary Score vs. Length of Headlines (category)")


#look a little bit deeper into migration
migration <- filter(headlines, headlines$category=="Migration")

#only the last years

migration <- filter(migration, migration$year>2014 & migration$year)
sum <- migration %>% 
  group_by(month_year = floor_date(date, unit ="month")) %>%
  summarise(mean_score= mean(rauhExpansion_dic_score))

#sum$year <- as.factor(sum$year)

ggplot(sum, aes(x=month_year, y= mean_score) )+
  geom_point()+
  geom_text(aes(label=ifelse(month_year=="2020-02-01","Start covid", "")),hjust=0, vjust=0)+
  geom_text(aes(label=ifelse(month_year=="2022-02-01","Start Ukraine War", "")),hjust=0, vjust=0)+
  geom_text(aes(label=ifelse(month_year=="2015-09-01","Wir schaffen das!", "")),hjust=0, vjust=0)+
  geom_smooth()+
  labs(y="Mean Dictionary Score" ,title= paste("Dictionary Sentiment Analysis Migration 2014-2023"))+
  scale_x_date(breaks= "1 month", date_labels =  "%b%Y") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))+
  #annotate(x=as.Date("2020-02-01"),y=0.09863112,label="First Covid Case ",geom="label", color="pink")
  geom_mark_ellipse(aes(filter = month_year %in% c("2022-03-01", "2022-05-01", "2022-06-01")), 
                    col = "red", description = "Although many Ukraine migrants in these months") +
  geom_mark_ellipse(aes(filter = month_year %in% c("2020-04-01", "2020-05-01", "2020-06-01", "2020-07-01")), 
                    col = "red", description = "Although no migrants in these months because of border closures") +
  geom_mark_ellipse(aes(filter = month_year %in% c("2015-09-01", "2015-08-01")), 
                    col = "green", description = "Many migrants because of migration crisis") 



#look a little bit deeper into covid
covid <- filter(headlines, headlines$category=="Coronavirus")

#only the last years

covid <- filter(covid, covid$year>2019)
sum <- covid %>% 
  group_by(month_year = floor_date(date, unit ="month")) %>%
  summarise(mean_score= mean(rauhExpansion_dic_score))

#sum$year <- as.factor(sum$year)

ggplot(sum, aes(x=month_year, y= mean_score) )+
  geom_point()+
  geom_text(aes(label=ifelse(month_year=="2020-02-01","Start Covid & First Lockdown", "")),hjust=0, vjust=0)+
  geom_text(aes(label=ifelse(month_year=="2020-05-01","End first Lockdown", "")),hjust=0, vjust=0)+
  geom_text(aes(label=ifelse(month_year=="2020-11-01","Start Second Lockdown", "")),hjust=0, vjust=0)+
  geom_text(aes(label=ifelse(month_year=="2021-04-01","End Second Lockdown", "")),hjust=0, vjust=0)+
  geom_text(aes(label=ifelse(month_year=="2020-12-01","Start vaccination", "")),hjust=0, vjust=0)+
  geom_text(aes(label=ifelse(month_year=="2022-12-01","End of Covid-19", "")),hjust=0, vjust=0)+
  geom_smooth()+
  geom_smooth()+
  labs(y="Mean Dictionary Score" ,title= paste("Dictionary Sentiment Analysis Coronavirus 2020-2023"))+
  scale_x_date(breaks= "1 month", date_labels =  "%b%Y") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))+
  geom_mark_ellipse(aes(filter = month_year %in% c("2022-11-01", "2022-12-01", "2023-01-01", "2023-02-01", "2023-03-01", "2023-04-01")), 
                    col = "red", description = "Although Covid-19 pandemic is over") 


#look a little bit deeper into ukraine
ukraine <- filter(headlines, headlines$category=="Ukraine")

#only the last years

ukraine <- filter(ukraine, ukraine$date>"2020-08-01")
sum <- ukraine %>% 
  group_by(month_year = floor_date(date, unit ="month")) %>%
  summarise(mean_score= mean(rauhExpansion_dic_score))

#sum$year <- as.factor(sum$year)

ggplot(sum, aes(x=month_year, y= mean_score)) +
  geom_point()+
  geom_smooth()+
  labs(y="Mean Dictionary Score" ,title= paste("Dictionary Sentiment Analysis Ukraine 2020-2023"))+
  scale_x_date(breaks= "1 month", date_labels =  "%b%Y") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))





  






