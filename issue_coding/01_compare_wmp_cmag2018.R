# Create a dataframe mapping from WMP to Kantar issues
# And calculate the proportion of WMP codings compared to Kantar for each of these issues
# Natalia is working on this
library(data.table)
library(haven)
library(dplyr)
library(tidyr)
library(stringr)

df <- read_dta("data/wmp-2018-all-nobltm-CREATIVE-wcoding_v1.0_120820.dta")

map <- fread("data/mapping_cmag_wmp_issues.csv", header = T)
map <- map[!str_detect(map$`Related WMP var`, '=|\\&'),]
map <- map[map$`Related WMP var` != "",]
map$`Related WMP var` <- tolower(map$`Related WMP var`)

df1 <- df[,na.omit(match(map$wmp_var, names(df)))]
df1 <- apply(df1, 2, sum, na.rm = T)
df1 <- data.frame(issue_cmag = names(df1), freq_cmag = df1)

df2 <- df[,na.omit(match(map$`Related WMP var`, names(df)))]
df2 <- apply(df2, 2, sum, na.rm = T)
df2 <- data.frame(issue_wmp = names(df2), freq_wmp = df2)

map <- select(map, c(wmp_var, `Related WMP var`))
names(map) <- c("issue_cmag", "issue_wmp")
map <- left_join(map, df1, by = "issue_cmag")
map <- left_join(map, df2, by = "issue_wmp")
map$wmp_prop <- map$freq_wmp/map$freq_cmag
map <- map[order(map$wmp_prop),]

map <- map[is.na(map$wmp_prop) == F,]

fwrite(map, "data/compare_2018_cmag_wmp_issue_frequency.csv")

