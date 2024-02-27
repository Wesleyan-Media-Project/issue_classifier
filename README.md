# Wesleyan Media Project - Issue_Classifier

Welcome! This repo is a part of the Cross-platform Election Advertising Transparency initiative ([CREATIVE](https://www.creativewmp.com/)) project. CREATIVE is a joint infrastructure project of WMP and privacy-tech-lab at Wesleyan University. CREATIVE provides cross-platform integration and standardization of political ads collected from Google and Facebook. You will also need the repos [datasets](https://github.com/Wesleyan-Media-Project/datasets) to run the script. Some parts of the data in the datasets repo include the TV data. Due to contractual reasons, users must apply directly to receive raw TV data. Visit [here](http://mediaproject.wesleyan.edu/dataaccess) and fill out the online request form to access the TV datasets.

This repo is a part of the Compiled Final Data step.
![A picture of the repo pipeline with this repo highlighted](Creative_Pipeline.png)

## Table of Contents

- [Introduction](#introduction)
- [Objective](#objective)
- [Data](#data)
- [Setup](#setup)

## Introduction

The issue classifier, trained on 2018 and 2020 ads - both TV and Facebook - is designed to be applied to uncoded 2022 ads. It is based on issues as coded by the WMP.

Given that an ad can have multiple issues - or none - there are two basic approaches. One is to use a binary classifier for each issue separately, and the other to use a multilabel classifier which processes all issues together. The binary classifiers tend to have higher precision but lower recall, while the multilabel classifiers tend to have lower precision and higher recall. The multilabel classifiers have higher F1 scores. All measures noted here are only for the 1s of each class as predicting the 0s all the time would yield something like 97-98% accuracy, meaning that it is in a sense easy.

The 2018 WMP coding is missing a few of the issues that were coded in 2020. Furthermore, some of the ads are missing random issues. Due to both of these problems, we do imputation by training binary classifiers for each issue with missing data. The binary classifiers are improved as a result of this this since we want to be cautious and err on the side of more 0s, and we want to use as much data for imputation as we can. In addition, the multilabel model can only use the ads for which no issues are missing, even if those other issues do not matter for imputing for just one issue.

Imputation is done by training models on Facebook data and then imputing the missing Facebook data, and training models on TV data and then imputing the missing TV data. With this in mind, the two types of media are handled separately for imputing.

For the final model, to be used for inference, we use a transformer-based multilabel model, mostly based on the [code](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/C9SAIX) by a recent [Political Analysis article](https://www.cambridge.org/core/journals/political-analysis/article/creating-and-comparing-dictionary-word-embedding-and-transformerbased-models-to-measure-discrete-emotions-in-german-political-text/2DA41C0F09DE1CA600B3DCC647302637#article). That paper is based on German data however, and so here a Distilbert is used instead of the German Electra used there.

## Objective

Each of our repos belongs to one or more of the following categories:

- Data Collection
- Data Processing
- Data Classification
- Compiled Final Data

This repo is part of the Compiled Final Data section.

## Data

The data created by the scripts in this repo is in `csv` format. They are stored in different folders based on different categories. For example, the performance data is stored in `/performance` folder. It contains the performance of the binary classifier and the multilabel classifier which processes all issues together.

To decide which issues to classify, we looked at which issues occurred at least 100 times in the TV data, and excluded two (Issue 116 and 209) that were problematic. So we have 65 issues. The file `data/issues_of_interest.csv` contains the list this is based on.

## Setup

To run the scripts in this repo, you will need to install the following packages:

For the python scripts that perform the classification, you will need to install:

- `scikit-learn`
- `pandas`
- `numpy`
- `joblib`
- `transformers`
- `torch`

For the R scripts you will need to install:

- `data.table`
- `dplyr`
- `tidyr`
- `stringr`
- `haven`
