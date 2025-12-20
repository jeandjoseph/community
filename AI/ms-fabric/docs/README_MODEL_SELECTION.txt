
# Model Selection & Benchmarking — Practical Guide

This README explains how to pick baseline and advanced models, compare performance, and select the best.

---

## 1) Baselines
Before complex models, use:
- **DummyRegressor** (mean/median predictor)
- **DummyClassifier** (most frequent or stratified)

PYTHON CODE START
from sklearn.dummy import DummyRegressor, DummyClassifier
PYTHON CODE END

---

## 2) Candidates by Task
- **Regression (Housing)**: Linear/Ridge/Lasso, RandomForest, XGBoost/LightGBM.
- **Classification (Churn)**: Logistic Regression, RandomForest, XGBoost/LightGBM, calibrated classifiers.
- **Clustering (Sales)**: K-Means, GMM, DBSCAN (when density-based).
- **Time Series (Energy)**: Feature-based regressors (GBM/RF), or ARIMA/Prophet/LSTM.

---

## 3) Evaluation Protocol
- Use consistent train/validation/test splits.
- Tune hyperparameters with CV on training set only.
- Report metrics with confidence intervals when possible.

---

## 4) Metric Selection
- **Regression**: MAE, RMSE, R², MAPE (use carefully with zeros).
- **Classification**: ROC-AUC, PR-AUC, F1, precision/recall, calibration error.
- **Clustering**: Silhouette, Davies–Bouldin, Calinski–Harabasz.
- **Time Series**: RMSE, MAE, sMAPE, MASE.

---

## 5) Model Comparison Template
PYTHON CODE START
results = []
for name, model in models:
    model.fit(X_train, y_train)
    y_pred = model.predict(X_val)
    results.append((name, metric(y_val, y_pred)))
PYTHON CODE END

---

## 6) Practical Tips
- Start simple; avoid overfitting with high-capacity models.
- Use pipelines for reproducibility.
- Log experiments (e.g., MLflow).
