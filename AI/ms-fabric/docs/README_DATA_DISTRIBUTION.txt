
# Data Distribution Analysis — How to Understand Distributions in Each CSV File

This README explains how to analyze data distributions for the four datasets:
- regression_housing.csv
- classification_churn.csv
- clustering_sales.csv
- timeseries_energy.csv

It includes histogram analysis, KDE density plots, skewness measures, and dataset-specific recommendations.

---

# 1️⃣ Why Data Distribution Matters
- Determines appropriate scaling.
- Helps detect skewness and tail behavior.
- Identifies data quality issues.
- Guides feature transformations (log, Box-Cox, winsorization).

---

# 2️⃣ How to Analyze Distribution

## ✔ Histograms
PYTHON CODE START
plt.hist(df['sqft'], bins=30)
PYTHON CODE END

## ✔ KDE Plots
PYTHON CODE START
sns.kdeplot(df['monthly_fee'])
PYTHON CODE END

## ✔ Skewness & Kurtosis
PYTHON CODE START
df['lot_acres'].skew()
df['lot_acres'].kurt()
PYTHON CODE END

## ✔ Boxplots
PYTHON CODE START
sns.boxplot(x=df['price'])
PYTHON CODE END

---

# 3️⃣ Dataset-Specific Notes

## 🏡 regression_housing.csv
- `lot_acres` → very right-skewed
- `sqft` → multimodal
- `price` → heavy-tailed

### Recommended:
- Log-transform: `lot_acres`
- Winsorize extreme `price`

## 📞 classification_churn.csv
- `num_logins_30d` → Poisson-like
- `num_tickets_90d` → heavy tail

### Recommended:
- StandardScaler
- No outlier removal on engagement metrics

## 🛒 clustering_sales.csv
- `monthly_sales_units` → highly skewed
- `price` clusters by product type

### Recommended:
- StandardScaler for all numeric columns

## ⚡ timeseries_energy.csv
- `temperature_F` → seasonal sinusoidal
- `energy_kWh` → daily/weekly cycles

### Recommended:
- Identify seasonality components
- Use rolling window statistics

---
