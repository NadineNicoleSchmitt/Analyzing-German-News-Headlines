
# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Project")

# Clear the environment by removing any defined objects/functions
rm(list = ls())

library(readr)
library(quanteda)
library(text2vec)
library(quanteda.textstats)
library(quanteda.textplots)
library(umap)
library(tidyverse)
library(superheat)
#library(Rtsne)
#library(PsychWordVec)
library(data.table)
library(googleLanguageR)
library(cocor)
library(formattable)
library(reactablefmtr)


#load headlines
load("Code/Data/headlines.Rdata")


#create corpus
headlines_corpus <- corpus(headlines,
                           text_field = "title")

#create fcm
headlines_fcm <- headlines_corpus %>%
  tokens() %>%
  tokens_tolower() %>%
  tokens_remove(stopwords("de")) %>%
  tokens(remove_punct = TRUE) %>%
  tokens(remove_numbers = TRUE) %>%
  fcm(context ="window",
      window =3,
      tri = FALSE)
headlines_fcm
dim(headlines_fcm)

#topfeatures 
topfeat <- names(topfeatures(headlines_fcm, n=50))


headlines_fcm_top <- fcm_select(headlines_fcm, pattern =topfeat) 
dim(headlines_fcm_top)

headlines_fcm_top%>%
  textplot_network(min_freq = 0.8, 
                   vertex_labelsize = rowSums(headlines_fcm_top)/min(rowSums(headlines_fcm_top)), title ="HI")

###################################
#function for plotting network for categories
#name is string with category, e.g. "Klimawandel"
#n is number of features to plot
plotNetwork <- function(name, N){
  
  categ <- filter(headlines, headlines$category==name)
  
  categ_corpus <- corpus(categ, text_field = "title")
  
  #create fcm
  categ_fcm <- categ_corpus %>%
    tokens() %>%
    tokens_tolower() %>%
    tokens_remove(stopwords("de")) %>%
    tokens(remove_punct = TRUE) %>%
    tokens(remove_numbers = TRUE) %>%
    fcm(context ="window",
        window =3,
        tri = FALSE)
  
  #topfeatures 
  topfeat <- names(topfeatures(categ_fcm, n=N))
  
  categ_fcm_top <- fcm_select(categ_fcm, pattern =topfeat) 
  #dim(headlines_fcm_top)
  
  categ_fcm_top%>%
    textplot_network(min_freq = 0.8, 
                     vertex_labelsize = rowSums(categ_fcm_top)/min(rowSums(categ_fcm_top)))
  
}

plotNetwork("Klimawandel",50)
plotNetwork("Migration", 50)
plotNetwork("Coronavirus", 50)
plotNetwork("Ukraine", 50)
plotNetwork("Rassismus", 50)
plotNetwork("Digitalisierung",50)
plotNetwork("Bildung", 50)
plotNetwork("Arbeitsmarkt", 50)


####################################
#Word Embeddings


#create corpus
headlines_corpus <- corpus(headlines,
                           text_field = "title")

#create fcm
#not removing stopwords, punct, numbers
headlines_fcm <- headlines_corpus %>%
  tokens() %>%
  tokens_tolower() %>%
  #tokens_remove(stopwords("de")) %>%
  #tokens(remove_punct = TRUE) %>%
  #tokens(remove_numbers = TRUE) %>%
  fcm(context ="window",
      window =3,
      tri = FALSE)
headlines_fcm
dim(headlines_fcm)


#fit GloVe model
glove = GlobalVectors$new(rank=150, x_max =2500L, learning_rate=.145)
headlines_main = glove$fit_transform(headlines_fcm, n_iter=500, convergence_tol = 0.005,
                                     n_threads=3)
#extract word embeddinngs
headlines_context = glove$components
word_vectors = headlines_main + t(headlines_context)
str(word_vectors)

save(word_vectors, file= "wordEmbeddingsGloVe.Rdata")
load("Code/wordEmbeddingsGloVe.Rdata")

#fit GloVe model with dim=300
glove300 = GlobalVectors$new(rank=300, x_max =2500L, learning_rate=.145)
headlines_main = glove300$fit_transform(headlines_fcm, n_iter=500, convergence_tol = 0.005,
                                     n_threads=3)
#extract word embeddinngs
headlines_context = glove300$components
word_vectors300 = headlines_main + t(headlines_context)
str(word_vectors300)

