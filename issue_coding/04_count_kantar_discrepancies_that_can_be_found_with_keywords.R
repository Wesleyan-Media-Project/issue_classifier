library(data.table)
library(dplyr)
library(tidyr)
library(stringr)

setwd("ads_that_kantar_codes_and_we_dont/")

files <- c("issue_healthcare.csv",
           "issue_coronavirus.csv",
           "issue_jobs.csv",
           "issue_taxes.csv",
           "issue_economy.csv",
           "issue_rxdrugs.csv",
           "issue_campaignfinance.csv",
           "issue_ed.csv",
           "issue_immigration.csv",
           "issue_guncontrol.csv",
           "issue_social_abortion.csv")

keywords <- c("healthcare|health care",
              "corona|covid|pandemic",
              "job|employment|unemployed",
              "tax",
              "econom",
              "prescription",
              "campaign finance|campaign money|campaign cash",
              "educat|college|school",
              "immigra",
              "gun control|Second Amendment|second amendment|NRA",
              "abort|pro-life|pro-choice")

df_keyword_hits <- data.frame(issue = str_remove(files, ".csv"),
                              keywords = keywords,
                              number_of_discrepancies = NA,
                              prop_keyword_hits = NA)

for(i in 1:length(files)){
  df <- fread(files[i])
  len_discrepancies <- nrow(df)
  n_keyword_hits <- length(which(str_detect(df$transcript, keywords[i])))
  prop_keyword_hits <- n_keyword_hits/len_discrepancies
  
  df_keyword_hits$number_of_discrepancies[i] <- len_discrepancies
  df_keyword_hits$prop_keyword_hits[i] <- prop_keyword_hits
  
}

fwrite(df_keyword_hits, "../count_kantar_discrepancies_that_can_be_found_with_keywords.csv")

