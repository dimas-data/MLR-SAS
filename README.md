# Graduate Admission Prediction: Multiple Linear Regression in SAS

A SAS pipeline that models an applicant's **Chance of Admit** from academic and profile factors using multiple linear regression (MLR). It covers data preparation, multicollinearity treatment, model building, residual diagnostics and error measures.

## Results

Final model (n = 1,000):

```
Admit = 0.38656 + 0.02197·UnivRating + 0.02015·LOR + 0.04542·GPA + 0.14965·Research
```

| Metric | Value |
|---|---|
| R² / Adjusted R² | 0.8269 / 0.8262 |
| RMSE / MAE | 0.0396 / 0.0317 |
| MPE / MAPE | -0.30% / 4.43% |

| Assumption | Test | Result |
|---|---|---|
| Independence | Durbin-Watson | D = 2.011 |
| Independence | Ljung-Box | p = 0.6687 (lag 6), p = 0.9715 (lag 12) |
| Normality | Anderson-Darling | A² = 0.1356, p > 0.25 |
| Homoscedasticity | Breusch-Pagan | χ² = 0.87 (df 4), p = 0.9292 |

All four predictors are statistically significant at α = 0.05. Research experience has the largest coefficient.

## Method

1. **Preparation:** import, rename variables, missing-value check, descriptive statistics, correlation analysis, z-score standardisation.
2. **Multicollinearity:** the full seven-predictor model showed a severe condition index (about 85.8, benchmark 30). Predictors were removed iteratively using VIF/COLLIN output and correlations with the response: TOEFL, then GRE, then SOP. The final model uses University Rating, LOR, GPA and Research.
3. **Dimensionality check:** PCA and varimax factor analysis (2 components) on the standardised predictors.
4. **Evaluation:** Durbin-Watson, Anderson-Darling, Breusch-Pagan and Ljung-Box tests; Q-Q, sequence, residual-vs-fitted and ACF plots; observed-vs-fitted plot; RMSE, MAE, MPE, MAPE.
5. **Scoring check:** the saved model is reapplied with `PROC SCORE` to confirm it reproduces the regression predictions.

## Repository Structure

```
.
├── sas/
│   ├── 01_dataprep.sas      # Import, QC, EDA, z-scores
│   ├── 02_buildmodel.sas    # Multicollinearity, PCA/FA, final MLR
│   └── 03_modeleval.sas     # Diagnostics, error measures, scoring check
├── data/
│   ├── raw/                 # Admission_Predict.csv (user-supplied, git-ignored)
│   └── processed/           # grad_clean, grad_z (.sas7bdat), 50-row sample CSV
├── models/                  # regression_fit.sas7bdat, factor_loadings.csv
├── reports/                 # model_diagnostics.pdf, pca_variance_scree.png
├── .gitignore
├── LICENSE
└── README.md
```

## Requirements

- SAS 9.4 (SAS Studio or SAS OnDemand for Academics)
- SAS/STAT (`REG`, `PRINCOMP`, `FACTOR`, `STDIZE`)
- SAS/ETS (`MODEL`, `ARIMA`)

## Usage

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/safaruzzamanshovo/graduate-admission-dataset) and place the CSV in `data/raw/`.
2. Upload the project folder to your SAS environment and set `%let root = <path to project folder>;` at the top of each script in `sas/`. Output folders are created automatically.
3. Run in order: `01_dataprep.sas`, `02_buildmodel.sas`, `03_modeleval.sas`.

## Limitations

- Trained on 1,000 records; not validated on external data or across admission years.
- No holdout or cross-validation split, so reported fit is in-sample.
- Omits essays and interviews; Research is a binary flag that ignores publication depth.
- Linear model, so non-linear and interaction effects may be missed.
- Validation is limited to the diagnostics and scoring check in `03_modeleval.sas`; there is no automated test suite.

## Data Source and License

- **Dataset:** Graduate Admission Dataset (Bangladeshi perspective) by Safaruzzaman Shovo, [Kaggle](https://www.kaggle.com/datasets/safaruzzamanshovo/graduate-admission-dataset). The author notes it was inspired by the UCLA Graduate Dataset.
- **License:** Kaggle lists the license as "Other (specified in description)" with no explicit open-source terms. The raw CSV in `data/raw/` is therefore git-ignored and **not** distributed with this repository; `data/processed/` holds only a 50-row illustrative sample and derived SAS datasets.
- This is a non-commercial, educational project.

## Reference

Idayu, N., Athilia, N. S., Qistina, P. D., Aditya, D., Danial, M., & Arsyaad, M. (2025). Predicting Graduate Admission Chances Using Academic and Profile Factors: An Exploratory Data Analysis. *Enhanced Knowledge in Sciences and Technology*, 5(1), 346-355.