library(vroom)
library(dplyr)

# 1. SET PATH

path <- "C:/Users/YourName/Downloads/" #update this to match your own folder location

# 2. FILTER FOR HOLLYWOOD (US REGION)
raw_akas <- vroom(paste0(path, "title.akas.tsv.gz"), col_select = c(titleId, region), na = "\\N")

hollywood_ids <- raw_akas %>% 
  filter(region == "US") %>% 
  select(tconst = titleId) %>% 
  distinct()

rm(raw_akas) 

# 3. FILTER FOR MOVIES (Added year filter >= 1990)

raw_titles <- vroom(paste0(path, "title.basics.tsv.gz"), na = "\\N")

hollywood_movies <- raw_titles %>% 
  filter(titleType == "movie" & tconst %in% hollywood_ids$tconst) %>% 
  # UPDATED: Filter for 1990 onwards and non-adult 
  filter(isAdult == 0 & !is.na(startYear) & startYear >= 1990)

# 4. SAVE INTERMEDIATE FILE

write.csv(hollywood_movies, "hollywood_movies_filtered.csv", row.names = FALSE)
