library(data.table)
library(dplyr)

tv <- fread("data/tv_18_20_imputed.csv", encoding = 'UTF-8')
fb <- fread("data/fb_18_20_imputed.csv", encoding = 'UTF-8')

# Make sure the columns are the same
length(names(fb)[!names(fb) %in% names(tv)]) == 0

# Combine
df <- bind_rows(tv, fb)
fwrite(df, "data/issues_tv_fb_18_20.csv")
