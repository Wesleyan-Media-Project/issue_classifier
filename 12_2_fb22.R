library(dplyr)
library(tidyr)
library(stringr)
library(stringi)
library(haven)
library(readr)

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

path_fb22 <- "../datasets/facebook/FBEL_092924.dta"

fb22 <- read_dta(path_fb22)
fb22$ad_id <- fb22$adid

fb22_2 <- fb22 %>%
  select(ad_id, starts_with("ISSUE")) %>% # Select relevant columns
  filter(!if_all(starts_with("ISSUE"), is.na)) %>% # Drop rows where all ISSUE columns are NA
  mutate(across(-c(ad_id), ~ ifelse(is.na(.), "", .))) %>% # Replace NA with empty string
  mutate(across(-c(ad_id), ~ ifelse(. == "False", "", .))) %>% # Replace "False" with empty string
  mutate(across(-c(ad_id), ~ ifelse(. == "" | is.na(.), 0, as.numeric(.)))) %>% # Binarize: empty or NA to 0, keep existing 0/1
  mutate(ad_id = str_replace(ad_id, "x_", "fb22-")) # Replace "x_" in ad_id

#Add in the text
path_ad_text <- "../data_post_production/fb_2022_adid_text.csv.gz"
text <- read_csv(path_ad_text)

text$aws_ocr_text <- ifelse(is.na(text$aws_ocr_text_img) & 
                              is.na(text$aws_ocr_text_vid), NA,
                            paste(coalesce(text$aws_ocr_text_img, ""), 
                                  coalesce(text$aws_ocr_text_vid, ""),
                                  sep = " "))

text <- text %>% rename(ocr = aws_ocr_text)
text <- text %>% rename(asr = google_asr_text)
text <- text %>% select(-c(ad_snapshot_url, ad_creative_bodies, ad_creative_bodies,
                           ad_creative_link_titles, ad_creative_link_descriptions,
                           aws_ocr_text_img, aws_ocr_text_vid, aws_status_img,
                           aws_status_vid, product_brand, product_name, 
                           product_description, ad_creative_link_captions,
                           google_asr_status))

# Combine text columns into one column 'transcript'
text <- text %>%
  mutate(ad_id = str_replace(ad_id, "x_", "fb22-")) %>%
  mutate(transcript = paste(page_name, disclaimer, ad_creative_body,
                            ad_creative_link_caption, ad_creative_link_title,
                            ad_creative_link_description, asr, ocr, sep = " ")) %>%
  mutate(transcript = str_squish(transcript)) %>%
  select(ad_id, transcript) # Keep only ad_id and the new transcript column

# Add the transcript column to fb22_2 by joining on ad_id
fb22_3 <- fb22_2 %>%
  left_join(text, by = "ad_id") %>%
  rename(alt = ad_id)

save(fb22_3, file = "data/fb_2022.rdata")
