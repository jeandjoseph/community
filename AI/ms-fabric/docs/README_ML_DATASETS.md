
# Sample ML Datasets

This repository contains four synthetic datasets tailored for common machine learning tasks:

1. **regression_housing.csv** — Predict home prices from features.
2. **classification_churn.csv** — Predict customer churn for a SaaS product.
3. **clustering_sales.csv** — Cluster products by sales and profitability profiles.
4. **timeseries_energy.csv** — Forecast energy consumption from hourly time series with weather.

All datasets include realistic quirks (noise, outliers, mild class imbalance, and some missing values) to reflect real-world scenarios.

## 1) Regression: Housing Prices
**Target**: `price` (USD)
**Features**: `city` (categorical), `neighborhood` (categorical), `beds`, `baths`, `sqft`, `built_year`, `lot_acres`, `has_garage`, `has_renovation`
**Notes**: Includes city/neighborhood multipliers, age penalty, Gaussian noise, and outliers; ~3% missing in `sqft`, `lot_acres`, `baths`.

## 2) Classification: Customer Churn
**Target**: `churned` (0/1)
**Features**: `segment`, `region`, `months_on_service`, `monthly_fee`, `num_logins_30d`, `num_tickets_90d`, `add_on_count`, `payment_type`, `auto_renew`, `promo_last_180d`
**Notes**: Rule-based churn probability reflecting engagement, support burden, pricing, and billing type; slight class imbalance.

## 3) Clustering: Product Sales Profiles
**Features**: `price`, `margin_pct`, `monthly_sales_units`, `return_rate` (+ categorical `category`)
**Notes**: Embedded latent clusters (`Bargain`, `Premium`, `Seasonal`) for teaching k-means, GMM, etc. `cluster_label` provided for validation.

## 4) Time Series: Energy Consumption
**Columns**: `timestamp` (hourly), `site_id`, `temperature_F`, `energy_kWh`
**Notes**: Daily/weekly/annual seasonality; temperature elasticity; outages (zeros) and spikes. Useful for ARIMA, Prophet, LSTM, or feature-based regressors.

## Suggested Exercises
- **Regression**: train/test split; feature encoding; evaluate with RMSE/MAE; analyze SHAP/feature importance.
- **Classification**: address class imbalance; ROC-AUC; confusion matrix; threshold tuning; calibration.
- **Clustering**: scale features; elbow method; silhouette score; compare k-means vs. GMM; interpret clusters.
- **Time Series**: resample to daily; decomposition; autocorrelation; baseline naive forecast vs. ML models; handle anomalies.

## License
These datasets are synthetic and free to use for educational purposes.
