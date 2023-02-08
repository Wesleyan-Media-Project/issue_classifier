# Create a dataframe mapping from WMP to Kantar issues
# And calculate the proportion of WMP codings compared to Kantar for each of these issues

library(data.table)
library(haven)
library(dplyr)
library(tidyr)
library(stringr)

df <- read_dta("../../datasets/tv/2020_creative_level_122120.dta")

map <- fread("data/mapping_cmag_wmp_issues.csv", header = T)

#Cleans the data in map by removing the rows that contain the characters "=|&" or are empty in the "Related WMP var" column.
map <- map[!str_detect(map$`Related WMP var`, '=|\\&'),]
map <- map[map$`Related WMP var` != "",]

#Calculates the sum of the frequencies of each issue in the df data frame, as specified by the map$wmp_var column, and stores the results in the data frame df1.
df1 <- df[,match(map$wmp_var, names(df))]
df1 <- apply(df1, 2, sum, na.rm = T)
df1 <- data.frame(issue_cmag = names(df1), freq_cmag = df1)

#Calculates the sum of the frequencies of each issue in the df data frame, as specified by the map$Related WMP varcolumn, and stores the results in the data framedf2`.
df2 <- df[,match(map$`Related WMP var`, names(df))]
df2 <- apply(df2, 2, sum, na.rm = T)
df2 <- data.frame(issue_wmp = names(df2), freq_wmp = df2)

#Modifies the names of the columns in map to be "issue_cmag" and "issue_wmp".
map <- select(map, c(wmp_var, `Related WMP var`))
names(map) <- c("issue_cmag", "issue_wmp")

#Joins the data in map with the data in df1 and df2 on the "issue_cmag" and "issue_wmp" columns, respectively.
map <- left_join(map, df1, by = "issue_cmag")
map <- left_join(map, df2, by = "issue_wmp")

#Adds a new column to map, called wmp_prop, that calculates the ratio of the frequency of each issue in df2 to the frequency of each issue in df1. Then orders
map$wmp_prop <- map$freq_wmp/map$freq_cmag
map <- map[order(map$wmp_prop),]

fwrite(map, "data/compare_2020_cmag_wmp_issue_frequency.csv")

