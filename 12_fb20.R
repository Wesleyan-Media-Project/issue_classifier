library(data.table)
library(dplyr)
library(tidyr)
library(stringr)
library(stringi)

# Clean up unicode
fix_unicode <- function(text) {
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
clean_brackets <- function(x) {
  x <- str_remove(x, '\\[\\"\\"')
  x <- str_remove(x, '\\"\\"\\]')
  x <- str_replace_all(x, '\\"\\"', '\\"')
}

# fbel_w_train.csv is an oputput of the repo ad_goal_classifier
path_fb20 <- "../ad_goal_classifier/data/fbel_w_train.csv"

# Read in as all character
# so it doesn't try to make the few issue variables that contain TRUE/FALSE boolean
fb20 <- fread(path_fb20, colClasses = "character")
fb20 <- fb20 %>%
  select(ad_id, ad_creative_body, asr, c(starts_with("ISSUE"))) %>% # keep relevant cols
  mutate(across(c(ad_creative_body, asr), fix_unicode)) %>%
  mutate(across(c(ad_creative_body, asr), clean_brackets)) %>%
  unite("transcript", c(ad_creative_body, asr), sep = " ", na.rm = T) %>% # combine acb and asr
  mutate(across(-c(ad_id, transcript), function(x) {
    ifelse(x == "False", "", x)
  })) %>% # make quasi-boolean columns conform to the rest
  mutate(across(-c(ad_id, transcript), function(x) {
    ifelse(x == "", 0, 1)
  })) %>% # binarize
  mutate(ad_id = str_replace(ad_id, "x_", "fb20-")) %>%
  rename(alt = ad_id) %>%
  mutate(transcript = str_squish(transcript)) %>%
  filter(transcript != "")

# fwrite(fb20, "data/fbel_prepared_issues.csv")
save(fb20, file = "data/fb_2020.rdata")
