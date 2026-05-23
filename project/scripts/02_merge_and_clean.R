library(dplyr) 
library(tidyr) 
library(vroom) 

path <- "C:/Users/YourName/Downloads/" #update this to match your own folder location


h_movies <- read.csv("hollywood_movies_filtered.csv") 
raw_ratings <- vroom(paste0(path, "title.ratings.tsv.gz"), na = "\\N") 

# 2. LOAD NAMES 
raw_names <- vroom(paste0(path, "name.basics.tsv.gz"), col_select = c(nconst, primaryName), na = "\\N") 

# 3. FILTER FOR DIRECTORS 
raw_principals <- vroom(paste0(path, "title.principals.tsv.gz"), col_select = c(tconst, nconst, category), na = "\\N") 

h_directors <- raw_principals %>% 
  filter(category == "director" & tconst %in% h_movies$tconst) %>% 
  select(tconst, directors = nconst) 

# 4. JOIN EVERYTHING 
final_dataset <- h_directors %>% 
  inner_join(raw_names, by = c("directors" = "nconst")) %>% 
  inner_join(h_movies, by = "tconst") %>% 
  inner_join(raw_ratings, by = "tconst") %>% 
  # Minimum 1000 votes to remove independent films 
  filter(numVotes >= 1000) %>%
  filter(runtimeMinutes >=80)


write.csv(final_dataset, "director_career_data.csv", row.names = FALSE)   
