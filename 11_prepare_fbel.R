library(data.table)
library(dplyr)
library(tidyr)
library(stringr)
library(stringi)

# Clean up unicode
fix_unicode <- function(text){
  
  Encoding(text) <- "UTF-8"
  # remove trailing backslashes
  # this is necessary, otherwise the unicode unescaping will break some texts
  text <- str_remove(text, "[\\\\]+$")
  # unescaping has to be done twice
  text <- stri_unescape_unicode(text)
  text <- stri_unescape_unicode(text)
  # Convert unicode-based characters
  # this takes care of things like boldface characters, etc.
  text <- stri_trans_nfkd(text)
  
  return(text)
}

# Clean up brackets
clean_brackets <- function(x){
  x <- str_remove(x,  '\\[\\"\\"')
  x <- str_remove(x,  '\\"\\"\\]')
  x <- str_replace_all(x,  '\\"\\"', '\\"')
}

gh <- "E:/gh/"
fb20 <- "ad_goal_classifier/data/fbel_w_train.csv"

# Read in as all character 
# so it doesn't try to make the few issue variables that contain TRUE/FALSE boolean
dffb20 <- fread(paste0(gh, fb20), colClasses = "character")
dffb20 <- dffb20 %>% 
  select(ad_id, ad_creative_body, asr, c(starts_with("ISSUE"))) %>% # keep relevant cols
  mutate(across(c(ad_creative_body, asr), fix_unicode)) %>%
  mutate(across(c(ad_creative_body, asr), clean_brackets)) %>%
  unite("transcript", c(ad_creative_body, asr), sep = " ") %>% # combine acb and asr
  mutate(across(-c(ad_id, transcript), function(x){ifelse(x == "False", "", x)})) %>% # make quasi-boolean columns conform to the rest
  mutate(across(-c(ad_id, transcript), function(x){ifelse(x == "", 0, 1)})) # binarize


fwrite(dffb20, "data/fbel_prepared_issues.csv")
