library(dplyr)

# set the path to the folder containing the csv files
folder_path <- "data/text_coding"

# Get the list of file names in the folder
file_names <- list.files(folder_path)

# Initialize an empty dataframe to store the results
results_df <- data.frame( kantar_issue= character(0), wmp_issue= character(0),precision = numeric(0), recall = numeric(0), wmp_total_ones = numeric(0), kantar__total_ones = numeric(0))

# Loop through each file in the folder
for (file_name in file_names) {
  # Read the CSV file
  df <- read.csv(file.path(folder_path, file_name))
  
  # Get the columns with names that start with "ISSUE" or "issue"
  wmp_col <- colnames(df)[grepl("^ISSUE", colnames(df))]
  combined_col <- colnames(df)[grepl("^combined", colnames(df))]
  

  # Calculate precision and recall
  tp <- sum(df[,combined_col] == df[,wmp_col] & df[,wmp_col] == 1)
  fp <- sum(df[,combined_col] != df[,wmp_col] & df[,wmp_col] == 1)
  fn <- sum(df[,combined_col] != df[,wmp_col] & df[,wmp_col] == 0)
  precision <- tp / (tp + fp)
  recall <- tp / (tp + fn)
  
  #Count the number of 1s in the kantar and wmp columns
  
  wmp_total_ones <- sum(df[,wmp_col] == 1)
  text_total_ones <- sum(df[,combined_col] == 1)
  
  
  # Add a row to the results dataframe with the calculated values
  results_df <- rbind(results_df, data.frame(kantar_issue = names(df)[5], wmp_issue = names(df)[4], precision, recall, wmp_total_ones, text_total_ones))
}

# Write the results dataframe to a CSV file
write.csv(results_df, "data/text_coding_precision_recall_results.csv")
