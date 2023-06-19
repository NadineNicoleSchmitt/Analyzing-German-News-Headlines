# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Project/Code")

# Clear the environment by removing any defined objects/functions
rm(list = ls())

library(quanteda)
library(quanteda.textmodels)
library(tidyverse)
library(caret)
library(formattable)
library(circIMPACT)
library(ggpubr)
library(scales)
library(slider)
library(ggpubr)
library(ggforce)

#load data
load("Data/headlines.Rdata")

headlinesLabeled <- filter(headlines, headlines$labeling == TRUE) #we use this for estimate the model
headlinesNotLabeled <- filter(headlines, headlines$labeling == FALSE)

#create a corpus and a dfm for our headlinesLabeled dataset
#we calculate it for 6 different models (feature selection)

df <- data.frame(Features = c("Unigram",
                              "Unigram, No stopwords",
                              "Unigram, No stopwords, No punctuation & numbers",
                              "Bigram",
                              "Bigram, No stopwords",
                              "Bigram, No stopwords, No punctuation & numbers"))
rownames(df) <- c("Model1", "Model2", "Model3", "Model4", "Model5", "Model6")
formattable(df)

corpus <- corpus(headlinesLabeled,
                 text_field = "title")

#model1
dfm1 <-  corpus %>% 
  tokens() %>%
  dfm()

#model2
dfm2 <-  corpus %>% 
  tokens() %>%
  tokens_remove(stopwords("de")) %>%
  dfm()

#model3
dfm3 <-  corpus %>% 
  tokens() %>%
  tokens_remove(stopwords("de")) %>%
  tokens(remove_punct = TRUE, remove_numbers = TRUE) %>%
  dfm()

#model4
dfm4 <-  corpus %>% 
  tokens() %>%
  tokens_ngrams(1:2) %>%
  dfm()

#model5
dfm5 <-  corpus %>% 
  tokens() %>%
  tokens_ngrams(1:2) %>%
  tokens_remove(stopwords("de")) %>%
  dfm()

#model6
dfm6 <-  corpus %>% 
  tokens() %>%
  tokens_ngrams(1:2) %>%
  tokens_remove(stopwords("de")) %>%
  tokens(remove_punct = TRUE, remove_numbers = TRUE) %>%
  dfm()


#cross validation

#function which takes a vector of logical values as input that has 
#TRUE values for observations in the held out set and FALSE for observations in the training set

#we also give the dfm as input

get_performance_scores <- function(held_out){
  
  # Set up train and test sets for this fold
  dfm_train <- dfm_subset(dfm6, !held_out)
  dfm_test <- dfm_subset(dfm6, held_out)
  
  # Train model on everything except held-out fold
  nb_train <- textmodel_nb(x = dfm_train, 
                           y = dfm_train$human_coding,
                           prior = "docfreq")
  
  # Predict for held-out fold
  dfm_test$predicted_classification <- predict(nb_train, 
                                               newdata = dfm_test, 
                                               type = "class")
  
  # Calculate accuracy, specificity, sensitivity
  confusion_nb <- table(predicted_classification = dfm_test$predicted_classification,
                        true_classification = dfm_test$human_coding)
  #print(confusion_nb)
  
  confusion_nb_statistics <- confusionMatrix(confusion_nb, positive = "Negative")
  
  accuracy <- confusion_nb_statistics$overall[1]
  sensitivity <- confusion_nb_statistics$byClass[1]
  specificity <- confusion_nb_statistics$byClass[2]
  
  return(data.frame(accuracy, sensitivity, specificity))
  
}

#create a vector representing the K folds
K <- 10
folds <- sample(c(1:K), nrow(headlinesLabeled), replace =T)


#apply performance score function to all folds
model <- lapply(1:K, function(k) get_performance_scores(folds==k))
x <- colMeans(bind_rows(model))

result <- data.frame(Model1 = c(4,2,3),
                     Model2 = c(2,30,4),
                     Model3 = c(31,12,14),
                     Model4 = c(40,0,0),
                     Model5 = c(0,40,0),
                     Model6 = c(0,0,50))
