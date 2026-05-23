library(tidyverse)
library(knitr)
library(ggplot2)
library(patchwork)

# Load data
df_model <- read.csv("processed_director_data.csv") #set your working directory where this file is downloaded

# Step 1: Collapse to director level for descriptive statistics
df_director <- df_model %>%
  group_by(directors, gender_label) %>%
  summarise(
    avg_career_gap      = mean(career_gap,           na.rm = TRUE), # avg years between films
    avg_budget_step_raw = mean(budget_step_cont,     na.rm = TRUE), # avg raw dollar change
    avg_budget_step_log = mean(budget_step_cont_log, na.rm = TRUE), # avg log difference (used in models)
    avg_perf            = mean(prior_perf_rating,    na.rm = TRUE), # avg IMDb rating
    first_year          = min(startYear,             na.rm = TRUE), # career entry year
    total_films         = max(movie_sequence,        na.rm = TRUE), # total films in dataset
    initial_tier        = first(prior_genre_tier),                  # starting genre tier (path dependency)
    .groups = "drop"
  )

cat("Director-level observations:\n")
print(table(df_director$gender_label))

# APPENDIX A: Extended descriptives (director level)

appendix_A <- df_director %>%
  group_by(gender_label) %>%
  summarise(
    # Career Gap (years)
    CG_Mean   = round(mean(avg_career_gap,   na.rm = TRUE), 2),
    CG_Median = round(median(avg_career_gap, na.rm = TRUE), 2),
    CG_SD     = round(sd(avg_career_gap,     na.rm = TRUE), 2),
    CG_IQR    = round(IQR(avg_career_gap,    na.rm = TRUE), 2),
    CG_Min    = round(min(avg_career_gap,    na.rm = TRUE), 2),
    CG_Max    = round(max(avg_career_gap,    na.rm = TRUE), 2),
    
    # Budget Step — Raw dollar change
    BS_Raw_Mean   = round(mean(avg_budget_step_raw,   na.rm = TRUE), 0),
    BS_Raw_Median = round(median(avg_budget_step_raw, na.rm = TRUE), 0),
    BS_Raw_SD     = round(sd(avg_budget_step_raw,     na.rm = TRUE), 0),
    BS_Raw_IQR    = round(IQR(avg_budget_step_raw,    na.rm = TRUE), 0),
    BS_Raw_Min    = round(min(avg_budget_step_raw,    na.rm = TRUE), 0),
    BS_Raw_Max    = round(max(avg_budget_step_raw,    na.rm = TRUE), 0),
    
    # Budget Step — Log difference 
    BS_Log_Mean   = round(mean(avg_budget_step_log,   na.rm = TRUE), 2),
    BS_Log_Median = round(median(avg_budget_step_log, na.rm = TRUE), 2),
    BS_Log_SD     = round(sd(avg_budget_step_log,     na.rm = TRUE), 2),
    BS_Log_IQR    = round(IQR(avg_budget_step_log,    na.rm = TRUE), 2),
    BS_Log_Min    = round(min(avg_budget_step_log,    na.rm = TRUE), 2),
    BS_Log_Max    = round(max(avg_budget_step_log,    na.rm = TRUE), 2),
    
    # Prior Film Performance (IMDb rating)
    PFP_Mean   = round(mean(avg_perf,   na.rm = TRUE), 2),
    PFP_Median = round(median(avg_perf, na.rm = TRUE), 2),
    PFP_SD     = round(sd(avg_perf,     na.rm = TRUE), 2),
    PFP_IQR    = round(IQR(avg_perf,    na.rm = TRUE), 2),
    PFP_Min    = round(min(avg_perf,    na.rm = TRUE), 2),
    PFP_Max    = round(max(avg_perf,    na.rm = TRUE), 2),
    
    N = n()
  ) %>%
  t()

cat("APPENDIX A: FULL DESCRIPTIVES (director level, raw + log)")
kable(appendix_A, format = "pipe")


# APPENDIX B: Control Variables (director level)

# Initial genre tier distribution across directors
tier_dist <- df_director %>%
  group_by(gender_label, initial_tier) %>%
  summarise(Count = n(), .groups = "drop") %>%
  group_by(gender_label) %>%
  mutate(Percentage = round((Count / sum(Count)) * 100, 2)) %>%
  ungroup()

# Career entry year and total films
control_stats <- df_director %>%
  group_by(gender_label) %>%
  summarise(
    Entry_Year_Median  = median(first_year,   na.rm = TRUE),
    Entry_Year_Min     = min(first_year,      na.rm = TRUE),
    Entry_Year_Max     = max(first_year,      na.rm = TRUE),
    Films_Mean         = round(mean(total_films,   na.rm = TRUE), 2),
    Films_Median       = round(median(total_films,  na.rm = TRUE),2),
    Films_Max          = round(max(total_films,     na.rm = TRUE),2),
    Total_Directors    = n()
  ) %>%
  t()

cat("APPENDIX B: INITIAL GENRE TIER DISTRIBUTION (director level)")
kable(tier_dist, format = "pipe")

cat("APPENDIX B: CAREER ENTRY YEAR AND TOTAL FILMS (director level)")
kable(control_stats, format = "pipe")

# FIGURES 

# Figure 1: Career Gap vs. Prior Film Performance by Gender
p1 <- ggplot(df_model %>% filter(!is.na(career_gap), !is.na(prior_perf_rating)),
             aes(x     = prior_perf_rating,
                 y     = career_gap + 1,
                 color = gender_label,
                 fill  = gender_label)) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 1.2) +
  scale_y_log10(
    breaks = c(1, 2, 5, 10, 20, 30),
    labels = c("0", "1", "4", "9", "19", "29")
  ) +
  scale_color_manual(values = c("M" = "steelblue", "F" = "tomato"),
                     labels = c("M" = "Male",       "F" = "Female")) +
  scale_fill_manual(values  = c("M" = "steelblue", "F" = "tomato"),
                    labels  = c("M" = "Male",       "F" = "Female")) +
  labs(
    x     = "Prior IMDb Rating",
    y     = "Career Gap (Years, log scale)",
    color = "Gender",
    fill  = "Gender"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

p1
# Figure 2: Budget Step (log) vs. Prior Film Performance by Gender
p2 <- ggplot(df_model %>% filter(!is.na(budget_step_cont_log),
                                 !is.na(prior_perf_rating)),
             aes(x     = prior_perf_rating,
                 y     = budget_step_cont_log,
                 color = gender_label,
                 fill  = gender_label)) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 1.2) +
  scale_color_manual(values = c("M" = "steelblue", "F" = "tomato"),
                     labels = c("M" = "Male",       "F" = "Female")) +
  scale_fill_manual(values  = c("M" = "steelblue", "F" = "tomato"),
                    labels  = c("M" = "Male",       "F" = "Female")) +
  labs(
    x     = "Prior IMDb Rating",
    y     = "Budget Step (Log Difference)",
    color = "Gender",
    fill  = "Gender"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

p2

