
# Data Splitting & Leakage Prevention — Practical Guide

This README documents **how to split data** correctly and **prevent leakage** across different ML tasks, including time series.

---

## 1) Why Splitting Matters
Proper splits ensure unbiased evaluation. All preprocessing (imputation, scaling, OHE, outlier handling) must be **fit on training only** and **applied** to validation/test.

---

## 2) Split Types
- **Random holdout**: Typical for regression/ML when i.i.d.
- **Stratified split**: Maintain class proportions (e.g., churn classification).
- **Time-based split**: Chronological train → validation → test (never shuffle).

---

## 3) Recommended Strategies per Dataset
- **regression_housing.csv**: Random split (e.g., 80/20), consider k-fold CV.
- **classification_churn.csv**: Stratified train/test split, stratified k-fold CV.
- **clustering_sales.csv**: No labels; use train/test for pipeline stability or evaluate clustering stability by resampling.
- **timeseries_energy.csv**: Time-based split; e.g., first 9 months train, next 2 months validation, last 1 month test.

---

## 4) Leakage Prevention Checklist
- Fit imputer/scaler/encoder **only** on training.
- Use `Pipeline` + `ColumnTransformer`.
- For target encoding, use cross-fold strategy to avoid leakage.
- For time series, build features from **past** only (lags/rollings) and avoid using future timestamps.

---

## 5) Code Snippets
### Stratified Split (Churn)
PYTHON CODE START
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2,
                                                    stratify=y, random_state=42)
PYTHON CODE END

### Time-Based Split (Energy)
PYTHON CODE START
# Assume df sorted by timestamp
test_df = df.tail(24*30)  # last 30 days
tmp = df.iloc[:-24*30]
val_df = tmp.tail(24*60)   # prior 60 days
train_df = tmp.iloc[:-24*60]
PYTHON CODE END

---

## 6) Cross-Validation
- **K-Fold / StratifiedKFold** for i.i.d. data.
- **TimeSeriesSplit** for temporal data.
PYTHON CODE START
from sklearn.model_selection import TimeSeriesSplit
cv = TimeSeriesSplit(n_splits=5)
PYTHON CODE END
