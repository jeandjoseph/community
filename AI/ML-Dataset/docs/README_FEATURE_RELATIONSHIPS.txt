
# Feature Relationships — How to Analyze Relationships in Each CSV File

This document explains how to find **relationships between features** using:
- Numeric–numeric analysis
- Categorical–numeric analysis
- Categorical–categorical analysis
- Feature–target relationships
- Interaction effects
- Dataset‑specific recommendations

This guide applies to:
- regression_housing.csv
- classification_churn.csv
- clustering_sales.csv
- timeseries_energy.csv

---

# 1️⃣ Numeric–Numeric Relationships

## Techniques
### ✔ Correlation Matrix
PYTHON CODE START
corr = df.corr(numeric_only=True)
sns.heatmap(corr, annot=False, cmap='coolwarm')
PYTHON CODE END

### ✔ Spearman Correlation (non‑linear monotonic)
PYTHON CODE START
df.corr(method='spearman', numeric_only=True)
PYTHON CODE END

### ✔ Scatterplots
PYTHON CODE START
sns.scatterplot(data=df, x='sqft', y='price')
PYTHON CODE END

### ✔ Pairplots
PYTHON CODE START
sns.pairplot(df[['sqft','beds','baths','price']])
PYTHON CODE END

---

# 2️⃣ Categorical–Numeric Relationships

## Techniques
### ✔ Boxplots
PYTHON CODE START
sns.boxplot(data=df, x='city', y='price')
PYTHON CODE END

### ✔ Grouped Statistics
PYTHON CODE START
df.groupby('segment')['monthly_fee'].mean()
PYTHON CODE END

---

# 3️⃣ Categorical–Categorical Relationships

## Techniques
### ✔ Crosstab
PYTHON CODE START
pd.crosstab(df['segment'], df['churned'], normalize='index')
PYTHON CODE END

### ✔ Chi‑Square Test
PYTHON CODE START
from scipy.stats import chi2_contingency
chi2_contingency(pd.crosstab(df['segment'], df['churned']))
PYTHON CODE END

---

# 4️⃣ Feature–Target Relationships

## Regression Targets
### ✔ Correlation with target
PYTHON CODE START
df.corr(numeric_only=True)['price'].sort_values()
PYTHON CODE END

### ✔ SHAP Values
PYTHON CODE START
explainer = shap.TreeExplainer(model)
shap.summary_plot(explainer.shap_values(X), X)
PYTHON CODE END

## Classification Targets
### ✔ Mutual Information
PYTHON CODE START
from sklearn.feature_selection import mutual_info_classif
mutual_info_classif(X, y)
PYTHON CODE END

---

# 5️⃣ Feature Interaction Detection

### ✔ Polynomial/Interaction Features
PYTHON CODE START
from sklearn.preprocessing import PolynomialFeatures
poly = PolynomialFeatures(interaction_only=True)
PYTHON CODE END

### ✔ SHAP Interaction Values
PYTHON CODE START
shap_inter = shap.TreeExplainer(model).shap_interaction_values(X)
PYTHON CODE END

---

# 6️⃣ Dataset‑Specific Recommendations

## 🏡 Housing Dataset (regression_housing.csv)
Explore:
- sqft ↔ price (strong positive)
- lot_acres ↔ price
- built_year ↔ price (age effect)
- city/neighborhood ↔ price

## 📞 Churn Dataset (classification_churn.csv)
Explore:
- logins_30d ↔ churn
- tickets_90d ↔ churn
- auto_renew ↔ churn
- payment_type ↔ churn
- segment × region interactions

## 🛒 Sales Dataset (clustering_sales.csv)
Explore:
- price ↔ margin_pct
- price ↔ monthly_sales_units
- return_rate ↔ category
- Validate clusters with cluster_label

## ⚡ Time Series Energy Dataset (timeseries_energy.csv)
Explore:
- temperature ↔ energy_kWh
- hour_of_day ↔ energy_kWh
- weekday/weekend patterns
- anomalies/outages vs load

---

This README is ready to use in your ML training materials.
