library(data.table)
library(dplyr)
library(tidyr)
library(stringr)

# Issue coding
load("data/ad_human_codes.RData")
rm(tv_codes)

fb_codes <- fb_codes %>% select(c(alt, starts_with("issue"))) %>%
  select(-c(issue97, issue97_txt, issue_count))
names(fb_codes)[-1] <- toupper(names(fb_codes)[-1])

# Ad text
load("data/all_features_fb.RData")
fb_features$alt <- paste0("fb-", fb_features$snapshot_id)
fb_features <- fb_features[fb_features$alt %in% fb_codes$alt,]
fb_features <- fb_features %>% select(alt, attr_type, text)
fb_features_acb <- fb_features %>% filter(attr_type == "creative_body")
fb_features_acb <- fb_features_acb[!duplicated(fb_features_acb$alt),] # I don't really understand why this can have duplicates - but it can
fb_features_asr <- fb_features %>% filter(attr_type == "video_transcript") %>%
  select(-attr_type) %>%
  rename(asr = text)
fb_features_asr <- fb_features_asr[!duplicated(fb_features_asr$alt),]

fb_features <- full_join(fb_features_acb, fb_features_asr, by = "alt")
fb_features <- fb_features %>% unite("text", text, asr, sep = " ", na.rm = T)
fb_features <- fb_features %>% select(-attr_type)

# Combine issue coding and ad text
fb18 <- left_join(fb_codes, fb_features, by = "alt")
fb18 <- fb18 %>% relocate(text, .after = alt)
fb18 <- fb18 %>% rename(transcript = text)
fb18 <- fb18 %>% mutate(transcript = str_replace_all(transcript, "\n", " "))
fb18 <- fb18 %>% mutate(transcript = str_squish(transcript))
fb18 <- fb18 %>% mutate(alt = str_replace(alt, 'fb-', 'fb18-'))
fb18 <- fb18[is.na(fb18$transcript) == F,]
fb18 <- fb18[fb18$transcript != "",]

save(fb18, file = "data/fb_18_issues_transcripts.rdata")
