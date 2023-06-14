# Change working directory 
setwd("C:/Users/nadin/OneDrive/Dokumente/Quantitative_Text_Analysis/Data")

# Clear the environment by removing any defined objects/functions
rm(list = ls())

#load libaries
library(tidyverse)
library(formattable)
library(quanteda)
library(ggQC)
library(ggpubr)


load("headlines.Rdata")


#create table

df <- data.frame("bild.de" = c(0,0,0,0,0,0,0,0,0),
                 "FAZ" = c(0,0,0,0,0,0,0,0,0),
                 "Handelsblatt" = c(0,0,0,0,0,0,0,0,0),
                 "Spiegel" = c(0,0,0,0,0,0,0,0,0),
                 "SZ" = c(0,0,0,0,0,0,0,0,0),
                 "Welt" = c(0,0,0,0,0,0,0,0,0),
                 "Wirtschaftswoche" = c(0,0,0,0,0,0,0,0,0),
                 "ZeitOnline" = c(0,0,0,0,0,0,0,0,0),
                 "Total" = c(0,0,0,0,0,0,0,0,0))
                 
rownames(df) <- c("Arbeitsmarkt", "Bildung", "Coronavirus", "Digitalisierung", "Klimawandel",    
                  "Migration", "Rassismus", "Ukraine", "Total")
formattable(df)

sum <- headlines %>%
  group_by(outlet, category) %>%
  summarise(n())

sum<- with(sum, sum[order(outlet, category) , ])

df[1:8,1] <-  sum[1:8, 3]
df[1:8,2] <-  sum[9:16, 3]
df[1:8,3] <-  sum[17:24, 3]
df[1:8,4] <-  sum[25:32, 3]
df[1:8,5] <-  sum[33:40, 3]
df[1:8,6] <-  sum[41:48, 3]
df[1:8,7] <-  sum[49:56, 3]
df[1:8,8] <-  sum[57:64, 3]


df[9,1] <- sum(df$bild.de)
df[9,2] <- sum(df$FAZ)
df[9,3] <- sum(df$Handelsblatt)
df[9,4] <- sum(df$Spiegel)
df[9,5] <- sum(df$SZ)
df[9,6] <- sum(df$Welt)
df[9,7] <- sum(df$Wirtschaftswoche)
df[9,8] <- sum(df$ZeitOnline)
#df[9,9] <- sum(df$Total)

df[1,9] <- sum(df[1,])
df[2,9] <- sum(df[2,])
df[3,9] <- sum(df[3,])
df[4,9] <- sum(df[4,])
df[5,9] <- sum(df[5,])
df[6,9] <- sum(df[6,])
df[7,9] <- sum(df[7,])
df[8,9] <- sum(df[8,])
df[9,9] <- sum(df[9,])
formattable(df)

plot_pareto <- function(cat, NameCategory){
  #pareto chart arbeitsmarkcategoryt 
  cat <- filter(headlines, headlines$category==NameCategory)
  cat <- cat %>%
    group_by(outlet) %>%
    summarise(sum = n()) %>%
    arrange(desc(sum))
  
  #cumulative
  total <- sum(cat$sum)
  cat <- cat%>%
    mutate(cumfreq = cumsum(cat$sum), cumperc = cumfreq/total)
  
  #plot pareto chart
  cat_alpha <- cat[order(cat$outlet),]
  cum_percent <- cat$cumperc
  #cum_percent <- percent(round(cum_percent*100,2))
  cum_percent <- percent(cum_percent)
  cum_sum <- cat$cumfreq
  
  ggplot(cat_alpha, aes(x= outlet, y= sum))+
    stat_pareto(point.color ="red", point.size =3, line.color = "black",
                bars.fill = c("blue", "orange"))+
    #scale_y_continuous()+
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))+ 
    geom_label(aes(label= cum_percent, y=cum_sum, vjust=1.3))+
    labs(x = "Outlet", 
         y = "Number of headlines", 
         title= NameCategory)+
    theme(plot.caption = element_text(color="grey", size=5),#hjust=0 face ="italic"
          plot.subtitle = element_text(color ="darkgrey", size = 10),
          plot.title = element_text(face = "bold", size = 16),
          legend.position = "bottom")
}

