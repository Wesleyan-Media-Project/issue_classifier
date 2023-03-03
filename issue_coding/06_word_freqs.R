library(dplyr)

# set the path to the folder containing the csv files
folder_path <- "data/ads_where_kantar_wmp_disagree"

# Get the list of file names in the folder
file_names <- list.files(folder_path)

if (!dir.exists("data/word_freq")) {
  dir.create("data/word_freq")
  
}

# Loop through each file in the folder
for (file_name in file_names) {
  
  dictionary <- data.frame(word = character(), frequency = numeric(), stringsAsFactors = FALSE)
  
  # Read the CSV file
  df <- read.csv(file.path(folder_path, file_name))
  
  # Get the columns with names that start with "ISSUE" or "issue"
  wmp_col <- colnames(df)[4]
  kantar_col <- colnames(df)[grepl("^issue", colnames(df))]
  
    
  
  
  # Calculate precision and recall
  for (i in 1:nrow(df)) {
    if (df[i, 4] == 1) {
      words <- tolower(strsplit(df$transcript[i], " ")[[1]])
      # Count the frequency of each word
      word_freq <- table(words)
      # Append the word frequencies to the dictionary
      dictionary <- rbind(dictionary, data.frame(word = names(word_freq), frequency = as.numeric(word_freq), stringsAsFactors = FALSE))
      
      # Sum the frequencies of each word in the dictionary
    }
  if (nrow(dictionary) > 0) {
    dictionary <- aggregate(frequency ~ word, data = dictionary, sum)
    
    dictionary <- dictionary[order(-dictionary$frequency),]
    
      # do something if "df" has at least one row
  }
    
  # Add a row to the results dataframe with the calculated values
  

  write.csv(dictionary, paste("data/word_freq/", file_name, ".csv", sep=""))
  
  
  }
}


