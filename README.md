# Thesis Replication

### Repository structure

``` text
project/
│
├── data/
│   ├── regression_data_long.csv          
│   ├── regression_data_long_FIXED.csv    
│   └── processed_director_data.csv        
│
├── scripts/
│   ├── 01_filter_us_movies.R              
│   ├── 02_merge_and_clean.R               
│   ├── 03_create_variables.R             
│   ├── 04_budget_step.R                  
│   ├── 05_descriptive_statistics.R       
│   ├── 06_model_assumptions.R            
│   ├── 07_regression_models.R
|   ├── 08_robustness_checks.R            
│   └── 09_gender_changes.R            
│
└── README.md
```

### Source

The raw IMDb files must be downloaded from the IMDb Non-Commercial Datasets: <https://datasets.imdbws.com/>

### Version used

All files were downloaded on April 4th, 2026. IMDb updates these files daily, so results may differ slightly if downloaded on a different date.

### Files required

Download the following five files from the link above:

| File | Description |
|------------------------------------|------------------------------------|
| `title.akas.tsv.gz` | Regional release information (used to filter US titles) |
| `title.basics.tsv.gz` | Film metadata: title, year, genre, runtime, type |
| `title.ratings.tsv.gz` | IMDb user ratings and vote counts |
| `name.basics.tsv.gz` | Director names and identifiers |
| `title.principals.tsv.gz` | Cast and crew credits (used to identify directors) |

*Note*: The data sets are large. The data processing and analyses were conducted on a 64-bit university workstation with a processor of Intel Core Ultra 7 265, 2.40 GHz, and equipped with 16GB of RAM.

## How to run

If you want to reproduce the analysis, run the scripts in the following order:

| Step | Script | Input | Output |
|------------------|------------------|------------------|------------------|
| 1 | `01_filter_us_movies.R` | Raw IMDb files | `hollywood_movies_filtered.csv` |
| 2 | `02_merge_and_clean.R` | `hollywood_movies_filtered.csv` + raw IMDb files | `director_career_data.csv` |
| 3 | `03_create_variables.R` | `director_career_data.csv` | `regression_data_long.csv` |
| 4 | `04_budget_step.R` | `regression_data_long_FIXED.csv` | `processed_director_data.csv` |
| 5 | `05_descriptive_statistics.R` | `processed_director_data.csv` | Descriptive tables and figures |
| 6 | `06_model_assumptions.R` | `processed_director_data.csv` | Assumptions check |
| 7 | `07_regression_models.R` | `processed_director_data.csv` | Regression tables |
| 8 | `08_robustness_checks.R` | `processed_director_data.cs` | Robustness check results |
| 9 | `09_gender_changes.R` | `regression_data_long.csv` + `regression_data_long_FIXED.csv` | Identifies directors who's gender where changed |

`regression_data_long_FIXED.csv` is a manually corrected version of `regression_data_long.csv`. The correction involved reclassifying a small number of directors whose gender had been incorrectly assigned by the automatic babynames lookup. `09_gender_changes.R`obtains the director's name who's gender where changed. 

The final processed dataset is `processed_director_data.csv`

## Key variables in `processed_director_data.csv`

| Variable | Type | Role | Description |
|------------------|------------------|------------------|------------------|
| `directors` | Character | Identifier | IMDb director ID |
| `primaryName` | Character | Identifier | Director's full name |
| `is_female` | Binary (0/1) | Moderator | 1 = female director, 0 = male director |
| `gender_label` | Character | Moderator | "F" or "M" |
| `career_gap` | Numeric | Dependent variable | The time in years between the release of the director’s previous film and the current film |
| `budget_step_cont_log` | Numeric | Dependent variable | Log difference in genre-based budget proxy between consecutive films |
| `budget_step_cont` | Numeric | Descriptive only | Raw dollar difference in genre-based budget proxy between consecutive films |
| `prior_perf_rating` | Numeric | Independent variable | IMDb weighted average rating of the prior film |
| `prior_genre_tier` | Factor (1/2/3) | Control variable | Genre budget tier of the prior film: 1 = low, 2 = mid, 3 = high |
| `movie_sequence` | Numeric | Control variable | Cumulative number of films directed up to each observation |
| `startYear` | Numeric | Control variable | The release year of the director’s film |
| `years_active` | Numeric | Robustness check | Years since the director's first film in the dataset |
| `budgetary_step` | Ordinal (-2 to 2) | Robustness check | Ordinal tier difference between consecutive films |
| `movie_budget_proxy` | Numeric | Intermediate | Highest average genre budget assigned to the current film |
| `genres` | Character | Intermediate | Genre labels as listed in IMDb |
