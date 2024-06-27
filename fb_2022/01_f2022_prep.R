library(data.table)
library(tidyr)
library(dplyr)

path_f22 <- "fb_2022_adid_text.csv.gz"
# source : data-post-production/01-merge-results/01_merge_preprocessed_results

out_f22 <- "fb_2022/data/fb_22_for_inf.csv"

f22 <- fread(path_f22, encoding = "UTF-8")

f22 <- f22 %>% select(
  ad_id, page_name, disclaimer, ad_creative_body,
  ad_creative_link_caption, ad_creative_link_title,
  ad_creative_link_description, google_asr_text,
  aws_ocr_text_img, aws_ocr_text_vid
)

# Aggregate
f22_2 <- f22 %>%
  pivot_longer(-ad_id) %>%
  filter(value != "") %>%
  mutate(id = paste(ad_id, name, sep = "__")) %>%
  select(-c(ad_id, name))

f22_2 <- aggregate(f22_2$id, by = list(f22_2$value), c)

names(f22_2) <- c("text", "id")


# Save
fb_2022_data <- "fb_2022/data"
dir.create(fb_2022_data)
fwrite(f22_2, out_f22)
