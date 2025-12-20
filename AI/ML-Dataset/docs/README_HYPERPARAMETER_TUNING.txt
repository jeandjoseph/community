
# Hyperparameter Tuning — Grid, Random, and Bayesian

This README covers techniques to optimize model hyperparameters safely and efficiently.

---

## 1) Methods
- **GridSearchCV**: Exhaustive search over small grids.
- **RandomizedSearchCV**: Efficient over large spaces; sample distributions.
- **Bayesian Optimization**: Optuna or scikit-optimize for smarter search.

---

## 2) Best Practices
- Split train/validation/test **before** tuning.
- Use CV folds on the training set.
- For time series, use `TimeSeriesSplit`.
- Monitor overfitting; prefer early stopping (boosted trees/NN).

---

## 3) Examples
PYTHON CODE START
from sklearn.model_selection import GridSearchCV
param_grid = { 'alpha': [0.1, 1.0, 10.0] }
search = GridSearchCV(Ridge(), param_grid, cv=5, scoring='neg_root_mean_squared_error')
search.fit(X_train, y_train)
PYTHON CODE END

PYTHON CODE START
from sklearn.model_selection import RandomizedSearchCV
from scipy.stats import loguniform
param_dist = { 'alpha': loguniform(1e-3, 1e1) }
search = RandomizedSearchCV(Ridge(), param_dist, n_iter=40, cv=5)
PYTHON CODE END

---

## 4) Optuna Sketch
PYTHON CODE START
import optuna

def objective(trial):
    alpha = trial.suggest_loguniform('alpha', 1e-4, 1e1)
    model = Ridge(alpha=alpha)
    # cross-validate and return score
PYTHON CODE END
