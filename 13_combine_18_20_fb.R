library(data.table)
library(dplyr)
library(tidyr)
library(stringr)

# the data required for this processes this script is used for
# requires television data which we are contractually unable to
# share through Github. However, you can request this data by following the
# instructions at the following link!
# https://mediaproject.wesleyan.edu/dataaccess/

# FB 18
load("data/fb_18_issues_transcripts.rdata")

# FB 20
load("data/fb_2020.rdata")

# fb20 <- fread("data/fbel_prepared_issues.csv", encoding = "UTF-8")
# fb20 <- fb20 %>% select(-c(ISSUE97, ISSUE97_TXT))
# fb20 <- fb20 %>% rename(alt = ad_id)

# Combine
fb <- bind_rows(fb18, fb20)
# fb <- fb[fb$transcript != '',]
# fb <- fb[fb$transcript != 'NA',]
# fb <- fb[is.na(fb$transcript) == F,]

# Only relevant columns, and in the right order
p_issues_of_interest <- "data/issues_of_interest.csv"
issues <- fread(p_issues_of_interest)
issues <- issues$issue_code[issues$issue_frequency >= 100]
issues <- issues[order(as.integer(str_remove(issues, "ISSUE")))] # sort issue columns
issues <- issues[!issues %in% c("ISSUE116", "ISSUE209")]
fb <- fb[, c("alt", "transcript", issues)]

fwrite(fb, "data/fb_18_20_for_imputation.csv")