p1 <- plot_pareto(filter(headlines, headlines$category=="Arbeitsmarkt"), "Arbeitsmarkt")
p2 <-plot_pareto(filter(headlines, headlines$category=="Bildung"), "Bildung")
p5 <-plot_pareto(filter(headlines, headlines$category=="Klimawandel"), "Klimawandel")
p6 <-plot_pareto(filter(headlines, headlines$category=="Migration"), "Migration")
p7 <-plot_pareto(filter(headlines, headlines$category=="Rassismus"), "Rassismus")
p3 <-plot_pareto(filter(headlines, headlines$category=="Coronavirus"), "Coronavirus")
p4 <-plot_pareto(filter(headlines, headlines$category=="Digitalisierung"), "Digitalisierung")
p8 <-plot_pareto(filter(headlines, headlines$category=="Ukraine"), "Ukraine")

ggarrange(p1, p2, p3, p4, p5, p6, p7, p8 ,
          #labels = c("A", "B", "C"),
          ncol = 2, nrow = 2)

########################################################################################

#plot a bar plot for each category with year on x-axis

plot_headlines <- function(cat, NameCategory){
  cat <- filter(headlines, headlines$category==NameCategory)
  
  ggplot(cat) + 
    geom_bar(aes(x=year, fill = outlet),stat="count", position="dodge") + 
    labs(x = "Year", 
         y = "Count", 
         title= NameCategory)
}

p1 <- plot_headlines(filter(headlines, headlines$category=="Arbeitsmarkt"), "Arbeitsmarkt")
p2 <-plot_headlines(filter(headlines, headlines$category=="Bildung"), "Bildung")
p5 <- plot_headlines(filter(headlines, headlines$category=="Klimawandel"), "Klimawandel")
p6 <-plot_headlines(filter(headlines, headlines$category=="Migration"), "Migration")
p7 <-plot_headlines(filter(headlines, headlines$category=="Rassismus"), "Rassismus")
p3 <-plot_headlines(filter(headlines, headlines$category=="Coronavirus"), "Coronavirus")
p4 <-plot_headlines(filter(headlines, headlines$category=="Digitalisierung"), "Digitalisierung")
p8 <-plot_headlines(filter(headlines, headlines$category=="Ukraine"), "Ukraine")


ggarrange(p1, p2, p3, p4, p5, p6, p7, p8 ,
          #labels = c("A", "B", "C"),
          ncol = 2, nrow = 2)

##############################################################################################

#histogram n_tokens

tokens <- headlines[c(1:5)]

#create corpus
tokens_corpus <-  corpus(tokens, text_field= "title")

#get ntokens
#ntokens <- ntoken(tokens_corpus)

# extract summary statistics of corpus
tokens_df <- summary(tokens_corpus, n = ndoc(tokens_corpus))


#plot against year, grouped by outlet
ggplot(data = tokens_df, aes(x = ymd(date), y = Tokens, color = outlet)) +
  geom_smooth(alpha = .6, linetype = 1, se = F, method = 'loess') +
  theme_bw() +
  theme(legend.position = 'right',
        plot.background = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        panel.border = element_blank())

#plot against year, grouped by category
ggplot(data = tokens_df, aes(x = ymd(date), y = Tokens, color = category)) +
  geom_smooth(alpha = .6, linetype = 1, se = F, method = 'loess') +
  theme_bw() +
  theme(legend.position = 'right',
        plot.background = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        panel.border = element_blank())



#density by outlet
ggplot(tokens_df, aes(x=Tokens))+
  geom_density(fill="white", color="black")+
  xlim(0,25)+
  facet_grid(outlet~.)

#density by category
ggplot(tokens_df, aes(x=Tokens))+
  geom_density(fill="white", color="black")+
  xlim(0,25)+
  facet_grid(category~.)
  