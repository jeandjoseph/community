
# Model Explainability — SHAP, PDP, Feature Importance

This README shows how to interpret models for stakeholders.

---

## 1) Global vs Local Interpretability
- **Global**: feature importance, permutation importance, PDP.
- **Local**: SHAP values, LIME.

---

## 2) Techniques
### Permutation Importance
PYTHON CODE START
from sklearn.inspection import permutation_importance
r = permutation_importance(model, X_val, y_val, n_repeats=10)
PYTHON CODE END

### SHAP (Tree Models)
PYTHON CODE START
import shap
explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X_val)
shap.summary_plot(shap_values, X_val)
PYTHON CODE END

### Partial Dependence
PYTHON CODE START
from sklearn.inspection import PartialDependenceDisplay
PartialDependenceDisplay.from_estimator(model, X_val, ['sqft'])
PYTHON CODE END

---

## 3) Communication Tips
- Use domain language (e.g., price per sqft).
- Highlight actionable insights.
- Explain limitations and uncertainty.