save(word_vectors300, file= "wordEmbeddingsGloVe300.Rdata")
load("wordEmbeddingsGloVe300.Rdata")

##############################################

#function to calculate similarities
#target_word: word for which we would like to calculate similarities
#n: number of nearest neighbouring words returned
#embedding: word embeddings
similarities <- function(target_word, n, embedding){
  
  # Extract embedding of target word
  target_vector <- embedding[which(rownames(embedding) %in% target_word),]  
  
  # Calculate cosine similarity between target word and other words
  target_sim <- sim2(embedding, matrix(target_vector, nrow = 1))
  
  # Report nearest neighbours of target word
  names(sort(target_sim[,1], decreasing = T))[1:n]
  
  #report also similarity score
  sort(target_sim[,1], decreasing = T)[1:n]
  
}

#do it manually for "cdu"
cdu <- word_vectors[which(rownames(word_vectors)=="cdu"),]
cdu_sim <- sim2(word_vectors, matrix(cdu, nrow=1))
sort(cdu_sim[,1], decreasing=T)[1:10]

#with function
similarities("cdu", 10, word_vectors)
similarities("merkel", 10, word_vectors)
similarities("twitter", 10, word_vectors)
similarities("biontech", 10, word_vectors)
similarities("ukraine", 10, word_vectors)
similarities("scholz", 10, word_vectors)
similarities("inflation", 10, word_vectors)
similarities("lauterbach", 10, word_vectors)
similarities("ischgl", 10, word_vectors)
similarities("vw", 10, word_vectors)
similarities("panzer", 10, word_vectors)
similarities("nato", 10, word_vectors)




#function to calculate analogies
#a is to b as c is to....
#target <- king -men + women
#a: men
#b: women
#c: king
analogies <- function(a, b, c, n, embedding){
  
  # Extract vectors for each of the three words in analogy task
  a_vec <- embedding[which(rownames(embedding) == a),]
  b_vec <- embedding[which(rownames(embedding) == b),]
  c_vec <- embedding[which(rownames(embedding) == c),]
  
  # Generate analogy vector (vector(c) - vector(a) + vector(b))
  target <- c_vec - a_vec + b_vec
  
  # Calculate cosine similarity between anaology vector and all other vectors
  target_sim <- sim2(embedding, matrix(target, nrow = 1))
  
  # Report nearest neighbours of analogy vector
  sort(target_sim[,1], decreasing = T)[1:n]
  
}

#manually
men <- word_vectors[which(rownames(word_vectors)=="deutschland"),]
women <- word_vectors[which(rownames(word_vectors)=="frankreich"),]
king <- word_vectors[which(rownames(word_vectors)=="berlin"),]

target <- king -men + women
target_sim <- sim2(word_vectors, matrix(target, nrow=1))
sort(target_sim[,1], decreasing=T)[1:10]

#with function
analogies("deutschland", "frankreich", "berlin", 10, word_vectors)
analogies("deutschland", "usa", "merkel", 10, word_vectors)
analogies("merkel", "scholz", "cdu", 10, word_vectors)
analogies("studenten", "schüler", "universität", 10, word_vectors)
analogies("paris", "london", "frankreich", 10, word_vectors)

analogies("deutschland", "china", "europa", 10, word_vectors)
analogies("mann", "frau", "könig", 10, word_vectors)


#Visualising cosine similarity for the 40 most common words
# code from https://rlbarter.github.io/superheat-examples/word2vec/

#extract 40 most common features

headlines_fcm_without_puncNumStop <- headlines_corpus %>%
  tokens() %>%
  tokens_tolower() %>%
  tokens_remove(stopwords("de")) %>%
  tokens(remove_punct = TRUE) %>%
  tokens(remove_numbers = TRUE) %>%
  fcm(context ="window",
      window =3,
      tri = FALSE)

forty_topfeat <- names(topfeatures(headlines_fcm_without_puncNumStop, n=40))
head(forty_topfeat,40)

CosineFun <- function(x, y){
  # calculate the cosine similarity between two vectors: x and y
  c <- sum(x*y) / (sqrt(sum(x * x)) * sqrt(sum(y * y)))
  return(c)
}

