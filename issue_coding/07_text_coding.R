library(dplyr)
library(data.table)
library(tidyr)
library(stringr)
library(haven)

# set the path to the folder containing the csv files
folder_path <- "data/ads_where_kantar_wmp_disagree"

# Get the list of file names in the folder
file_names <- list.files(folder_path)

if (!dir.exists("data/text_coding")) {
  dir.create("data/text_coding")
}


# Loop through each file in the folder
for (file_name in file_names) {
  
  # Read the CSV file
  df <- read.csv(file.path(folder_path, file_name))
  
  issue_word <- gsub("issue_","",(gsub(".csv", '', file_name)))
  
  ab1 <- str_detect(df$transcript, coll(issue_word, ignore_case = T))
  
  #ab2 <- str_detect(tv_asr$google_asr_text, coll("planned parenthood", ignore_case = T))
  #ab3 <- str_detect(tv_asr$google_asr_text, coll("reproductive right", ignore_case = T))
  #ab4 <- str_detect(tv_asr$google_asr_text, coll("reproductive freedom", ignore_case = T))
  #ab5 <- str_detect(tv_asr$google_asr_text, coll("pro life", ignore_case = T))

  #ab <- c(ab1|ab2|ab3|ab4|ab5)
  
  #df$text_coding <- as.integer(ab)
  

  
  df$text_coding <- as.integer(ab1)
  
  wmp_col <- colnames(df)[4]
  
  #kantar_col <- colnames(df)[grepl("^issue", colnames(df))]
  
  df$combined <- ifelse(df[,4] == 1 | df$text_coding == 1, 1, 0)  
  
  write.csv(df, paste("data/text_coding/", wmp_col, ".csv", sep=""))
  
  
}
