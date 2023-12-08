library(data.table)
library(tidyverse)

path_g22 <- "../google_2022/g2022_adid_01062021_11082022_text_v20231203.csv"

out_g22 <- "google_2022/data/google_22_for_inf.csv"

g22 <- fread(path_g22, encoding = "UTF-8")


# Subset
g22_2 <- g22 %>%
  select(c(ad_id, ad_title, google_asr_text, aws_ocr_video_text, 
           aws_ocr_img_text, advertiser_name, ad_text))

# Aggregate
g22_3 <- g22_2 %>% 
  pivot_longer(-ad_id) %>%
  filter(value != "") %>%
  mutate(id = paste(ad_id, name, sep = "__")) %>%
  select(-c(ad_id, name))

# Add the concatenation step
g22_4 <- g22_3 %>%
  group_by(value) %>%
  summarize(id = paste(id, collapse = " | ")) %>%
  ungroup()

names(g22_4) <- c("text", "id")

# Save
fwrite(g22_4, out_g22)
