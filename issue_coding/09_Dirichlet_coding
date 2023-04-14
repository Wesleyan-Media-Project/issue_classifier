library(dplyr)
library(stringr)
library(data.table)
library(quanteda)

# SpeedReader can be installed like this:
#devtools::install_github("matthewjdenny/SpeedReader")
library(SpeedReader)



# set the path to the folder containing the csv files
folder_path <- "data/ads_for_each_issue"

# Get the list of file names in the folder
file_names <- list.files(folder_path)

if (!dir.exists("data/neg_dirichlet")) {
  dir.create("data/neg_dirichlet")
  
}

if (!dir.exists("data/pos_dirichlet")) {
  dir.create("data/pos_dirichlet")
  
}


# Loop through each file in the folder
for (file_name in file_names) {
  
  
  
  # Read the CSV file
  df <- read.csv(file.path(folder_path, file_name))
  
  tks <- tokens(df$transcript)
  df$combined <- ifelse(df[,4] == 1 | df[,5] == 1, 1, 0)
  
  docvars(tks, "issue") <- df$combined
  
  stopw <- quanteda::stopwords()
  tks <- tokens_remove(tks, stopw)
  
  dtm <- dfm(tks)
  df_vars <- docvars(dtm)
  dtm <- slam::as.simple_triplet_matrix(dtm)
  
  cgt <- contingency_table(df_vars, dtm, variables_to_use = "issue")
  
  fs <- feature_selection(cgt, method = "informed Dirichlet")
  neg<- as.data.frame(fs[1])
  
  pos<- as.data.frame(fs[2])
  
  write.csv(neg, paste("data/neg_dirichlet/", file_name, sep=""))
  
  
  write.csv(pos, paste("data/pos_dirichlet/", file_name, sep=""))
  
}
