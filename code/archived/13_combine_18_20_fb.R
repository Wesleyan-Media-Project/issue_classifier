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
#fb20 <- fb20 %>% rename(alt = ad_id)

# Combine
fb <- bind_rows(fb18, fb20)
#fb <- fb[fb$transcript != '',]
#fb <- fb[fb$transcript != 'NA',]
#fb <- fb[is.na(fb$transcript) == F,]

# Only relevant columns, and in the right order
#p_issues_of_interest <- "data/issues_of_interest.csv"
#issues <- fread(p_issues_of_interest)
#issues <- issues$issue_code[issues$issue_frequency>=100]
#issues <- issues[order(as.integer(str_remove(issues, "ISSUE")))] # sort issue columns
#issues <- issues[!issues %in% c("ISSUE116", "ISSUE209")]
#fb <- fb[,c('alt', 'transcript', issues)]

# NEW SCRIPT FOR 2022 TRAINING
# Only relevant columns, and in the right order
p_issues_of_interest <- "data/issues_of_interest.csv"
issues <- fread(p_issues_of_interest)

# Filter issue codes based on frequency and sort them
issues <- issues$issue_code[issues$issue_frequency >= 100]
issues <- issues[order(as.integer(str_remove(issues, "ISSUE")))]  # Sort issue columns

# Ensure ISSUE209 and ISSUE215 are kept
issues <- issues[!issues %in% c("ISSUE116")]  # Remove ISSUE116
issues <- c("ISSUE209", "ISSUE215", issues)  # Ensure ISSUE209 and ISSUE215 are included

# Subset fb dataframe to include 'alt', 'transcript', and the selected issue columns
fb <- fb[, c('alt', 'transcript', issues)]

fwrite(fb, "data/fb_18_20_for_imputation.csv")
