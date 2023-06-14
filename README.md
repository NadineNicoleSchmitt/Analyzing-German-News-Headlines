# Bad news are good news!? - Quantitative Text Analysis of German News Headlines

## Introduction

In this project I analyse German news headlines.....
                     
In the following figure an overview of the approach is given:

![Approach.JPG](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Approach.JPG)

## Data

### Collecting Data
#### Human Coding
#### Naive guess

### Descriptive Statistics

## Dictionary Analysis


## Classification with Naive Bayes

<img src="https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Classification_NaiveBayes/FeatureSelection.JPG" width="600">
<img src="https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Classification_NaiveBayes/PerformanceScoresNaiveBayes.JPG" width="600">

see full [Classification_NaiveBayesResults.pdf](https://github.com/NadineNicoleSchmitt/Analyzing-German-News-Headlines/blob/main/Classification_NaiveBayes/ClassificationNaiveBayesResults.pdf)





## Compare two Pearson correlations
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


## Topic Modelling - STM

