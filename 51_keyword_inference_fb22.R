library(data.table)
library(dplyr)
library(tidyr)
library(stringr)
library(haven)

# TV
cmag <- read_dta("../datasets/tv/2020_creative_level_122120.dta")
tv_asr <- read.csv("../datasets/tv/tv_2020_fed.csv")

cmag <- cmag %>% select(alt, issue_social_abortion, issue_social_birthcontrol, issue_economy)

tv_asr <- merge(tv_asr, cmag, by = "alt")

ab1 <- str_detect(tv_asr$google_asr_text, coll("abort", ignore_case = T))
ab2 <- str_detect(tv_asr$google_asr_text, coll("planned parenthood", ignore_case = T))
ab3 <- str_detect(tv_asr$google_asr_text, coll("reproductive right", ignore_case = T))
ab4 <- str_detect(tv_asr$google_asr_text, coll("reproductive freedom", ignore_case = T))
ab5 <- str_detect(tv_asr$google_asr_text, coll("pro life", ignore_case = T))
ab6 <- str_detect(tv_asr$google_asr_text, coll("pro-life", ignore_case = T))
ab7 <- str_detect(tv_asr$google_asr_text, coll("pro choice", ignore_case = T))
ab8 <- str_detect(tv_asr$google_asr_text, coll("pro-choice", ignore_case = T))
ab9 <- str_detect(tv_asr$google_asr_text, coll("rape or incest", ignore_case = T))
ab10 <- str_detect(tv_asr$google_asr_text, coll("rape and incest", ignore_case = T))
ab11 <- str_detect(tv_asr$google_asr_text, coll("woman's right to choose", ignore_case = T))
ab12 <- str_detect(tv_asr$google_asr_text, coll("women's right to choose", ignore_case = T))
ab13 <- str_detect(tv_asr$google_asr_text, coll("right to life", ignore_case = T))
ab14 <- str_detect(tv_asr$google_asr_text, coll("right to live", ignore_case = T))
ab15 <- str_detect(tv_asr$google_asr_text, regex("kill babies", ignore_case = T))
ab16 <- str_detect(tv_asr$google_asr_text, regex("roe v.+ wade", ignore_case = T))
ab17 <- str_detect(tv_asr$google_asr_text, coll("reproductive health", ignore_case = T))
ab18 <- str_detect(tv_asr$google_asr_text, coll("right to choose", ignore_case = T))

ab <- c(ab1|ab2|ab3|ab4|ab5|ab6|ab7|ab8|ab9|ab10|ab11|ab12|ab13|ab14|ab15|ab16|ab17|ab18)

tv_asr$predict_abortion_keyword <- as.integer(ab)

ab_wrong = tv_asr[tv_asr$issue_social_abortion != tv_asr$predict_abortion_keyword,]

abortion_df <- read.csv("issue_coding/data/ads_where_kantar_wmp_disagree/issue_social_abortion.csv")

tv_asr <- merge(tv_asr, abortion_df, by = "alt")


wmp_col <- colnames(tv_asr)[grepl("^ISSUE30", colnames(tv_asr))]
pred_col <- 'predict_abortion_keyword'

# Calculate precision and recall when WMP coding is the prediction and Kantar is the ground truth
tp <- sum(tv_asr[,pred_col] == tv_asr[,wmp_col] & tv_asr[,pred_col] == 1)
fp <- sum(tv_asr[,pred_col] != tv_asr[,wmp_col] & tv_asr[,wmp_col] == 1)
fn <- sum(tv_asr[,pred_col] != tv_asr[,wmp_col] & tv_asr[,pred_col] == 0)
precision_wmp_pred <- tp / (tp + fp)
recall_wmp_pred <- tp / (tp + fn)

# Calculate precision and recall when Kantar coding is the prediction and WMP is the ground truth
tp <- sum(tv_asr[,pred_col] == tv_asr[,wmp_col] & tv_asr[,wmp_col] == 1)
fp <- sum(tv_asr[,pred_col] != tv_asr[,wmp_col] & tv_asr[,wmp_col] == 1)
fn <- sum(tv_asr[,pred_col] != tv_asr[,wmp_col] & tv_asr[,wmp_col] == 0)
precision_pred_wmp <- tp / (tp + fp)
recall_pred_wmp <- tp / (tp + fn)

