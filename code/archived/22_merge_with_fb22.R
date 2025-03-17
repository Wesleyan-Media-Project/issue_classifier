library(data.table)
library(dplyr)
library(tidyr)
library(stringr)
library(readr)

# Load 18, 20, and TV
path_train <- "data/issues_tv_fb_18_20.csv"
train <- read_csv(path_train)

# Load 22
path_fb22 <- "data/fb_2022.rdata"
load(path_fb22)

# keep only top issues
# Specify the columns to keep
columns_to_keep <- c(
  "ISSUE215", "ISSUE10", "ISSUE30", "ISSUE40", "ISSUE212", "ISSUE12", "ISSUE16", 
  "ISSUE209", "ISSUE18", "ISSUE83", "ISSUE200", "ISSUE54", "ISSUE95", "ISSUE62", 
  "ISSUE55", "ISSUE91", "ISSUE56", "ISSUE53", "ISSUE90", "ISSUE65", "ISSUE45", 
  "ISSUE60", "ISSUE58", "ISSUE22", "ISSUE32", "ISSUE31", "alt", "transcript"
)

# Subset the dataframes
train2 <- train %>% 
  select(all_of(columns_to_keep))

fb22 <- fb22_3 %>% 
  select(all_of(columns_to_keep))

df <- bind_rows(train2, fb22)

fwrite(df, "data/issues_tv_fb_18_20_22.csv")
