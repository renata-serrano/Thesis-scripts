library(dplyr)

#Load files
orig  <- read.csv("regression_data_long.csv")
fixed <- read.csv2("regression_data_long_FIXED.csv")

orig_gender <- orig %>%
  select(directors, primaryName, is_female, gender_label) %>%
  distinct(directors, .keep_all = TRUE)

fixed_gender <- fixed %>%
  select(directors, primaryName, is_female, gender_label) %>%
  distinct(directors, .keep_all = TRUE)

# Find directors where gender changed 
changes <- orig_gender %>%
  inner_join(fixed_gender, by = "directors", suffix = c("_orig", "_fixed")) %>%
  filter(is_female_orig != is_female_fixed) %>%
  select(
    directors,
    primaryName    = primaryName_orig,
    gender_orig    = gender_label_orig,
    gender_fixed   = gender_label_fixed,
    is_female_orig,
    is_female_fixed
  ) %>%
  arrange(gender_orig, primaryName)

# Results
cat("Total directors with gender changes:", nrow(changes), "\n\n")

cat("Changed from MALE to FEMALE")
print(changes %>% filter(gender_orig == "M"))

cat("Changed from FEMALE to MALE")
print(changes %>% filter(gender_orig == "F"))

# Summary counts 
cat("M -> F:", sum(changes$gender_orig == "M"), "\n")
cat("F -> M:", sum(changes$gender_orig == "F"), "\n")