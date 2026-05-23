library(dplyr)
library(tidyr)

df <- read.csv2("regression_data_long_FIXED.csv") #set your working directory where this file is downloaded


# 1.Lookup table with genres
genre_values <- data.frame(
  genre = c("Animation", "Adventure", "Sci-Fi", "Action", "Fantasy", "Family", "Thriller", 
            "Comedy", "History", "Crime", "Mystery", "Sport", "Biography", "Drama", 
            "Romance", "War", "Music", "Horror", "Musical", "Western", "Documentary", 
            "Film-Noir", "News"),
  avg_budget = c(65012910, 63203425, 57245524, 52848121, 48735280, 47869763, 
                 28614196, 28289377, 26487368, 25171932, 24254080, 24059928, 
                 23846723, 22449169, 20969162, 20653776, 16326453, 16298415, 
                 16117296, 14616900, 4388240, 1184270, 350000)
)

# 2. Process main data
df_cont <- df %>%
  separate_rows(genres, sep = ",") %>%
  left_join(genre_values, by = c("genres" = "genre")) %>%
  group_by(directors, primaryTitle, startYear) %>%
  # Assign highest average budget among genres
  mutate(movie_budget_proxy = max(avg_budget, na.rm = TRUE)) %>%
  mutate(movie_budget_proxy = ifelse(is.infinite(movie_budget_proxy), NA, movie_budget_proxy)) %>%
  distinct(directors, primaryTitle, startYear, .keep_all = TRUE) %>%
  ungroup()

# 3. Calculate steps and Log-transform while excluding missing data
df_final <- df_cont %>%
  filter(!is.na(movie_budget_proxy)) %>%
  group_by(directors) %>%
  arrange(startYear) %>%
  mutate(
    budget_step_cont = movie_budget_proxy - lag(movie_budget_proxy),
    movie_sequence = row_number() - 1 
  ) %>%
  mutate(
    budget_step_cont_log = ifelse(!is.na(lag(movie_budget_proxy)), 
                                  log(movie_budget_proxy) - log(lag(movie_budget_proxy)), 
                                  NA)
  ) %>%
  ungroup()

df_final$budget_step_cont_log <- log(df_final$movie_budget_proxy) - log(lag(df_final$movie_budget_proxy))

write.csv(df_final, "processed_director_data.csv", row.names = FALSE)