rownames(result) <- c("Accuracy", "Sensitivity", "Specificity")

result[1,6] <- x[1]
result[2,6] <- x[2]
result[3,6] <- x[3]

formattable(result, list(
  Model1 = formatter("span", 
                    style = ~ style(color = ifelse(Model1 > Model2 & Model1 > Model3 &
                    Model1 > Model4 & Model1 > Model5 & Model1 > Model6,
                    "green", "black"))),
  Model2 = formatter("span", 
                     style = ~ style(color = ifelse(Model2 > Model1 & Model2 > Model3 &
                                                      Model2 > Model4 & Model2 > Model5 & Model2 > Model6,
                                                    "green", "black"))),
  Model3 = formatter("span", 
                     style = ~ style(color = ifelse(Model3 > Model1 & Model3 > Model2 &
                                                      Model3 > Model4 & Model3 > Model5 & Model3 > Model6,
                                                    "green", "black"))),
  Model4 = formatter("span", 
                     style = ~ style(color = ifelse(Model4 > Model1 & Model4 > Model2 &
                                                      Model4 > Model3 & Model4 > Model5 & Model4 > Model6,
                                                    "green", "black"))),
  Model5 = formatter("span", 
                     style = ~ style(color = ifelse(Model5 > Model1 & Model5 > Model2 &
                                                      Model5 > Model3 & Model5 > Model4 & Model5 > Model6,
                                                    "green", "black"))),
  Model6 = formatter("span", 
                     style = ~ style(color = ifelse(Model6 > Model1 & Model6 > Model2 &
                                                      Model6 > Model3 & Model6 > Model4 & Model6 > Model5,
                                                    "green", "black")))))

#############################################################################################

#use best model and make predictions 
#best model: model6

#we now use our entire labeled dataset to train the naive model using the "best" dfm

nb_model_best <- textmodel_nb(x = dfm6,
                              y = dfm6$human_coding,
                              prior = "docfreq")

#inspect words with the highest probability in the Negative class
#head(coef(nb_model_best)) negative class is in column 1
head(sort(coef(nb_model_best)[,1], decreasing = TRUE),50)

#highest probability in NotNegative class
head(sort(coef(nb_model_best)[,2], decreasing = TRUE),50)


#inspect headlines with highest probability to Negative class
dfm6$predicted_probability <- predict(nb_model_best, type = "probability")

dfm6$id[order(dfm6$predicted_probability[,1], decreasing=TRUE)[1:10]]
#489588 123237 466521 322150 432726 430654 431046 464151 463594 322350
headlinesLabeled$title[headlinesLabeled$id == 489588]
headlinesLabeled$title[headlinesLabeled$id == 123237]
headlinesLabeled$title[headlinesLabeled$id == 466521]
headlinesLabeled$title[headlinesLabeled$id == 322150]
headlinesLabeled$title[headlinesLabeled$id == 432726]


#inspect headlines with highest probability to NotNegative class
dfm6$id[order(dfm6$predicted_probability[,2], decreasing=TRUE)[1:100]]
#495625 159766 193077 196022 196454 196975 197309 198963 203239 204427 208828 209795 211113 211618 336451
headlinesLabeled$title[headlinesLabeled$id == 159766]
headlinesLabeled$title[headlinesLabeled$id == 193077]
headlinesLabeled$title[headlinesLabeled$id == 25395]
headlinesLabeled$title[headlinesLabeled$id == 488032]
headlinesLabeled$title[headlinesLabeled$id == 272790]

#classification
dfm6$predicted_classification <- predict(nb_model_best, type = "class")



# Calculate accuracy, specificity, sensitivity
confusion_nb <- table(predicted_classification = dfm6$predicted_classification,
                      true_classification = dfm6$human_coding)
confusion_nb

confusion_nb_statistics <- confusionMatrix(confusion_nb, positive = "Negative")
confusion_nb_statistics

accuracy <- confusion_nb_statistics$overall[1]
sensitivity <- confusion_nb_statistics$byClass[1]
specificity <- confusion_nb_statistics$byClass[2]