CosineSim <- function(X) {
  # calculate the pairwise cosine similarity between columns of the matrix X.
  # initialize similarity matrix
  m <- matrix(NA, 
              nrow = ncol(X),
              ncol = ncol(X),
              dimnames = list(colnames(X), colnames(X)))
  cos <- as.data.frame(m)
  
  # calculate the pairwise cosine similarity
  for(i in 1:ncol(X)) {
    for(j in i:ncol(X)) {
      co_rate_1 <- X[which(X[, i] & X[, j]), i]
      co_rate_2 <- X[which(X[, i] & X[, j]), j]  
      cos[i, j] <- CosineFun(co_rate_1, co_rate_2)
      # fill in the opposite diagonal entry
      cos[j, i] <- cos[i, j]        
    }
  }
  return(cos)
}

# calculate the cosine similarity matrix  between the forty most common words
cosineSimilarity <- CosineSim(t(word_vectors[forty_topfeat, ]))

#Since the diagonal similarity values are all 1 
#(the similarity of a word with itself is 1), 
#and this can skew the color scale, we make a point of setting these values to NA.

diag(cosineSimilarity) <- NA

#plot superheat
superheat(cosineSimilarity, 
          
          # place dendrograms on columns and rows 
          row.dendrogram = T, 
          col.dendrogram = T,
          
          # make gridlines white for enhanced prettiness
          grid.hline.col = "white",
          grid.vline.col = "white",
          
          # rotate bottom label text
          bottom.label.text.angle = 90,
          
          #legend.breaks = c(-0.1, 0.1, 0.3, 0.5)
)




#Translation of goldstandards to evaluate word embeddings
#as the words are in English, we translate them into German 
#using googleLanguageR

# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data/SimilarityTasks")

#we need a authenfication for API
gl_auth("key.json")

#translation <- gl_translate("Mum", target = "de", format = "text")
#translation
# A tibble: 1 × 3
#translatedText detectedSourceLanguage text 
#<chr>          <chr>                  <chr>
#  1 Mama           en                     Mum  


wordsim353 <- read.delim("wordsim_similarity_goldstandard.txt")

#translate first word
translation_w1 <- NULL
for(i in wordsim353$w1){
  translation <- gl_translate(i, target = "de", format = "text")
  translation <- translation$translatedText
  translation <- tolower(translation)
  translation_w1 <- append(translation_w1, translation)
}

wordsim353$w1_german <- translation_w1

#translate second word
translation_w2 <- NULL
for(i in wordsim353$w2){
  translation <- gl_translate(i, target = "de", format = "text")
  translation <- translation$translatedText
  translation <- tolower(translation)
  translation_w2 <- append(translation_w2, translation)
}
wordsim353$w2_german <- translation_w2

#save
save(wordsim353, file= "wordsim353_german.Rdata")


#SimLex-999

simlex999 <- read.delim("SimLex-999.txt")
simlex999 <- simlex999[,c(1,2,4)]

#translate first word
translation_w1 <- NULL
for(i in simlex999$w1){
  translation <- gl_translate(i, target = "de", format = "text")
  translation <- translation$translatedText
  translation <- tolower(translation)
  translation_w1 <- append(translation_w1, translation)
}

simlex999$w1_german <- translation_w1

#translate second word
translation_w2 <- NULL
for(i in simlex999$w2){
  translation <- gl_translate(i, target = "de", format = "text")
  translation <- translation$translatedText
  translation <- tolower(translation)
  translation_w2 <- append(translation_w2, translation)
}
simlex999$w2_german <- translation_w2

#save
save(simlex999, file= "simlex999_german.Rdata")


#RG65

rg65 <- read.csv("RG65.csv", sep=";")

#translate first word
translation_w1 <- NULL
for(i in rg65$w1){
  translation <- gl_translate(i, target = "de", format = "text")
  translation <- translation$translatedText
  translation <- tolower(translation)
  translation_w1 <- append(translation_w1, translation)
}

rg65$w1_german <- translation_w1

#translate second word
translation_w2 <- NULL
for(i in rg65$w2){
  translation <- gl_translate(i, target = "de", format = "text")
  translation <- translation$translatedText
  translation <- tolower(translation)
  translation_w2 <- append(translation_w2, translation)
}
rg65$w2_german <- translation_w2

#save
save(rg65, file= "rg65_german.Rdata")




#load pretrained GloVe embeddings 
#https://www.deepset.ai/german-word-embeddings
x <- fread("https://int-emb-glove-de-wiki.s3.eu-central-1.amazonaws.com/vectors.txt", data.table = F)

preTrained <- as.matrix(x[-1])

names <- x$V1
#head(names)
rownames(preTrained) <- names
#head(preTrained)

column <- colnames(word_vectors)
save(preTrained, file= "preTrained.Rdata")


