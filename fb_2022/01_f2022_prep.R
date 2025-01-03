library(data.table)
library(tidyverse)

path_f22 <- "../fb_2022/fb_2022_adid_text.csv.gz"

out_f22 <- "fb_2022/data/fb_22_for_inf.csv"

f22 <- fread(path_f22, encoding = "UTF-8")

f22_1 <- f22 %>% 
  select(c(ad_id, ad_creative_body, google_asr_text, aws_ocr_text_img, 
           aws_ocr_text_vid, page_name, disclaimer, ad_creative_link_caption, 
           ad_creative_link_title, ad_creative_link_description))

# Aggregate
f22_2 <- f22_1 %>% 
  pivot_longer(-ad_id) %>%
  filter(value != "") %>%
  mutate(id = paste(ad_id, name, sep = "__")) %>%
  select(-c(ad_id, name))

f22_2 <- aggregate(f22_2$id, by = list(f22_2$value), c)

names(f22_2) <- c("text", "id")


# Save
fwrite(f22_2, out_f22)
