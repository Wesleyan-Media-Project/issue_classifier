library(dplyr)
library(tidyr)
library(stringr)
library(stringi)
library(haven)
library(readr)

# this script requires television data which we are contractually unable to 
# share through Github. However, you can request this data by following the 
# instructions at the following link!
# https://mediaproject.wesleyan.edu/dataaccess/

path_tv22 <- '../data/TV_1.0_noicr_012425.dta'
tv22 <- read_dta(path_tv22)


tv22_2 <- tv22 %>% 
  select(alt, Q65, starts_with("ISSUE")) %>% # Select relevant columns
  filter(!if_all(starts_with("ISSUE"), is.na)) %>% # Drop rows where all ISSUE columns are NA
  mutate(across(-alt, ~ replace_na(., 0))) %>%
  mutate(alt = str_c("tv22-", alt)) %>% # Prepend "tv22-" in alt identifier
  rename(ISSUE209 = Q65)

# Import TV transcripts
path_ad_text <- "../data/asr_tv2022_fedgov_01012021_11082022.csv"
text <- read_csv(path_ad_text)

text <- text %>% 
  rename(transcript = google_asr_text, alt = cmag_vidfile)  %>%
  select(c(alt, transcript)) %>% 
  mutate(alt = str_c("tv22-", alt))

tv22_3 <- tv22_2 %>%
  left_join(text, by = "alt")

write.csv(tv22_3, "../data/tv22_transcripts_issue_codes.csv", row.names = FALSE)

