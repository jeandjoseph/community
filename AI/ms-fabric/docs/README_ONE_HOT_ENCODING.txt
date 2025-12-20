
One‑Hot Encoding (OHE) — Practical Guide for the Sample ML Datasets

This README explains **when and how** to apply one‑hot encoding (OHE) to the categorical columns in the four synthetic datasets you’re using for training. It also covers pipeline design, data leakage prevention, handling unseen categories, sparse outputs, and alternatives for high‑cardinality features.

---

#Why One‑Hot Encoding?
Many ML algorithms expect numeric inputs. OHE converts categorical values into a set of binary indicator columns (0/1) without imposing any artificial ordering, making it suitable for linear models, neural networks, and many general workflows. Tree‑based models (Random Forest, XGBoost, LightGBM) can often work without OHE, but OHE may still help depending on the data and objective.

---

#Dataset‑Specific Guidance

##1) Regression — `regression_housing.csv`
**Categorical columns:**
- `city` → OHE (nominal)
- `neighborhood` → OHE (nominal)
**Binary columns:**
- `has_garage`, `has_renovation` → keep as 0/1 (do not OHE)

**Recommended:** OHE for `city`, `neighborhood`, especially for linear/ridge/lasso models. For tree‑based models, OHE is optional; label encoding or leaving them as categories (when supported) can suffice.

**Example (scikit‑learn):**
PYTHON CODE START

from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
from sklearn.pipeline import Pipeline
from sklearn.linear_model import Ridge

cat_cols = ['city', 'neighborhood']
num_cols = ['beds', 'baths', 'sqft', 'built_year', 'lot_acres',
            'has_garage', 'has_renovation']

preprocess = ColumnTransformer([
    ('cat', OneHotEncoder(handle_unknown='ignore', sparse=True), cat_cols),
    ('num', 'passthrough', num_cols)
])

model = Pipeline([
    ('prep', preprocess),
    ('est', Ridge(alpha=1.0))
])

PYTHON CODE END

---

##2) Classification — `classification_churn.csv`
**Categorical columns (use OHE):** `segment`, `region`, `payment_type`
**Binary columns (keep as numeric 0/1):** `auto_renew`, `promo_last_180d`

**Recommended:** OHE for nominal fields (`segment`, `region`, `payment_type`) in logistic regression, neural nets, and tree models (optional). If you introduced an `'Unknown'` bucket for missing values, include it in OHE.

**Example:**
PYTHON CODE START

from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression

cat_cols = ['segment', 'region', 'payment_type']
num_cols = ['months_on_service', 'monthly_fee', 'num_logins_30d',
            'num_tickets_90d', 'add_on_count', 'auto_renew', 'promo_last_180d']

preprocess = ColumnTransformer([
    ('cat', OneHotEncoder(handle_unknown='ignore', sparse=True), cat_cols),
    ('num', 'passthrough', num_cols)
])

clf = Pipeline([
    ('prep', preprocess),
    ('est', LogisticRegression(max_iter=1000))
])

PYTHON CODE END

---

##3) Clustering — `clustering_sales.csv`
**Categorical column:** `category` → OHE if you include it in clustering.
**Helper label:** `cluster_label` → do **not** use for modeling (only for validation).

**Recommended:** Scale numeric features and (optionally) include `category` via OHE for k‑means/GMM. Remember OHE increases dimensionality — evaluate whether the signal from `category` justifies the extra features.

**Example:**
PYTHON CODE START

from sklearn.preprocessing import StandardScaler
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
from sklearn.pipeline import Pipeline
from sklearn.cluster import KMeans

cat_cols = ['category']
num_cols = ['price', 'margin_pct', 'monthly_sales_units', 'return_rate']

preprocess = ColumnTransformer([
    ('cat', OneHotEncoder(handle_unknown='ignore', sparse=False), cat_cols),
    ('num', StandardScaler(), num_cols)
])

