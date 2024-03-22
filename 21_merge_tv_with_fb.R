library(data.table)
library(dplyr)

# the data required for this processes this script is used for
# requires television data which we are contractually unable to 
# share through Github. However, you can request this data by following the 
# instructions at the following link!
# https://mediaproject.wesleyan.edu/dataaccess/

tv <- fread("data/tv_18_20_imputed.csv", encoding = 'UTF-8')
fb <- fread("data/fb_18_20_imputed.csv", encoding = 'UTF-8')

# Make sure the columns are the same
length(names(fb)[!names(fb) %in% names(tv)]) == 0

# Combine
df <- bind_rows(tv, fb)
fwrite(df, "data/issues_tv_fb_18_20.csv")
