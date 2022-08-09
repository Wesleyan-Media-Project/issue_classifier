library(data.table)
library(haven)
library(dplyr)
library(stringr)

p_asr18 <- "data/tv_2018_asr.csv"
p_wmp18 <- "data/wmp-2018-all-nobltm-CREATIVE-wcoding_v1.0_120820.dta"

p_asr20_1 <- "data/tv_2020_asr.csv"
p_asr20_2 <- "data/tv_2020_asr_b2.csv"
p_wmp20 <- "../datasets/tv/2020_creative_level_122120.dta"

p_issues_of_interest <- "data/issues_of_interest.csv"

#----
# 2018
# ASR
asr18 <- fread(p_asr18) %>% filter(is.na(stt_confidence) == F) %>% select(-stt_confidence)
names(asr18)[2] <- "transcript"

# Read wmp coding and reduce it only to creative name and issue codings
wmp18 <- read_dta(p_wmp18)
issue_vars <- names(wmp18)[stringr::str_detect(names(wmp18), "issue[0-9]")]
wmp18$filename <- str_remove(wmp18$link, "http://mycmag.kantarmediana.com/KMIcmagvidbin2/") %>% str_remove(".wmv")
wmp18 <- wmp18[,c('filename', issue_vars)]
wmp18 <- wmp18 %>% select(-c(issue97_txt,issue97)) # Kick out 'other' issue
na_row <- apply(wmp18[,-1], 1, function(x){all(is.na(x))})
wmp18 <- wmp18[!na_row,]
names(wmp18)[-1] <- toupper(names(wmp18)[-1])

# Merge WMP coding with ASR
df18 <- left_join(wmp18, asr18, by = "filename")
df18 <- df18[is.na(df18$transcript) == F,]
names(df18)[1] <- "alt"

# Add year
df18$alt <- paste0("tv18-", df18$alt)

#----
# 2020
# ASR
asr20_1 <- fread(p_asr20_1) %>% filter(is.na(stt_confidence) == F) %>% select(-stt_confidence)
asr20_2 <- fread(p_asr20_2) %>% filter(is.na(stt_confidence) == F) %>% select(-stt_confidence)
asr20 <- rbind(asr20_1, asr20_2)

# Read wmp coding and reduce it only to creative name and issue codings
wmp20 <- read_dta(p_wmp20)
issue_vars <- names(wmp20)[stringr::str_detect(names(wmp20), "ISSUE[0-9]")]
wmp20 <- wmp20[,c('alt', issue_vars)]
# Other issue is called ISSUEOTH in 2020, and already not included in the regex
na_row <- apply(wmp20[,-1], 1, function(x){all(is.na(x))})
wmp20 <- wmp20[!na_row,]

# Merge WMP coding with ASR
df20 <- left_join(wmp20, asr20, by = c("alt" = "filename"))
df20 <- df20[is.na(df20$transcript) == F,]

# Add year
df20$alt <- paste0("tv20-", df20$alt)

#----
df <- bind_rows(df18, df20)

issues <- fread(p_issues_of_interest)
issues <- issues$issue_code[issues$issue_frequency>=100]
issues <- issues[order(as.integer(str_remove(issues, "ISSUE")))] # sort issue columns
issues <- issues[!issues %in% c("ISSUE116", "ISSUE209")]

df <- df[,c('alt', 'transcript', issues)]
fwrite(df, "data/issues_asr_18_20.csv")
