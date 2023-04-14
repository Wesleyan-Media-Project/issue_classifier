library(dplyr)
library(stringr)


# set the path to the folder containing the csv files
folder_path <- "data/dirichlet_pos_text_coding"

# Get the list of file names in the folder
file_names <- list.files(folder_path)

# Initialize an empty dataframe to store the results
results_df <- data.frame( issue= character(0), tc_precision_change = numeric(0), tc_recall_change = numeric(0), kantar_total_ones = numeric(0), text_total_ones = numeric(0),words = character(0))

# Loop through each file in the folder
for (file_name in file_names) {
  
  # Read the CSV file xcwdsx
  df <- read.csv(file.path(folder_path, file_name))
  
  # Get the columns with names that start with "ISSUE" or "issue"
  wmp_col <- colnames(df)[grepl("^ISSUE", colnames(df))]
  kantar_col <- colnames(df)[grepl("^issue", colnames(df))]
  combined_col <- colnames(df)[grepl("^combined", colnames(df))]
  
  
  # Calculate precision and recall
  tp <- sum(df[,combined_col] == df[,kantar_col] & df[,kantar_col] == 1)
  fp <- sum(df[,combined_col] != df[,kantar_col] & df[,kantar_col] == 1)
  fn <- sum(df[,combined_col] != df[,kantar_col] & df[,kantar_col] == 0)
  precision <- tp / (tp + fp)
  recall <- tp / (tp + fn)
  
  #Count the number of 1s in the kantar and wmp columns
  
  #wmp_total_ones1 <- sum(df[,kantar_col] == 1)
  
  kantar_total_ones1 <- sum(df[,kantar_col] == 1)
  
  text_total_ones1 <- sum(df[,combined_col] == 1)
  
  pos_word_df <- read.csv(file.path(folder_path, file_name))
  
  
  pos_word_df <- read.csv(paste("data/pos_dirichlet/issue_",file_name, sep = ""))
  
  
  words1 <- paste((coll(pos_word_df[1,2], ignore_case = T)),", ",coll(pos_word_df[2,2], ignore_case = T), ", ", coll(pos_word_df[3,2], ignore_case = T))
  
  
  # Add a row to the results dataframe with the calculated values

  results_df <- rbind(results_df, data.frame(issue = names(df)[6], tc_precision_change = recall, tc_recall_change = precision, kantar_total_ones = kantar_total_ones1, text_total_ones = text_total_ones1, words = words1))
}
original <- read.csv("data/precision_recall_results.csv")
results_df <- merge(results_df, original[, c(2, 4, 5, 6)], by.x = "issue",by.y ="kantar_issue")





results_df$tc_precision_change <- results_df$tc_precision_change - results_df$precision
results_df$tc_recall_change <- results_df$tc_recall_change - results_df$recall


results_df <- results_df %>%
  select(issue, kantar_total_ones, wmp_total_ones, text_total_ones,precision,recall,tc_precision_change,tc_recall_change, words)

# Write the results dataframe to a CSV file
write.csv(results_df, "data/dirichlet_text_coding_precision_recall_results.csv")
