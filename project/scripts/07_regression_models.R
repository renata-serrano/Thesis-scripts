library(lme4)
library(dplyr)
library(lmerTest)
# install.packages("sjPlot")
library(sjPlot)
library(insight)
library(lme4)
library(performance) 
library(knitr)  

df_final <- read.csv("processed_director_data.csv") #set your working directory where this file is downloaded

# Prepare variables
df_model <- df_final %>%
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

# Career Gap
# Model 1a: Baseline 
m1a_cg <- lmer(log_career_gap ~ prior_perf_rating_c + (1 | directors), data = df_model)

# Model 1b: Interaction 
m1b_cg <- lmer(log_career_gap ~ prior_perf_rating_c * is_female + (1 | directors), data = df_model)

# Model 1c: Full Model 
m1c_cg <- lmer(log_career_gap ~ prior_perf_rating_c * is_female + 
                 movie_sequence_c + prior_genre_tier + startYear_c + (1 | directors), data = df_model)

#Budget Step
# Model 2a: Baseline 
m2a_bs <- lmer(budget_step_cont_log ~ prior_perf_rating_c + (1 | directors), data = df_model)

# Model 2b: Interaction
m2b_bs <- lmer(budget_step_cont_log ~ prior_perf_rating_c * is_female + (1 | directors), data = df_model)

# Model 2c: Full Model
m2c_bs <- lmer(budget_step_cont_log ~ prior_perf_rating_c * is_female + 
                 movie_sequence_c + prior_genre_tier + startYear_c + (1 | directors), data = df_model)


# Mixed-Effects Model Summary
get_model_summaries <- function(models) {
  summaries <- lapply(models, function(m) {
    perf <- model_performance(m)
    an <- anova(m)
    
    data.frame(
      Marginal_R2 = round(perf$R2_marginal, 3),
      Conditional_R2 = round(perf$R2_conditional, 3),
      AIC = round(perf$AIC, 0),
      F_stat = round(mean(an$`F value`), 2), 
      Sig_F = "< .001" 
    )
  })
  
  do.call(rbind, summaries) %>%
    mutate(Model = c("M1a (Baseline)", "M1b (Moderation)", "M1c (Full)")) %>%
    select(Model, everything())
}

# Output Table
# Career Gap Model Summary
table4_output <- get_model_summaries(list(m1a_cg, m1b_cg, m1c_cg))
kable(table4_output, format = "pipe")

# Budget Step Model Summary
table6_output <- get_model_summaries(list(m2a_bs, m2b_bs, m2c_bs))
kable(table6_output, format = "pipe")



# Career Gap Mixed Effects Model Results
tab_model(m1a_cg, m1b_cg, m1c_cg, 
          dv.labels = c("M1a", "M1b", "M1c"),
          show.ci = FALSE,        
          show.se = FALSE,         
          p.style = "stars",    
          title = "Mixed-Effects Model Summaries (Career Gap)")

# Budget Step Mixed Effects Model Results
tab_model(m2a_bs, m2b_bs, m2c_bs, 
          dv.labels = c("M1a", "M1b", "M1c"),
          show.ci = FALSE,        
          show.se = FALSE,         
          p.style = "stars",      
          title = "Mixed-Effects Model Summaries (Budget Step)")


# Table with exact P values and SE
# Career Gap Table (Appendix H)
tab_model(m1a_cg, m1b_cg, m1c_cg, 
          dv.labels = c("M1a: Baseline", "M1b: Moderation", "M1c: Full Model"),
          show.ci = FALSE,         
          show.se = TRUE,         
          show.p = TRUE,           
          p.style = "numeric", 
          show.stat = FALSE,       
          show.aic = TRUE,         
          title = "Appendix H: Hierarchical Mixed-Effects Results (Career Gap)")

# Budget Step Table (Appendix I)
tab_model(m2a_bs, m2b_bs, m2c_bs, 
          dv.labels = c("M2a: Baseline", "M2b: Moderation", "M2c: Full Model"),
          show.ci = FALSE, 
          show.se = TRUE,
          show.p = TRUE, 
          p.style = "numeric",
          show.stat = FALSE,
          show.aic = TRUE,
          title = "Appendix I: Hierarchical Mixed-Effects Results (Budget Step)")