# Add a row to the results dataframe with the calculated values
abortion_results_df <- data.frame(
  precision_wmp_pred,
  recall_wmp_pred,
  precision_pred_wmp,
  recall_pred_wmp
)

fwrite(abortion_results_df, paste0("issue_coding/data/abortion_pred.csv"))











inf1 <- str_detect(tv_asr$google_asr_text, coll("inflation", ignore_case = T))
inf2 <- str_detect(tv_asr$google_asr_text, coll("bidenflation", ignore_case = T))
inf3 <- str_detect(tv_asr$google_asr_text, coll("groceries", ignore_case = T))
inf4 <- str_detect(tv_asr$google_asr_text, coll("grocery", ignore_case = T))
inf5 <- str_detect(tv_asr$google_asr_text, coll("air conditioning", ignore_case = T))
inf6 <- str_detect(tv_asr$google_asr_text, coll("at the pump", ignore_case = T))

infl <- c(inf1|inf2|inf3|inf4|inf6|inf5)
tv_asr$predict_inflation_keyword <- as.integer(infl)

inf_wrong = tv_asr[tv_asr$issue_inflation != tv_asr$predict_inflation_keyword,]


inflation_df <- read.csv("issue_coding/data/ads_where_kantar_wmp_disagree/issue_economy.csv")

tv_asr <- merge(tv_asr, inflation_df, by = "alt")


wmp_col <- colnames(tv_asr)[grepl("^ISSUE22", colnames(tv_asr))]
pred_col <- 'predict_inflation_keyword'

# Calculate precision and recall when WMP coding is the prediction and Kantar is the ground truth
tp <- sum(tv_asr[,pred_col] == tv_asr[,wmp_col] & tv_asr[,pred_col] == 1)
fp <- sum(tv_asr[,pred_col] != tv_asr[,wmp_col] & tv_asr[,wmp_col] == 1)
fn <- sum(tv_asr[,pred_col] != tv_asr[,wmp_col] & tv_asr[,pred_col] == 0)
precision_wmp_pred <- tp / (tp + fp)
recall_wmp_pred <- tp / (tp + fn)

# Calculate precision and recall when Kantar coding is the prediction and WMP is the ground truth
tp <- sum(tv_asr[,pred_col] == tv_asr[,wmp_col] & tv_asr[,wmp_col] == 1)
fp <- sum(tv_asr[,pred_col] != tv_asr[,wmp_col] & tv_asr[,wmp_col] == 1)
fn <- sum(tv_asr[,pred_col] != tv_asr[,wmp_col] & tv_asr[,wmp_col] == 0)
precision_pred_wmp <- tp / (tp + fp)
recall_pred_wmp <- tp / (tp + fn)

# Add a row to the results dataframe with the calculated values
inflation_results_df <- data.frame(
  precision_wmp_pred,
  recall_wmp_pred,
  precision_pred_wmp,
  recall_pred_wmp
)

fwrite(inflation_results_df, paste0("issue_coding/data/inflation_pred.csv"))




#I am not sure about what the rest of the code is for


# gas alone not worth it
# grocery/groceries is worth it -- reduces 45 errors that would otherwise happen
# at the pump worth it
# gas prices not worth it
# prices not worth it

# there are 115 ads that contain 'inflation' and yet aren't coded as such by kantar (and my spot-checking shows that they are indeed about inflation)

fwrite(tv_asr, "data/tv_asr_keyword_clf.csv")

#----

df <- fread("data/inference/fb2022.csv.gz", encoding = "UTF-8")

abort <- str_detect(df$transcript, "abort")
length(which(abort))
inflation <- str_detect(df$transcript, "inflation")
length(which(inflation))
df$transcript[inflation]

"bidenflation"
"bideninflation"




