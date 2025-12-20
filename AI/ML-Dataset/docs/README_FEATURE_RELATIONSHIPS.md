
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
```python
corr = df.corr(numeric_only=True)
sns.heatmap(corr, annot=False, cmap='coolwarm')
```

### ✔ Spearman Correlation (non‑linear monotonic)
```python
df.corr(method='spearman', numeric_only=True)
```

### ✔ Scatterplots
```python
sns.scatterplot(data=df, x='sqft', y='price')
```

### ✔ Pairplots
```python
sns.pairplot(df[['sqft','beds','baths','price']])
```

---

# 2️⃣ Categorical–Numeric Relationships

## Techniques
### ✔ Boxplots
```python
sns.boxplot(data=df, x='city', y='price')
```

### ✔ Grouped Statistics
```python
df.groupby('segment')['monthly_fee'].mean()
```

---

# 3️⃣ Categorical–Categorical Relationships

## Techniques
### ✔ Crosstab
```python
pd.crosstab(df['segment'], df['churned'], normalize='index')
```

### ✔ Chi‑Square Test
```python
from scipy.stats import chi2_contingency
chi2_contingency(pd.crosstab(df['segment'], df['churned']))
```

---

# 4️⃣ Feature–Target Relationships

## Regression Targets
### ✔ Correlation with target
```python
df.corr(numeric_only=True)['price'].sort_values()
```

### ✔ SHAP Values
```python
explainer = shap.TreeExplainer(model)
shap.summary_plot(explainer.shap_values(X), X)
```

## Classification Targets
### ✔ Mutual Information
```python
from sklearn.feature_selection import mutual_info_classif
mutual_info_classif(X, y)
```

---

# 5️⃣ Feature Interaction Detection

### ✔ Polynomial/Interaction Features
```python
from sklearn.preprocessing import PolynomialFeatures
poly = PolynomialFeatures(interaction_only=True)
```

### ✔ SHAP Interaction Values
```python
shap_inter = shap.TreeExplainer(model).shap_interaction_values(X)
```

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