#classify for all other observations

#create corpus and dfm for headlinesNotLabeled

corpus_notLabeled <- corpus(headlinesNotLabeled,
                 text_field = "title")


dfm6_notLabeled <- corpus_notLabeled %>% 
  tokens() %>%
  tokens_ngrams(1:2) %>%
  tokens_remove(stopwords("de")) %>%
  tokens(remove_punct = TRUE, remove_numbers = TRUE) %>%
  dfm() %>%
  dfm_match(features=featnames(dfm6)) #make sure that features of the new dfm matches the features of dfm6

#some face validating
dfm6_notLabeled$predicted_probability <- predict(nb_model_best, newdata = dfm6_notLabeled,
                                                 type = "probability")
#negative
dfm6_notLabeled$id[order(dfm6_notLabeled$predicted_probability[,1], decreasing=TRUE)[1:10]]
#286278 464750 490029 489321 465645  27346 280278 372551 391097 470735
headlinesNotLabeled$title[headlinesNotLabeled$id == 464750]
headlinesNotLabeled$title[headlinesNotLabeled$id == 490029]
headlinesNotLabeled$title[headlinesNotLabeled$id == 489321]
headlinesNotLabeled$title[headlinesNotLabeled$id == 470735]

#not negative
dfm6_notLabeled$id[order(dfm6_notLabeled$predicted_probability[,2], decreasing=TRUE)[5000:10000]]
#205469  33352  33461  33562  33896  34158  34231  34332  34338  34354
headlinesNotLabeled$title[headlinesNotLabeled$id == 205469]
headlinesNotLabeled$title[headlinesNotLabeled$id == 113143]
headlinesNotLabeled$title[headlinesNotLabeled$id == 334636]
headlinesNotLabeled$title[headlinesNotLabeled$id == 211146]
  
#predict classification
dfm6_notLabeled$predicted_classification <- predict(nb_model_best, 
                                                    newdata = dfm6_notLabeled,
                                                    type = "class")

table(dfm6_notLabeled$predicted_classification)  
  
  



##############################################################################################
#making naive guess (no model)

#take mean of our human_coding
negative <- table(headlinesLabeled$human_coding)

fraction <- negative[1]/(negative[1]+negative[2]) #0.589252  of the headlines are negative

#the naive guess is therefore Negative (because >0.5), i.e. every headline is negative

headlinesLabeled$naive <- as.factor("Negative")

table(headlinesLabeled$naive, headlinesLabeled$human_coding)

accuracy <- 6546/(6546+4563) #0.589252

#making the simpliest possible guess, we get an accuracy of 59%



############################################################################
#put the classification into the headlines dataframe in order to make some plots
prediction_Labeled <- data.frame(id = dfm6$id,
                                 classificationNaiveBayes = dfm6$predicted_classification)
prediction_NotLabeled <- data.frame(id = dfm6_notLabeled$id,
                                 classificationNaiveBayes = dfm6_notLabeled$predicted_classification)

prediction <- rbind(prediction_Labeled,prediction_NotLabeled )


headlines <- merge(headlines, prediction, by = "id", all.x = TRUE)

save(headlines, file ="headlines_withNaiveBayesScore.Rdata" )

#plot

#sum <- headlines %>%
  #group_by(year,category, classificationNaiveBayes) %>%
  #summarise(score= n())


sum <- headlines %>% 
  group_by(year,category, classificationNaiveBayes) %>%
  summarise(count= n()) %>%
  mutate(percentage = count/sum(count))
f <- formattable(sum)

#export_formattable(f, file= "test.pdf", width="100%", height="100%")
export_formattable(f, file= "ClassificationNaiveBayesResults.pdf", width="25%")

#only negative
sum_onlyNegative <- data.frame(year = sum$year, category =sum$category,
                               classificationNaiveBayes= sum$classificationNaiveBayes,
                               percentage =sum$percentage)
sum_onlyNegative$classificationNaiveBayes <- as.character(sum_onlyNegative$classificationNaiveBayes)
sum_onlyNegative <- filter(sum_onlyNegative, sum_onlyNegative$classificationNaiveBayes=="Negative")

