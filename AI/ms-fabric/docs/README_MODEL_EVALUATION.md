
# Model Evaluation — Metrics, Curves, and Diagnostics

This README provides a consistent evaluation framework per task.

---

## 1) Regression
- Metrics: MAE, RMSE, R², MAPE
- Diagnostics: residual plots, error distribution, heteroscedasticity checks.

```python
errors = y_val - y_pred
plt.hist(errors, bins=30)
```

---

## 2) Classification
- Metrics: ROC-AUC, PR-AUC, F1, precision/recall.
- Curves: ROC curve, Precision-Recall curve.
- Confusion matrix analysis and threshold tuning.

```python
from sklearn.metrics import roc_auc_score, RocCurveDisplay
RocCurveDisplay.from_estimator(model, X_val, y_val)
```

---

## 3) Clustering
- Metrics: silhouette, Davies–Bouldin.
- Stability: compare runs across seeds.

---

## 4) Time Series
- Metrics: MAE/RMSE/sMAPE/MASE.
- Backtesting with rolling windows.

```python
from sklearn.model_selection import TimeSeriesSplit
```

---

## 5) Reporting
- Keep a standardized evaluation report.
- Include confidence intervals via bootstrapping when feasible.
