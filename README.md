# Bad news are good news!? - Quantitative Text Analysis of German News Headlines

## Introduction

The world has faced multiple crises in the last decade, including the migration crisis starting in 2015, the Covid-19 pandemic, and the Ukraine War. Hence, there is a large amount of negative news in terms of its content. Besides, due to the growth in user-tracking technologies throughout the 2010s to measure content reach, it has become a common fact that ``Bad news are good news``, which means that negative headlines reach more clicks/ attention. Therefore, in this project we analyse folowing question: 

                  Have outlets started to drift towards increasing usage of negative sentiment in their headlines to make even good/ neutral news (in terms of its content) sentimentally more negative?

In order to find answers to this question, we applied several quantitative text analysis approaches, which is represented in following figure: 

![Approach.JPG](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Approach.JPG)

***

## Data
### Collecting Data
For our analysis, we collected in total 548,629 ${\color{violet} 548,629 \space German \space news \space headlines}$ over a ``10-year time frame`` (01.01.2013 to 30.04.2023) from ``8 different news outlets`` and ``8 different categories``:
![CountHeadlines.JPG](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Data/CountHeadlines.JPG)

We used [MediaCloud.org](https://search.mediacloud.org/search?) to collect the headlines for the outlets **bild.de** and **Spiegel**. Due to the fact that Mediacloud API has an API request/rate limit, we downloaded the headlines as csv file manually from their webside. Headlines for the other **outlets** are not available on MediaCloud and therefore we scraped them directly from the outlets archive websides using [WebScraper.io](https://webscraper.io/) (Google Chrome Extension). In the following a sample SiteMap for scraping the headlines for the outlet **SZ** in category **Digitalisierung** is shown:

```markdown
{"_id":"DigitalisierungSueddeutsche","startUrl":["https://www.sueddeutsche.de/news/page/[1-97]?search=Digitalisierung&sort=date&all%5B%5D=dep&typ%5B%5D=article&sys%5B%5D=sz&catsz%5B%5D=alles&time=2013-01-01T00%3A00%2F2013-06-19T23%3A59&startDate=01.01.2013&endDate=31.12.2018","https://www.sueddeutsche.de/news/page/[1-97]?search=Digitalisierung&sort=date&all%5B%5D=dep&typ%5B%5D=article&sys%5B%5D=sz&catsz%5B%5D=alles&time=2013-01-01T00%3A00%2F2013-06-19T23%3A59&startDate=01.01.2019&endDate=31.12.2021","https://www.sueddeutsche.de/news/page/[1-25]?search=Digitalisierung&sort=date&all%5B%5D=dep&typ%5B%5D=article&sys%5B%5D=sz&catsz%5B%5D=alles&time=2013-01-01T00%3A00%2F2013-06-19T23%3A59&startDate=01.01.2022&endDate=30.04.2023"],"selectors":[{"id":"Title","parentSelectors":["_root"],"type":"SelectorText","selector":"em.entrylist__title","multiple":true,"regex":""},{"id":"Date","parentSelectors":["_root"],"type":"SelectorText","selector":"time","multiple":true,"regex":""},{"id":"URL","parentSelectors":["_root"],"type":"SelectorLink","selector":"a.entrylist__link","multiple":true}]}
```

The scraped headlines were then exported as csv/ xlsx files and can be found in this [folder](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/tree/main/WebScraping) (they are stored for each outlet in a seperate folder), which also contains R scripts, which we used to bring the headlines into one specific format (see the resulted datasets in the [HeadlineProcessed folder](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/tree/main/WebScraping/HeadlinesProcessed).
> __Note__: we produced with *face validating* an [ErrorList](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/WebScraping/ErrorList.xlsx) in order to remove headlines with NAs and other errors in our collected data.

Finally, we used [PrepareDataForLabeling.R](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/WebScraping/PrepareDataForLabeling.R) to put headlines from all outlets into one single dataframe and a **random sample** of them where human labeled.

#### Human Coding

In order to be able to evaluate our models, we perform **human coding** of about **2% (11,109)** of the headlines. Therefore, we randomly chose 2% of the headlines, and a team of 7 family members coded the headlines into ``Negative`` or ``NotNegative``. We labeled the headlines according to the **maximum coding** (e.g., if 5 coded the headline as ``Negative`` and 2 as ``NotNegative``, we assigned ``Negative``).

We labeled the data according to the **sentiment** rather than the content of the headline. I.e., if a headline contains negative content but is expressed in positive/ neutral language, it is classified as ``NotNegative``. 
> __Note__: Otherwise, it would be very hard to classify headlines because human (political) opinion would be included (e.g. a headline about Covid-19 lockdowns could be classified differently according to the opinion of the coder). 

In the following, a list of **coding guidelines** is given:

![RulesHumanCoding.JPG](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Data/RulesHumanCoding.JPG)

Here some sample codings are shown:

![ExampleHumanCoding.JPG](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Data/ExampleHumanCoding.JPG)

In total, 6546 (~59%) headlines were classified as ``Negative``; 4563 (~41%) were classified as ``NotNegative``.

#### Final Dataset

The final labeled dataset can be found [here](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Data/headlines.Rdata).
The dataset includes following variables:

![HeadlineDataset.JPG](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Data/HeadlineDataset.JPG)

Following 3 sample observations can be seen:
![ExampleHeadlines.JPG](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Data/ExampleHeadlines.JPG)

#### Naive guess

When analyzing performance statistics of our statistical models, we have to get an idea of what a specific value of accuracy means. When we predict a headline as ``Negative`` or ``NotNegative`` without using any model, one reasonable guess would be to use the mean outcome of the data (the naive guess is the most common outcome of the dependent variable = the human coding). 

In our case, roughly 59% of the headlines are ``Negative``, which means that even by making the simplest possible guess, we would get an accuracy of **0.589252**.

### Scraping full article
Additionally, for the **text-scaling analysis** of the political ideology of the news outlets, we used the packages ``rvest`` and ``xml2`` in R to collect **full news articles** from two categories in specific time frames:
- **Homo Ehe** (26.06.2017 - 10.07.2017)
- **Bürgergeld** (01.09.2022 - 08.01.2013)

In the following the function to scrape an article from the outlet **Wirtschaftswoche** is shown:

```markdown
getWirtschaftsWoche <- function(url) {

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
} 
```
The R code to scrape articles for all otlets can be found [here](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/WebScraping/scrapeArticles.R). 
> __Note__: As we do not want to have each article as an *individual* document, we **collapsed** the data to the **outlet level** (i.e. we have one single document for each outlet). The collapsed articles for each outlet are then stored in a dataframe ([articlesHomoEhe.Rdata](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Data/articlesHomoEhe.Rdata), [ariclesBuergergeld.Rdata](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Data/articlesBuergergeld.Rdata)). 

### Descriptive Statistics

In order to get an insight into our collected headlines, we made some **descriptive analyses** (see this [R script](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/DescriptiveStatistics/DescriptiveAnalysis.R)):

![ParetoChart1.JPG](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/DescriptiveStatistics/ParetoChart1.JPG)
![ParetoChart2.JPG](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/DescriptiveStatistics/ParetoChart2.JPG)

We can see, for example, that more than one-third of the headlines in the category **Ukraine** were written by the outlet **FAZ** and only about 3% of them belong to the outlet **bild.de**. 

Additionally, the following figures provide insights on the count of headlines for each category over time. It is, for example, interesting to see that there were almost no headlines related to Coronavirus before 2020. 

![BarPlot1.JPEG](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/DescriptiveStatistics/BarPlot1.JPG)
![Barplot2.JPEG](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/DescriptiveStatistics/Barplot2.JPG)


#### Ntoken

Furthermore, we analyzed the length of the headlines (number of tokens). We can see that the length of the headlines increased in all categories over time and that the headlines of the boulevard **bild.de** were always the longest, while **SZ/ FAZ** produced the shortest headlines. 

![Ntokens.JPG](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/DescriptiveStatistics/NTokens.JPG)


***
## Dictionary Analysis

***
## Classification with Naive Bayes

<img src="https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Classification_NaiveBayes/FeatureSelection.JPG" width="600">
<img src="https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Classification_NaiveBayes/PerformanceScoresNaiveBayes.JPG" width="600">

see full [Classification_NaiveBayesResults.pdf](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Classification_NaiveBayes/ClassificationNaiveBayesResults.pdf)






***
## Word Embeddings

### Compare two Pearson correlations
In order to compare two Pearson correlations the [cocor package in R](https://cran.r-project.org/web/packages/cocor/cocor.pdf) is used. It can be downloaded from the [project's homepage](https://CRAN.R-project.org/package=cocor). 

Subsequent to the above steps, the cocor package can be used to compare two Pearson correlations. It is done for a _dependent overlapping group_ by using following function in R (see the [R script](https://github.com/Nadine-Schmitt/bachelorThesis-nadischm/blob/master/Code/cocor.Rmd)):
```markdown
cocor.dep.groups.overlap(r.jk, r.jh, r.kh, n, alternative = "two.sided", test = "all", alpha = 0.05, conf.level = 0.95, null.value = 0, data.name = NULL, var.labels = NULL, return.htest = FALSE)
```
where following arguments as input are required: 
- **r.jk** is a number specifying the correlation between j and k (this correlation is used for comparison). 
- **r.jh** is a number specifying the correlation between j and h (this correlation is used for comparison).
- **r.kh** is a number specifying the correlation between k and h.
- **n** is an integer defining the size of the group.
- **alternative** is a character string specifying whether the alternative hypothesis is two-sided ("two.sided"; default) or one-sided ("greater" or "less", depending on the direction).
- **test** is a vector of character strings specifying the tests (pearson1898, hotelling1940, hendrickson1970, williams1959, olkin1967, dunn1969, steiger1980, meng1992, hittner2003, or zou2007) to be used. With "all" all tests are applied (default).
- **alpha** is a number defining the alpha level for the hypothesis test. The default value is 0.05.
- **conf.level** is a number defining the level of confidence for the confidence interval (if test meng1992 or zou2007 is used). The default value is 0.95.
- **null.value** is a number defining the hypothesized difference between the two correlations used for testing the null hypothesis. The default value is 0. If the value is other than 0, only the test zou2007 that uses a confidence interval is available.
- **data.name** is a character string giving the name of the data/group.
- **var.labels** is a vector of three character strings specifying the labels for j, k, and h (in this order).
- **return.htest** is a logical indicating whether the result should be returned as a list containing a list of class htest for each test. The default value is FALSE.

Illustrating this, an example of the comparison between the two Pearson scores for Similarity353 for the best models with parameter setting (300,3,5,1,0,16) is shown in the following. As output from the training and evaluation a Pearson score of 0.786 for the raw model and 0.793 for the entity embedding is the result. As also the intercorrelation between the two correlations is needed as input parameter, the correlation between the cosine similarities of the raw model with the cosine similarities of the entity model is computed and given as 0.012. Besides, the Similaritym353 dataset has a size of 203 instances. Therefore following need to be typed in to the R command line in order to compare the two Pearson correlations:
```markdown
cocor.dep.groups.overlap(r.jk= 0.786, r.jh= 0.793, r.kh= 0.012, n=203, alternative="two.sided", alpha=0.05, conf.level=0.95, null.value=0)
````
As output all results of the tests are shown and the null hypothesis is for this example always retained:

![OutputCocot](https://user-images.githubusercontent.com/48829194/62342257-86e2d080-b4e6-11e9-8685-94fb930be027.PNG)

All the calculated results can be seen on the [excel files](https://github.com/Nadine-Schmitt/bachelorThesis-nadischm/tree/master/Results/ResultsCocor).

***
## Topic Modelling - STM

***
## Text Scaling - Wordfish

## Further Limitations
- We collected news headlines from eight different **categories** and 8 different news **outlets**, and it would be interesting to see if we get different results when including other categories (such as sports or finance) and more/ other outlets. 
- We did not include **metadata** such as the gender of the author, and it would be interesting to see if this impacts the headline's sentiment. 
- Besides, as described in our introduction, user-tracking technology to measure content reach grew throughout the 2010s. We, therefore, could expand the analysis to a **broader time frame** (e.g., starting in 2003) and see if we get different results in this earlier period 
>__Note__: that collecting data for this time frame could be very hard.
-  Going deeper into this, we could also perform a **causal inference using our headlines as a treatment**: We could analyze the causal relationship between headlines with negative sentiment (treatment) and the clicks of a headline 
> __Note__: when using text as treatment randomization alone is not sufficient to identify the causal effect of a latent treatment, because there are other features in the headlines (such as content) which can have an impact on the click rate. Therefore one would have to control for observable cofounders).


