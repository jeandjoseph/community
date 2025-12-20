
# Normalization & Standardization — How to Apply Them to Each CSV File

This document explains exactly **how to normalize** and **how to standardize** each of the four datasets:
- regression_housing.csv
- classification_churn.csv
- clustering_sales.csv
- timeseries_energy.csv

You can use these instructions directly in ML pipelines.

---

# 1️⃣ regression_housing.csv

## Columns to Standardize
- beds
- baths
- sqft
- built_year
- lot_acres

## Do NOT Scale
- has_garage (binary)
- has_renovation (binary)
- One-hot encoded columns

### Code
```python
numeric_cols = ['beds','baths','sqft','built_year','lot_acres']
binary_cols = ['has_garage','has_renovation']
categorical_cols = ['city','neighborhood']

numeric_pipe = Pipeline([
    ('impute', SimpleImputer(strategy='median')),
    ('scale', StandardScaler())
])

categorical_pipe = Pipeline([
    ('impute', SimpleImputer(strategy='most_frequent')),
    ('ohe', OneHotEncoder(handle_unknown='ignore'))
])
```

---

# 2️⃣ classification_churn.csv

## Columns to Standardize
- months_on_service
- monthly_fee
- num_logins_30d
- num_tickets_90d
- add_on_count

## Do NOT Scale
- auto_renew (binary)
- promo_last_180d (binary)
- OHE columns

### Code
```python
numeric_cols = ['months_on_service','monthly_fee','num_logins_30d','num_tickets_90d','add_on_count']

numeric_pipe = Pipeline([
    ('impute', SimpleImputer(strategy='median')),
    ('scale', StandardScaler())
])
```

---

# 3️⃣ clustering_sales.csv

## Columns to Standardize
- price
- margin_pct
- monthly_sales_units
- return_rate

## Why?
K‑Means and GMM require scaled numeric features.

### Code
```python
numeric_cols = ['price','margin_pct','monthly_sales_units','return_rate']

numeric_pipe = Pipeline([
    ('impute', SimpleImputer(strategy='median')),
    ('scale', StandardScaler())
])
```

---

# 4️⃣ timeseries_energy.csv

## Use StandardScaler for ML Models
- energy_kWh
- temperature_F

## Use MinMaxScaler for Deep Learning (LSTM/GRU)
- energy_kWh
- temperature_F

### Code (ML Version)
```python
numeric_cols = ['temperature_F','energy_kWh']
numeric_pipe = Pipeline([
    ('impute', SimpleImputer(strategy='median')),
    ('scale', StandardScaler())
])
```

### Code (Deep Learning Version)
```python
scaler = MinMaxScaler()
df[['temperature_F','energy_kWh']] = scaler.fit_transform(df[['temperature_F','energy_kWh']])
```

---

# Summary Table
| Dataset | Columns to Scale | Method |
|--------|------------------|--------|
| Housing | sqft, lot_acres, built_year, beds, baths | StandardScaler |
| Churn | All numeric | StandardScaler |
| Sales | All numeric | StandardScaler |
| Energy | temp + energy | Standard (ML), MinMax (DL) |

---

This README is now ready for use in your ML training materials.
