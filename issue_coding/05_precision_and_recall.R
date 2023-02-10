library(dplyr)

# set the path to the folder containing the csv files
folder_path <- "data/ads_where_kantar_wmp_disagree"

# Get the list of file names in the folder
file_names <- list.files(folder_path)

# Initialize an empty dataframe to store the results
results_df <- data.frame( kantar_issue= character(0), wmp_issue= character(0),precision_wmp_kantar = numeric(0), recall_wmp_kantar = numeric(0), precision_kantar_wmp = numeric(0), recall_kantar_wmp = numeric(0))

# Loop through each file in the folder
for (file_name in file_names) {
  # Read the CSV file
  df <- read.csv(file.path(folder_path, file_name))
  
  # Get the columns with names that start with "ISSUE" or "issue"
  wmp_col <- colnames(df)[grepl("^ISSUE", colnames(df))]
  kantar_col <- colnames(df)[grepl("^issue", colnames(df))]
  
  # Calculate precision and recall when WMP coding is the prediction and Kantar is the ground truth
  tp <- sum(df[,kantar_col] == df[,wmp_col] & df[,kantar_col] == 1)
  fp <- sum(df[,kantar_col] != df[,wmp_col] & df[,wmp_col] == 1)
  fn <- sum(df[,kantar_col] != df[,wmp_col] & df[,kantar_col] == 0)
  precision_wmp_kantar <- tp / (tp + fp)
  recall_wmp_kantar <- tp / (tp + fn)
  
  # Calculate precision and recall when Kantar coding is the prediction and WMP is the ground truth
  tp <- sum(df[,kantar_col] == df[,wmp_col] & df[,wmp_col] == 1)
  fp <- sum(df[,kantar_col] != df[,wmp_col] & df[,wmp_col] == 1)
  fn <- sum(df[,kantar_col] != df[,wmp_col] & df[,wmp_col] == 0)
  precision_kantar_wmp <- tp / (tp + fp)
  recall_kantar_wmp <- tp / (tp + fn)
  
  # Add a row to the results dataframe with the calculated values
  results_df <- rbind(results_df, data.frame(kantar_issue = names(df)[5], wmp_issue = names(df)[4], precision_wmp_kantar, recall_wmp_kantar, precision_kantar_wmp, recall_kantar_wmp))
}

# Write the results dataframe to a CSV file.
write.csv(results_df, "precision_recall_results.csv")
