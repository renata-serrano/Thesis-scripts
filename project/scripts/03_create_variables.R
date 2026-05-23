library(dplyr) 
library(tidyr) 
install.packages("babynames")
library(babynames) 

# Gender
gender_lookup <- babynames %>% 
  group_by(name, sex) %>% 
  summarise(total = sum(n), .groups = 'drop') %>% 
  group_by(name) %>% 
  slice_max(total, n = 1) %>% 
  ungroup() %>% 
  select(name, gender_label = sex) %>% 
  mutate(is_female = ifelse(gender_label == "F", 1, 0)) 

# Prior Genre Tier
get_genre_tier <- function(genre_string) { 
  if (is.na(genre_string) || genre_string == "") return(1) 
  genres_split <- trimws(unlist(strsplit(as.character(genre_string), ","))) 
  
  tiers <- sapply(genres_split, function(g) { 
    # Tier 3: High Budget 
    if (g %in% c("Animation", "Adventure", "Sci-Fi", "Action", "Fantasy")) return(3) 
    # Tier 2: Mid Budget
    if (g %in% c("Family", "Comedy", "Thriller", "History", "Crime", "Mystery", "Biography", "Drama", "Romance", "War", "Sport")) return(2) 
    # Tier 1: Low Budget 
    return(1) 
  })
  return(max(tiers)) # takes the highest number 
} 
  
# DATA PROCESSING 
raw_data <- read.csv("director_career_data.csv") #set your working directory where this file is downloaded

regression_data_long <- raw_data %>% 
  distinct(directors, tconst, .keep_all = TRUE) %>% 
  group_by(directors) %>% 
  arrange(startYear, .by_group = TRUE) %>% 
  mutate( 
    movie_order = row_number(), 
    years_active = startYear - min(startYear), 
    genre_tier = sapply(genres, get_genre_tier), 
    prior_genre_tier = lag(genre_tier), 
    prior_perf_rating = lag(averageRating), 
    prior_year = lag(startYear),
    career_gap = startYear - prior_year, 
    budgetary_step = genre_tier - prior_genre_tier 
  ) %>% 
  filter(!is.na(prior_year)) %>% 
  ungroup() %>% 
  mutate(first_name = sub(" .*", "", primaryName)) %>% 
  left_join(gender_lookup, by = c("first_name" = "name")) %>% 
  filter(!is.na(is_female)) %>% 
  select( 
    directors, primaryName, is_female, gender_label, 
    movie_order, years_active, startYear, 
    prior_perf_rating, prior_genre_tier, 
    career_gap, budgetary_step, genre_tier,
    primaryTitle, genres 
  )
    
write.csv(regression_data_long, "regression_data_long.csv", row.names = FALSE) 

