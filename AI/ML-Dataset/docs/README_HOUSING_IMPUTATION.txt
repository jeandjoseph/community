
Notepad README — Regression (Housing) NA Imputation
--------------------------------------------------

TARGET: price
MISSING: sqft (numeric), lot_acres (skewed numeric), baths (small discrete numeric)

Recommended steps:
1) sqft: Fill with median to resist outliers.
   pandas: housing_df['sqft'] = housing_df['sqft'].fillna(housing_df['sqft'].median())

2) lot_acres: Fill with median (distribution is skewed/lognormal).
   pandas: housing_df['lot_acres'] = housing_df['lot_acres'].fillna(housing_df['lot_acres'].median())

3) baths: Fill with mode (most frequent value).
   pandas: housing_df['baths'] = housing_df['baths'].fillna(housing_df['baths'].mode()[0])

Optional variants for teaching:
- Group-wise median (by city or neighborhood):
  housing_df['sqft'] = housing_df.groupby('city')['sqft'].transform(lambda x: x.fillna(x.median()))
- KNNImputer using beds, sqft, built_year as features.

Notes:
- Perform imputation AFTER train/test split using training statistics only.
- Document the imputation in your pipeline for reproducibility.
