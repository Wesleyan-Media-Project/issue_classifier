library(data.table)
library(dplyr)
library(tidyr)
library(stringr)

# FB 18
load("data/fb_18_issues_transcripts.rdata")

# FB 20
load("data/fb_2020.rdata")

fb20 <- fread("data/fbel_prepared_issues.csv", encoding = "UTF-8")
fb20 <- fb20 %>% select(-c(ISSUE97, ISSUE97_TXT))
fb20 <- fb20 %>% rename(alt = ad_id)

# Combine
fb <- bind_rows(fb18, fb20)
fb <- fb[fb$transcript != '',]
fb <- fb[fb$transcript != 'NA',]
fb <- fb[is.na(fb$transcript) == F,]

fwrite(fb, "data/fb_18_20_for_imputation.csv")
