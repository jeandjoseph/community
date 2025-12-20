
Notepad README — Clustering (Product Sales) NA Imputation
---------------------------------------------------------

TASK: Unsupervised clustering
MISSING: none intentionally; if present, follow below:

Numeric columns: price, margin_pct, monthly_sales_units, return_rate
- Fill with median BEFORE scaling (k-means/GMM are sensitive to scaling).
  pandas:
  for col in ['price','margin_pct','monthly_sales_units','return_rate']:
      sales_df[col] = sales_df[col].fillna(sales_df[col].median())

Categorical columns: category, cluster_label (helper)
- Fill with mode.
  pandas:
  sales_df['category'] = sales_df['category'].fillna(sales_df['category'].mode()[0])

Advanced variant:
- Scale numeric features, then KNNImputer for structure-aware fills.
  from sklearn.preprocessing import StandardScaler
  from sklearn.impute import KNNImputer
  num_cols = ['price','margin_pct','monthly_sales_units','return_rate']
  scaler = StandardScaler()
  Xs = scaler.fit_transform(sales_df[num_cols])
  imputer = KNNImputer(n_neighbors=5)
  sales_df[num_cols] = imputer.fit_transform(Xs)

Notes:
- Always perform imputation within your pipeline to avoid data leakage.