#evaluation

#compute similarity between two words in goldstandard wordsim353 for our embeddings
  
self_trained <- NULL
pre_trained <- NULL
for(i in 1:nrow(wordsim353)){
  print(i)
  #print(wordsim353$w1_german[i])
  #check if word is in goldstandard
  #if not similarity is set to 0
  if(wordsim353$w1_german[i] %in% rownames(word_vectors) && wordsim353$w2_german[i] %in% rownames(word_vectors)){
    w1_self <- word_vectors[which(rownames(word_vectors)== wordsim353$w1_german[i]),]
    w2_self <- word_vectors[which(rownames(word_vectors) == wordsim353$w2_german[i]), ]
    sim <- sim2(matrix(w1_self, nrow=1), matrix(w2_self, nrow=1) )
  }else{
    sim <-0}
  print(sim)
  self_trained <- append(self_trained, sim)
  #print(self_trained)
  
  if(wordsim353$w1_german[i] %in% rownames(preTrained) && wordsim353$w2_german[i] %in% rownames(preTrained)){
    w1_pre <- preTrained[which(rownames(preTrained)== wordsim353$w1_german[i]),]
    w2_pre <- preTrained[which(rownames(preTrained) == wordsim353$w2_german[i]), ]
    sim <- sim2(matrix(w1_pre, nrow=1), matrix(w2_pre, nrow=1) )
  }else{
    sim <-0}
  #print(sim)
  pre_trained <- append(pre_trained, sim)
  
}

wordsim353$self_trained_score <- self_trained
wordsim353$pre_trained_score <- pre_trained
#save
save(wordsim353, file= "wordsim353_german_evaluated.Rdata")


#compute similarity between two words in goldstandard simlex99 for our embeddings

self_trained <- NULL
pre_trained <- NULL
for(i in 1:nrow(simlex999)){
  print(i)
  #print(wordsim353$w1_german[i])
  #check if word is in goldstandard
  #if not similarity is set to 0
  if(simlex999$w1_german[i] %in% rownames(word_vectors) && simlex999$w2_german[i] %in% rownames(word_vectors)){
    w1_self <- word_vectors[which(rownames(word_vectors)== simlex999$w1_german[i]),]
    w2_self <- word_vectors[which(rownames(word_vectors) == simlex999$w2_german[i]), ]
    sim <- sim2(matrix(w1_self, nrow=1), matrix(w2_self, nrow=1) )
  }else{
    sim <-0}
  print(sim)
  self_trained <- append(self_trained, sim)
  #print(self_trained)
  
  if(simlex999$w1_german[i] %in% rownames(preTrained) && simlex999$w2_german[i] %in% rownames(preTrained)){
    w1_pre <- preTrained[which(rownames(preTrained)== simlex999$w1_german[i]),]
    w2_pre <- preTrained[which(rownames(preTrained) == simlex999$w2_german[i]), ]
    sim <- sim2(matrix(w1_pre, nrow=1), matrix(w2_pre, nrow=1) )
  }else{
    sim <-0}
  #print(sim)
  pre_trained <- append(pre_trained, sim)
  
}

simlex999$self_trained_score <- self_trained
simlex999$pre_trained_score <- pre_trained
#save
save(simlex999, file= "simlex999_german_evaluated.Rdata")



#compute similarity between two words in goldstandard rg65 for our embeddings

self_trained <- NULL
pre_trained <- NULL
for(i in 1:nrow(rg65)){
  print(i)
  #print(wordsim353$w1_german[i])
  #check if word is in goldstandard
  #if not similarity is set to 0
  if(rg65$w1_german[i] %in% rownames(word_vectors) && rg65$w2_german[i] %in% rownames(word_vectors)){
    w1_self <- word_vectors[which(rownames(word_vectors)== rg65$w1_german[i]),]
    w2_self <- word_vectors[which(rownames(word_vectors) == rg65$w2_german[i]), ]
    sim <- sim2(matrix(w1_self, nrow=1), matrix(w2_self, nrow=1) )
  }else{
    sim <-0}
  print(sim)
  self_trained <- append(self_trained, sim)
  #print(self_trained)
  
  if(rg65$w1_german[i] %in% rownames(preTrained) && rg65$w2_german[i] %in% rownames(preTrained)){
    w1_pre <- preTrained[which(rownames(preTrained)== rg65$w1_german[i]),]
    w2_pre <- preTrained[which(rownames(preTrained) == rg65$w2_german[i]), ]
    sim <- sim2(matrix(w1_pre, nrow=1), matrix(w2_pre, nrow=1) )
  }else{
    sim <-0}
  #print(sim)
  pre_trained <- append(pre_trained, sim)
  
}

