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






Refer to my  \href{https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines}{GitHub Project} to see a detailed description of how we scraped the data and prepared them for our analysis. The 548,629 news headlines dataset can be found \href{https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Data/headlines.Rdata}{here}. In figure \ref{img:headlinesDataset} a description of the variables in the dataset are given and in figure \ref{img:ExampleHeadlines} three sample observations of the dataset are shown. Additionally, we collected full news articles from two categories (HomoEhe and Bügergeld) in specific time frames for our text-scaling analysis of the political ideology of news outlets (see \href{https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines}{GitHub Project} for full description). 

\begin{figure}[H]
	\centering
	\makebox[\textwidth]{\includegraphics[width=\textwidth]{CountHeadlines.JPG}}
	\caption{Count of headlines in each category and for each outlet}
	\label{img:CountHeadlines}
\end{figure}

#### Human Coding
#### Naive guess

### Scraping full article
Additionally, for the **text-scaling analysis** of the political ideology of the news outlets, we used the packages ``rvest`` and ``xml2`` in R to collect **full news articles** from two categories in specific time frames:
- **Homo Ehe** (26.06.2017 - 10.07.2017)
- **Bürgergeld** (01.09.2022 - 08.01.2013)

In the following the function to scrape an article from the outlet **Wirtschaftswoche** is shown:

```markdown

```


### Descriptive Statistics

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
The follwoing command is typed into the R console to install the cocor package in R:
```markdown
install.packages("cocor", lib= "/my/own/R-packages/")
library("cocor")
``` 
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