sum_onlyNegative$year <- as.factor(sum_onlyNegative$year)

ggplot(sum_onlyNegative, aes(x=year, y= percentage, group=category)) +
  geom_line(aes(color=category))+
  geom_point(aes(color=category))+
  labs(y="Fraction of negative headlines",title= "Naive Bayes Classification (grouped by category)")

#plot grouped by outlet

sum <- headlines %>% 
  group_by(year,outlet, classificationNaiveBayes) %>%
  summarise(count= n()) %>%
  mutate(percentage = count/sum(count))

#only negative
sum_onlyNegative <- data.frame(year = sum$year, outlet =sum$outlet,
                               classificationNaiveBayes= sum$classificationNaiveBayes,
                               percentage =sum$percentage)
sum_onlyNegative$classificationNaiveBayes <- as.character(sum_onlyNegative$classificationNaiveBayes)
sum_onlyNegative <- filter(sum_onlyNegative, sum_onlyNegative$classificationNaiveBayes=="Negative")

sum_onlyNegative$year <- as.factor(sum_onlyNegative$year)

ggplot(sum_onlyNegative, aes(x=year, y= percentage, group=outlet)) +
  geom_line(aes(color=outlet))+
  geom_point(aes(color=outlet))+
  labs(y="Fraction of negative headlines", title = "Naive Bayes Classification (grouped by outlet)")



#plot for each category splitted up into outlets

plot_naive <- function(cat, NameCategory){
  cat <- filter(headlines, headlines$category==NameCategory)
  
  sum <- cat %>% 
    group_by(year,outlet, classificationNaiveBayes) %>%
    summarise(count= n()) %>%
    mutate(percentage = count/sum(count))
  
  #only negative
  sum_onlyNegative <- data.frame(year = sum$year, outlet =sum$outlet,
                                 classificationNaiveBayes= sum$classificationNaiveBayes,
                                 percentage =sum$percentage)
  sum_onlyNegative$classificationNaiveBayes <- as.character(sum_onlyNegative$classificationNaiveBayes)
  sum_onlyNegative <- filter(sum_onlyNegative, sum_onlyNegative$classificationNaiveBayes=="Negative")
  
  sum_onlyNegative$year <- as.factor(sum_onlyNegative$year)
  
  ggplot(sum_onlyNegative, aes(x=year, y= percentage, group=outlet)) +
    geom_line(aes(color=outlet))+
    geom_point(aes(color=outlet))+
    labs(y="Fraction of negative headlines",title= paste("Naive Bayes Classification", NameCategory))
  
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


#look a little bit deeper into covid
#only the last years

covid <- filter(covid, covid$year>2019)
sum <- covid %>% 
  group_by(date, classificationNaiveBayes) %>%
  summarise(count= n()) %>%
  mutate(percentage = count/sum(count))

#only negative
sum_onlyNegative <- data.frame(date = sum$date, classificationNaiveBayes= sum$classificationNaiveBayes,
                               percentage =sum$percentage)
sum_onlyNegative$classificationNaiveBayes <- as.character(sum_onlyNegative$classificationNaiveBayes)
sum_onlyNegative <- filter(sum_onlyNegative, sum_onlyNegative$classificationNaiveBayes=="Negative")


ggplot(sum_onlyNegative, aes(x=date, y= percentage)) +
  geom_point()+
  geom_smooth()+
  labs(y="Fraction of negative headlines",title= "Naive Bayes Classification Coronavirus 2020-2023")+
  scale_x_date(date_breaks = "1 month", date_labels =  "%b%Y") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))+
  #theme(axis.text.x=element_text(angle=60, hjust=1))
  geom_vline(xintercept=as.Date("2020-01-27"), linetype='dashed', color='pink')+
  annotate(x=as.Date("2020-01-27"),y=0.5,label="First Covid Case ",geom="label", color="pink")+
  geom_vline(xintercept=as.Date("2020-02-22"), linetype='dashed', color='red')+
  annotate(x=as.Date("2020-02-22"),y=1,label="Start First Lockdown ",geom="label", color='red')+
  geom_vline(xintercept=as.Date("2020-05-04"), linetype='dashed', color='green')+
  annotate(x=as.Date("2020-05-04"),y=0,label="End Lockdown",geom="label", color='green')+
  geom_vline(xintercept=as.Date("2020-11-02"), linetype='dashed', color='orange')+
  annotate(x=as.Date("2020-11-02"),y=0.5,label="Start Light Lockdown",geom="label", color='orange')+
  geom_vline(xintercept=as.Date("2021-01-06"), linetype='dashed', color='violet')+
  annotate(x=as.Date("2021-01-06"),y=1,label="Start Strict Lockdown",geom="label", color='violet')


