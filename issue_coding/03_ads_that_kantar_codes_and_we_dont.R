library(data.table)
library(dplyr)
library(tidyr)
library(stringr)
library(haven)

map <- fread("data/compare_2020_cmag_wmp_issue_frequency.csv")
df <- read_dta("../../datasets/tv/2020_creative_level_122120.dta")
alphas <- readxl::read_xlsx("data/2020_TV_Alphas_Final.xlsx")
# ASR
p_asr <- "../data/tv_2020_asr.csv"
p_asr_2 <- "../data/tv_2020_asr_b2.csv"
df_asr1 <- fread(p_asr)
df_asr2 <- fread(p_asr_2)
df_asr <- rbind(df_asr1, df_asr2)
df_asr <- df_asr[is.na(df_asr$stt_confidence) == F,]
df_asr <- df_asr %>% select(-stt_confidence)

df <- left_join(df, df_asr, by = c('alt' = 'filename'))
df <- df[is.na(df$transcript)==F,]
df$issue_social_abortion[is.na(df$issue_social_abortion)] <- 0
df$ISSUE30[is.na(df$ISSUE30)] <- 0
df$only_K_abort <- (df$issue_social_abortion == 1) & (df$ISSUE30 == 0)

# Equivalent issues if WMP is less than .8 of Kantar
for(i in 1:nrow(map)){
  if(map$wmp_prop[1] < .8){
    issue_wmp <- map$issue_wmp[i]
    issue_cmag <- map$issue_cmag[i]
    
    df[issue_cmag][is.na(df[issue_cmag])] <- 0
    df[issue_wmp][is.na(df[issue_wmp])] <- 0
    
    only_K <- (df[issue_cmag] == 1) & (df[issue_wmp] == 1)
    
    df_kantar <- df %>%
      filter(only_K == T) %>%
      select(alt, transcript, link)
    
    df_kantar$alpha <- alphas$alphas[match(issue_wmp, alphas$variable)]
    df_kantar$wmp_ratio <- map$wmp_prop[1]
    
    fwrite(df_kantar, paste0("data/ads_that_kantar_codes_and_we_dont/", issue_cmag, ".csv"))
    
  }
}


#issues <- fread("../data/issues_of_interest.csv")




