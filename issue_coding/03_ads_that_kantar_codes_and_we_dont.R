library(data.table)
library(dplyr)
library(tidyr)
library(stringr)
library(haven)

#Reading files
map <- fread("data/compare_2020_cmag_wmp_issue_frequency.csv")
df <- read_dta("../../datasets/tv/2020_creative_level_122120.dta")
alphas <- readxl::read_xlsx("data/2020_TV_Alphas_Final.xlsx")

map2 <- fread("data/mapping_cmag_wmp_issues.csv", header = T)
#Cleans the data in map by removing the rows that contain the characters "=|&" or are empty in the "Related WMP var" column.
map2 <- map2[!str_detect(map2$`Related WMP var`, '=|\\&'),]
map2 <- map2[map2$`Related WMP var` != "",]


# ASR
p_asr <- "../data/tv_2020_asr.csv"
p_asr_2 <- "../data/tv_2020_asr_b2.csv"
df_asr1 <- fread(p_asr)
df_asr2 <- fread(p_asr_2)

#Merging df_asr1 and df_asr2 into df_asr
df_asr <- rbind(df_asr1, df_asr2)

# Filter data
df_asr <- df_asr[is.na(df_asr$stt_confidence) == F,]
df_asr <- df_asr %>% select(-stt_confidence)

#Joining df and df_asr on "alt" and "filename" columns
df <- left_join(df, df_asr, by = c('alt' = 'filename'))
df <- df[is.na(df$transcript)==F,]


#Replacing missing values with 0 in the "issue_social_abortion" and "ISSUE30" columns
df$issue_social_abortion[is.na(df$issue_social_abortion)] <- 0
df$ISSUE30[is.na(df$ISSUE30)] <- 0

#Creating a new variable or column "only_K_abort" using a logical expression based on the values in "issue_social_abortion" and "ISSUE30" columns
df$only_K_abort <- (df$issue_social_abortion == 1) & (df$ISSUE30 == 0)

df0 <- df[,match(map$wmp_var, names(df))]


#df1 <- df[,c(match(map2$wmp_var, names(df)), which(names(df) %in% c("alt", "transcript", "link")))]
#Check if df vs df_not_kantar is supposed to be on the left or right or both  
#df2 <- df[,c(match(map2$`Related WMP var`, names(df)), which(names(df) %in% c("alt", "transcript", "link")))]

#df_merged <- merge(df1, df2, by = "link", all = TRUE)

if (!dir.exists("data/ads_where_kantar_wmp_disagree")) {
  dir.create("data/ads_where_kantar_wmp_disagree")
}


# Looping through the rows in map, checking if the "wmp_prop" is less than 0.8.
for(i in 1:nrow(map)){
  if(map$wmp_prop[1] < .8){
    
    #Replacing missing values in issue_cmag and issue_wmp with 0
    issue_wmp <- map$issue_wmp[i]
    issue_cmag <- map$issue_cmag[i]
    
    df[issue_cmag][is.na(df[issue_cmag])] <- 0
    df[issue_wmp][is.na(df[issue_wmp])] <- 0
    
    #Creating a new variable "only_K" using a logical expression based on the values in issue_cmag and issue_wmp
    only_K <- (df[issue_cmag] == 1) & (df[issue_wmp] == 1)
    
    #Filtering df for only the rows where only_K is true and selecting columns
    df_kantar <- df %>%
      filter(only_K == T) %>%
      select(alt, transcript, link)
    
    #Creating new variables "alpha" and "wmp_ratio" using values from alphas and map respectively
    
    df_kantar$alpha <- alphas$alphas[match(issue_wmp, alphas$variable)]
    df_kantar$wmp_ratio <- map$wmp_prop[1]
    
    #Writing the filtered and modified df to a file named issue_cmag.csv in the "data/ads_that_kantar_codes_and_we_dont" directory
    
    fwrite(df_kantar, paste0("data/ads_that_kantar_codes_and_we_dont/", issue_cmag, ".csv"))
    
    
    #Filtering df for only the rows where discrep is true and selecting columns
    discrep <- ((df[issue_cmag] == 1) & (df[issue_wmp] == 0)) | ((df[issue_cmag] == 0) & (df[issue_wmp] == 1))
    
    df_discrep <- df %>%
      filter(discrep == T) %>%
      select(alt, transcript, link, issue_wmp, issue_cmag)

    
    fwrite(df_discrep, paste0("data/ads_where_kantar_wmp_disagree/", issue_cmag, ".csv"))
    
    
    
  }
}


#issues <- fread("../data/issues_of_interest.csv")




