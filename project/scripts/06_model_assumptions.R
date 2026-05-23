
library(tidyverse)
library(lme4)
library(lmerTest)
library(performance) 
library(car)         

df <- read.csv("processed_director_data.csv") #set your working directory where this file is downloaded

# 1. Prepare variables 
df_model <- df %>%
  mutate(
    prior_perf_rating = as.numeric(as.character(prior_perf_rating)),
    startYear = as.numeric(as.character(startYear)),
    log_career_gap = log(career_gap + 1),
    prior_perf_rating_c = as.numeric(scale(prior_perf_rating, scale = FALSE)),
    is_female = factor(is_female),
    startYear_c = as.numeric(scale(startYear, scale = FALSE)),
    movie_sequence_c = as.numeric(scale(movie_sequence, scale = FALSE)),
    prior_genre_tier = factor(prior_genre_tier)
  )

# Define Model 1c (Career Gap)
m1c_cg <- lmer(log_career_gap ~ prior_perf_rating_c * is_female + movie_sequence_c + 
                 prior_genre_tier + startYear_c + (1 | directors), data = df_model)

# Define Model 2c (Budget Step)
m2c_bs <- lmer(budget_step_cont_log ~ prior_perf_rating_c * is_female + movie_sequence_c + 
                 prior_genre_tier + startYear_c + (1 | directors), data = df_model)

# LINEARITY + HOMOSKEDASTICITY 

# Visual check for Career Gap
plot(m1c_cg, 
     main = "Residuals vs Fitted: Career Gap",
     xlab = "Fitted Values(Log-Years)",
     ylab = "Residuals",
     col = "black")

# Visual check for Budget Step
plot(m2c_bs, 
     main = "Residuals vs Fitted: Budget Step",
     xlab = "Fitted Values(Log-Years)",
     ylab = "Residuals",
     col = "black")

# NORMALITY 
# Career Gap 
qqnorm(resid(m1c_cg), 
       main = "Normal Q-Q Plot of Residuals (Career Gap)")
qqline(resid(m1c_cg), col = "red", lwd = 2)

# Budget Step (Model 2c)
qqnorm(resid(m2c_bs), 
       main = "Normal Q-Q Plot of Residuals (Budget Step)")
qqline(resid(m2c_bs), col = "red", lwd = 2)

# Histogram check for normality

res_cg <- resid(m1c_cg) 
hist(res_cg, 
     prob = TRUE,      
     main = "Histogram of Residuals (Career Gap)",
     xlab = "Residuals (Error Term)", 
     col = "gray",  
     border = "white", 
     breaks = 50)

# Add the red normal distribution line
curve(dnorm(x, mean = mean(res_cg), sd = sd(res_cg)), 
      add = TRUE, 
      col = "red", 
      lwd = 2)

# 2. Budget Step Histogram (Model 2c)
res_bs <- resid(m2c_bs) 
hist(res_bs, 
     prob = TRUE,      
     main = "Histogram of Residuals (Budget Step)",
     xlab = "Residuals (Error Term)", 
     col = "gray", 
     border = "white", 
     breaks = 50)

# Add the red normal distribution line
curve(dnorm(x, mean = mean(res_bs), sd = sd(res_bs)), 
      add = TRUE, 
      col = "red", 
      lwd = 2)

# Multicolinearity 
check_collinearity(m1c_cg)
check_collinearity(m2c_bs)


# Independence
# Intraclass Correlation Coefficient (ICC)
icc(m1c_cg)
icc(m2c_bs)

