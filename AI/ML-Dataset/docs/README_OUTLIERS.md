
# Outlier Detection & Handling — A Practical Guide for All CSV Files

This README explains how to detect and handle outliers in:
- regression_housing.csv
- classification_churn.csv
- clustering_sales.csv
- timeseries_energy.csv

---

# 1️⃣ Outlier Detection Methods

## ✔ Z-Score Method
```python
z = (df['sqft'] - df['sqft'].mean()) / df['sqft'].std()
outliers = df[z.abs() > 3]
```

## ✔ IQR Rule
```python
Q1 = df['price'].quantile(0.25)
Q3 = df['price'].quantile(0.75)
IQR = Q3 - Q1
outliers = df[(df['price'] < Q1 - 1.5*IQR) | (df['price'] > Q3 + 1.5*IQR)]
```

## ✔ Isolation Forest
```python
from sklearn.ensemble import IsolationForest
iso = IsolationForest(contamination=0.02)
df['outlier_flag'] = iso.fit_predict(df[['price','sqft']])
```

---

# 2️⃣ Dataset-Specific Outlier Handling

## 🏡 regression_housing.csv
### Common Outliers:
- Very large `sqft`
- Huge `lot_acres`
- Extreme `price`

### Recommended Handling:
- Winsorize `price`
- Log-transform `lot_acres`

## 📞 classification_churn.csv
### Outliers reflect real behavior:
- Very low logins
- Very high support tickets

### Recommendation:
- DO NOT remove these
- These patterns often indicate churn risk

## 🛒 clustering_sales.csv
### Outliers come from cluster structure:
- Premium products → high price
- Bargain products → high sales

### Recommendation:
- Do NOT remove
- Standardize numeric features

## ⚡ timeseries_energy.csv
### Outliers:
- Outages (zeros)
- Spikes

### Recommendation:
- Flag spikes
- Keep outages

---
