# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Project/Code")

# Clear the environment by removing any defined objects/functions
rm(list = ls())

library(stm)
library(tidyverse)
library(quanteda)
library(ggforce)
library(Rtsne)
library(rsvd)
library(geometry)
library(tm)

#load headlines and filter it by category Coronavirus
#we used our classifications for  Naive Bayes as one covariate,; hence we have to load the dataset which include the scores

load("headlines_withNaiveBayesScore.Rdata")

covid <- filter(headlines, headlines$category=="Coronavirus")

glimpse(covid)


#create corpus
covid_corpus <- covid %>%
  corpus(text_field = "title")

#one option is creating a dfm and then 
#convert dfm to an object that can be used with stm
#covid_stm <- convert(covid_dfm, to ="stm")
#alternative: we use the approach decribed in https://cran.r-project.org/web/packages/stm/vignettes/stmVignette.pdf
#for preprocessing by using the tm package

#ingest and prepare documents
processed <- textProcessor(covid$title, metadata = covid)

#prepDocuments removes infrequent
#terms depending on the user-set parameter lower.thresh. 
# we will plot the number of words and documents removed for different thresholds in order to
#to evaluate how many words and documents would be removed from the dataset at each word
#threshold, which is the minimum number of documents a word needs to appear in order for
#the word to be kept


#threshold to remove rarely used words
plotRemoved(processed$documents, lower.thresh = seq(1,25, by=1))

out <-prepDocuments(processed$documents,
                    processed$vocab,
                    processed$meta,
                    lower.thresh = 1)

#as the training of the model is time consuming we set up a Google Cloud Virtual Machine 
#and trained the models there (code below was run on virtual machine)
#we load them now here:

load("model_lee_mimoCovid.Rdata")
load("searchKCovid.Rdata")
load("modelCovid.Rdata")


#use preliminary selection strategy based on work by Lee and Mimno (2014) (https://dl.acm.org/doi/pdf/10.5555/2145432.2145462)
#When initialization type is set to "Spectral" the user can specify K=0 to use the algorithm of
#Lee and Mimno (2014) to select the number of topics (K)
model_lee_mimo <- stm(documents = out$documents,
                      vocab      = out$vocab,
                      K          = 0, #instructs STM to run Lee_Mimo
                      seed       = 1234,
                      prevalence =  ~ outlet + year + classificationNaiveBayes,
                      #content = ~ human_coding,
                      data       = out$meta,
                      init.type = "Spectral",
                      #max.em.its = 150,
                      verbose =TRUE)


#search K
search_k <- searchK(documents  = out$documents,
                   vocab      = out$vocab,
                   K          = seq(5,60, by=5),
                   prevalence =  ~ outlet + year + classificationNaiveBayes,
                   data       = out$meta,
                   #max.em.its = 150,
                   #core=10,
                   init.type = "Spectral",
                   verbose=TRUE)
load("searchKCovid.Rdata")

search_k
plot(search_k)

df  <- search_k$results 

df$semcoh <- unlist(df$semcoh)
df$exclus <- unlist(df$exclus)
df$K <- unlist(df$K)
df <- df %>%
  mutate(K = as.factor(K))

df %>% 
  ggplot(aes(semcoh, exclus, col = K)) +
  geom_point(size = 3) +
  geom_mark_ellipse(aes(filter = K %in% c(10, 15, 20,25)), 
                   col = "red", description = "Potentials best candidates for K") +
  labs(x = "Semantic Coherence", y = "Exclusivity") +
  theme(legend.position = "bottom")

modelCovid<- stm(documents = out$documents,
             vocab      = out$vocab,
             K          = 25, 
             seed       = 1234,
             prevalence =  ~ outlet + year + classificationNaiveBayes, 
             data       = out$meta,
             init.type = "Spectral",
             #max.em.its = 150,
             verbose =TRUE)


model <- modelCovid
labelTopics(model)
plot(model)

#inspect topic 1
cloud(model, topic= 1)

doc <- covid[-out$docs.removed,] # remove docs which were removed in preprocessing
thought1 <- findThoughts(model= model, texts= doc$title,  topic=1)
thought1

stm_effects <- estimateEffect(c(1)~outlet+ year + classificationNaiveBayes, model, metadata = out$meta)
p1 <-plot.estimateEffect(stm_effects, covariate = "outlet", method = "pointestimate")
p2 <-plot.estimateEffect(stm_effects, covariate = "classificationNaiveBayes", method = "pointestimate")
p3 <-plot.estimateEffect(stm_effects, covariate = "year", method = "pointestimate")
p4 <-plot.estimateEffect(stm_effects, covariate = "classificationNaiveBayes", method = "difference", cov.value1 = 1, cov.value2 = 0)

ggarrange(p1, p2, p3, p4, 
          labels = c("A", "B", "C", "D"),
          ncol = 2, nrow = 2)

#content 
#plot(model, topics= c(12), type ="perspectives", main= labelTopics(model, n=3)$frex[12,])
#labelTopics(model, n=3)