rg65$self_trained_score <- self_trained
rg65$pre_trained_score <- pre_trained
#save
save(rg65, file= "rg65_german_evaluated.Rdata")



evaluation_tabel <- data.frame(goldstandard = c("WordSim353", "SimLex999", "RG65"), 
                               Pearson_Self = c(0,0,0),
                               p_value_Self= c(0,0,0),
                               Pearson_Pre =c(0,0,0), 
                               p_value_Pre= c(0,0,0))

#formattable(evaluation_tabel)


#correlations/cocor wordsim353

pearson_wordsim353_self <- cor.test(wordsim353$score, wordsim353$self_trained_score)
pearson_wordsim353_pre <-  cor.test(wordsim353$score, wordsim353$pre_trained_score)
pearson_wordsim353_pre_self <- cor(wordsim353$self_trained_score, wordsim353$pre_trained_score)

cocor.dep.groups.overlap(r.jk= pearson_wordsim353_self$estimate , r.jh= pearson_wordsim353_pre$estimate, 
                         r.kh= pearson_wordsim353_pre_self, n=203, 
                         alternative="two.sided", alpha=0.05, conf.level=0.95, null.value=0)
#spearman
#spearman_wordsim353_self <- cor.test(wordsim353$score, wordsim353$self_trained_score, method="spearman")
#spearman_wordsim353_pre <-  cor.test(wordsim353$score, wordsim353$pre_trained_score, method ="spearman")


evaluation_tabel$Pearson_Self[1] <- pearson_wordsim353_self$estimate
evaluation_tabel$p_value_Self[1] <- pearson_wordsim353_self$p.value
evaluation_tabel$Pearson_Pre[1] <- pearson_wordsim353_pre$estimate
evaluation_tabel$p_value_Pre[1] <- pearson_wordsim353_pre$p.value

#correlations/cocor simlex999

pearson_simlex999_self <- cor.test(simlex999$score, simlex999$self_trained_score)
pearson_simlex999_pre <-  cor.test(simlex999$score, simlex999$pre_trained_score)
pearson_simlex999_pre_self <- cor(simlex999$self_trained_score, simlex999$pre_trained_score)

cocor.dep.groups.overlap(r.jk= pearson_simlex999_self$estimate , r.jh= pearson_wordsim353_pre$estimate, 
                         r.kh= pearson_simlex999_pre_self, n=999, 
                         alternative="two.sided", alpha=0.05, conf.level=0.95, null.value=0)

evaluation_tabel$Pearson_Self[2] <- pearson_simlex999_self$estimate
evaluation_tabel$p_value_Self[2] <- pearson_simlex999_self$p.value
evaluation_tabel$Pearson_Pre[2] <- pearson_simlex999_pre$estimate
evaluation_tabel$p_value_Pre[2] <- pearson_simlex999_pre$p.value


#correlations/cocor rg65

pearson_rg65_self <- cor.test(rg65$score, rg65$self_trained_score)
pearson_rg65_pre <-  cor.test(rg65$score, rg65$pre_trained_score)
pearson_rg65_pre_self <- cor(rg65$self_trained_score, rg65$pre_trained_score)

cocor.dep.groups.overlap(r.jk= pearson_rg65_self$estimate , r.jh= pearson_rg65_pre$estimate, 
                         r.kh= pearson_rg65_pre_self, n=65, 
                         alternative="two.sided", alpha=0.05, conf.level=0.95, null.value=0)

evaluation_tabel$Pearson_Self[3] <- pearson_rg65_self$estimate
evaluation_tabel$p_value_Self[3] <- pearson_rg65_self$p.value
evaluation_tabel$Pearson_Pre[3] <- pearson_rg65_pre$estimate
evaluation_tabel$p_value_Pre[3] <- pearson_rg65_pre$p.value


#formattable(evaluation_tabel)

formattable(evaluation_tabel, list(
  Pearson_Self = formatter("span", 
                        style = ~ style(color = ifelse(Pearson_Pre < Pearson_Self, "green", "black"))),
  Pearson_Pre = formatter("span", 
                           style = ~ style(color = ifelse(Pearson_Self < Pearson_Pre, "green", "black"))))
  )