km = Pipeline([
    ('prep', preprocess),
    ('est', KMeans(n_clusters=3, n_init=10, random_state=42))
])

PYTHON CODE END

---

##4) Time Series — `timeseries_energy.csv`
**Categorical column:** `site_id` (in provided data it’s a single value) → OHE **not needed**. 
**Temporal features:** do **not** OHE `timestamp`. Instead, derive cyclical features.

**Recommended:** Extract time‑based features (hour, day of week, month) and encode cyclical components using sine/cosine.

**Example:**
PYTHON CODE START

import pandas as pd
import numpy as np

df['hour'] = df['timestamp'].dt.hour
cyclical encoding
df['hour_sin'] = np.sin(2 * np.pi * df['hour'] / 24)
df['hour_cos'] = np.cos(2 * np.pi * df['hour'] / 24)

PYTHON CODE END

---

#Implementation Notes & Best Practices

##1) Prevent data leakage
- Fit encoders **only on the training split**.
- Use `ColumnTransformer`/`Pipeline` so transformations are learned from training data and applied consistently.

##2) Handle unseen categories
- Set `handle_unknown='ignore'` in `OneHotEncoder` to avoid errors at inference.

##3) Sparse vs dense output
- `OneHotEncoder(..., sparse=True)` returns a sparse matrix. Many estimators accept sparse input; if not, set `sparse=False` to get dense arrays.

##4) High‑cardinality features
- For very large category sets (e.g., thousands of cities), consider:
  - **Hashing** (`FeatureHasher`) to bound dimensionality
  - **Target encoding** (with careful cross‑validation to avoid leakage)
  - **Frequency/rare category bucketing** (group infrequent values into `'Other'`)

##5) Interaction features
- If domain knowledge suggests interactions (e.g., `city × neighborhood`), consider polynomial features or explicit interaction terms.

##6) Model choice
- Linear/GLM/NN: benefit strongly from OHE.
- Trees/boosting: OHE optional; test both ways.

---

#End‑to‑End Template (with imputation + OHE)
Below is a combined preprocessing template for the **housing** dataset, including imputation and OHE in one pipeline.

PYTHON CODE START

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.pipeline import Pipeline
from sklearn.linear_model import Ridge

Load
housing_df = pd.read_csv('regression_housing.csv')
X = housing_df.drop(columns=['price'])
y = housing_df['price']

num_cols = ['beds', 'baths', 'sqft', 'built_year', 'lot_acres', 'has_garage', 'has_renovation']
cat_cols = ['city', 'neighborhood']

Train/test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

numeric_pipe = Pipeline([
    ('impute', SimpleImputer(strategy='median')),
])

categorical_pipe = Pipeline([
    ('impute', SimpleImputer(strategy='most_frequent')),  if any NA in cat
    ('ohe', OneHotEncoder(handle_unknown='ignore', sparse=True))
])

preprocess = ColumnTransformer([
    ('num', numeric_pipe, num_cols),
    ('cat', categorical_pipe, cat_cols)
])

model = Pipeline([
    ('prep', preprocess),
    ('est', Ridge(alpha=1.0))
])

model.fit(X_train, y_train)
print('Train R^2:', model.score(X_train, y_train))
print('Test R^2:', model.score(X_test, y_test))

PYTHON CODE END

---

#Versioning & Reproducibility
- Save fitted encoders (via the whole pipeline using `joblib.dump`).
- Record random seeds and library versions.
- Document feature lists and any bucketing rules (e.g., rare categories → `'Other'`).

---

#Quick Checklist
- [ ] Identify categorical vs numeric features
- [ ] Impute missing values appropriately (median/mode/time‑aware)
- [ ] Apply OHE to nominal categories; keep binary as numeric
- [ ] Guard against unseen categories at inference
- [ ] Evaluate sparse vs dense performance
- [ ] Avoid leakage by fitting on training only

---

This guide is designed for drop‑in use in your training projects.
