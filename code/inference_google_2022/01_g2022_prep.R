library(data.table)
library(tidyverse)

# Output of data-post-production repo, available for download in Wesleyan Media Project Figshare
# change to local path
path_g22 <- "g2022_adid_text.csv.gz"

out_g22 <- "../../data/google_22_for_inf.csv"

g22 <- fread(path_g22, encoding = "UTF-8")

# Subset
g22_2 <- g22 %>%
  select(c(ad_id, ad_title, google_asr_text, aws_ocr_video_text, description,
           aws_ocr_img_text, advertiser_name, ad_text))

# Aggregate
g22_3 <- g22_2 %>% 
  pivot_longer(-ad_id) %>%
  filter(value != "") %>%
  mutate(id = paste(ad_id, name, sep = "__")) %>%
  select(-c(ad_id, name))

g22_4 <- aggregate(g22_3$id, by = list(g22_3$value), c)

names(g22_4) <- c("text", "id")

# Save
fwrite(g22_4, out_g22)