covid <- filter(covid, covid$year>2019)
sum <- covid %>% 
  group_by(month_year = floor_date(date, unit ="month") , classificationNaiveBayes) %>%
  summarise(count= n()) %>%
  mutate(percentage = count/sum(count))

#only negative
sum_onlyNegative <- data.frame(month_year = sum$month_year, classificationNaiveBayes= sum$classificationNaiveBayes,
                               percentage =sum$percentage)
sum_onlyNegative$classificationNaiveBayes <- as.character(sum_onlyNegative$classificationNaiveBayes)
sum_onlyNegative <- filter(sum_onlyNegative, sum_onlyNegative$classificationNaiveBayes=="Negative")


ggplot(sum_onlyNegative, aes(x=month_year, y= percentage)) +
  geom_point()+
  geom_smooth()+
  labs(y="Fraction of negative headlines",title= "Naive Bayes Classification Coronavirus 2020-2023")+
  scale_x_date(breaks= "1 month", date_labels =  "%b%Y") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  geom_text(aes(label=ifelse(month_year=="2020-02-01","Start Covid & First Lockdown", "")),hjust=0, vjust=0)+
  geom_text(aes(label=ifelse(month_year=="2020-05-01","End first Lockdown", "")),hjust=0, vjust=0)+
  geom_text(aes(label=ifelse(month_year=="2020-11-01","Start Second Lockdown", "")),hjust=0, vjust=0)+
  geom_text(aes(label=ifelse(month_year=="2021-04-01","End Second Lockdown", "")),hjust=0, vjust=0)+
  geom_text(aes(label=ifelse(month_year=="2020-12-01","Start vaccination", "")),hjust=0, vjust=0)+
  geom_text(aes(label=ifelse(month_year=="2022-12-01","End of Covid-19", "")),hjust=0, vjust=0) +
  geom_mark_ellipse(aes(filter = month_year %in% c("2023-01-01", "2023-02-01", "2023-03-01", "2023-04-01")), 
                    col = "red", description = "Although Covid-19 pandemic is over") 
  


##see trend percentage and length of headlines

corpus <- corpus(headlines,
                 text_field = "title")
nTokens <- ntoken(corpus)

headlines$NToken <- nTokens

sum <- headlines %>% 
  group_by(month_year = floor_date(date, unit ="month"),outlet, classificationNaiveBayes) %>%
  summarise(count= n(), mean_Ntoken = mean(NToken)) %>%
  mutate(percentage = count/sum(count)) 

#only negative
sum_onlyNegative <- data.frame(month_year = sum$month_year, outlet = sum$outlet, classificationNaiveBayes= sum$classificationNaiveBayes,
                               percentage =sum$percentage, mean_Ntoken =sum$mean_Ntoken)
sum_onlyNegative$classificationNaiveBayes <- as.character(sum_onlyNegative$classificationNaiveBayes)
sum_onlyNegative <- filter(sum_onlyNegative, sum_onlyNegative$classificationNaiveBayes=="Negative")

ggplot(sum_onlyNegative, aes(x=percentage, y= mean_Ntoken)) +
  #geom_line(aes(color=outlet))+
  geom_point(aes(color=outlet))+
  geom_smooth()+
  labs(x= "Fraction of negative headlines", y="Length of headline (NToken)" ,
       title= "Fraction of negative headlines vs. Length of headline (NToken)")


