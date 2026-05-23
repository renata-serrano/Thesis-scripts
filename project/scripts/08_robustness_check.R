#install.packages("ordinal")
library(ordinal) 
library(dplyr)
library(lme4)
library(lmerTest) 
library(dplyr)

df_model <- read.csv("processed_director_data.csv") #set your working directory where this file is downloaded

#Robustness Check 1

df_model <- df_model %>%
  mutate(
    log_career_gap = log(career_gap + 1),
    # alternative experience control (duration-based)
    years_active_c = as.numeric(scale(years_active, scale = FALSE)),
    prior_perf_rating = as.numeric(as.character(prior_perf_rating)),
    startYear = as.numeric(as.character(startYear)),
    prior_perf_rating_c = as.numeric(scale(prior_perf_rating, scale = FALSE)),
    is_female = factor(is_female), 
    startYear_c = as.numeric(scale(startYear, scale = FALSE)),
    movie_sequence_c = as.numeric(scale(movie_sequence, scale = FALSE)),
    prior_genre_tier = factor(prior_genre_tier)
  )

# Run Robustness Check: Replacing volume-experience with duration-experience
m_robust_cg_duration <- lmer(log_career_gap ~ prior_perf_rating_c * is_female + 
                               years_active_c +    # Swapped from movie_sequence_c
                               prior_genre_tier + 
                               startYear_c +       
                               (1 | directors), 
                             data = df_model)

# view Results
summary(m_robust_cg_duration)


#Robustness Check 2

# Prepare the Ordinal Budget Step 
df_model <- df_model %>%
  mutate(
    budget_step_ord = factor(budgetary_step, levels = c(-2, -1, 0, 1, 2), ordered = TRUE),
    log_career_gap = log(career_gap + 1),
    prior_perf_rating = as.numeric(as.character(prior_perf_rating)),
    startYear = as.numeric(as.character(startYear)),
    prior_perf_rating_c = as.numeric(scale(prior_perf_rating, scale = FALSE)),
    is_female = factor(is_female), 
    startYear_c = as.numeric(scale(startYear, scale = FALSE)),
    movie_sequence_c = as.numeric(scale(movie_sequence, scale = FALSE)),
    prior_genre_tier = factor(prior_genre_tier) 
  )

# Robustness Check: Ordered Logit with Random Intercepts
m_robust_ord <- clmm(budget_step_ord ~ prior_perf_rating_c * is_female + 
                       movie_sequence_c + startYear_c + prior_genre_tier + 
                       (1 | directors), data = df_model)

# view Results
summary(m_robust_ord)


