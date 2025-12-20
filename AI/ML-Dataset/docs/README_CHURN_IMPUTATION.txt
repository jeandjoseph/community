
Notepad README — Classification (Churn) NA Imputation
-----------------------------------------------------

TARGET: churned (0/1)
MISSING: none intentionally; if present, use the following:

Numeric columns: months_on_service, monthly_fee, num_logins_30d,
                 num_tickets_90d, add_on_count
- Fill with median (robust to skew).
  pandas:
  for col in ['months_on_service','monthly_fee','num_logins_30d','num_tickets_90d','add_on_count']:
      churn_df[col] = churn_df[col].fillna(churn_df[col].median())

Categorical columns: segment, region, payment_type, auto_renew, promo_last_180d
- Fill with mode (most frequent) or use an explicit 'Unknown'.
  pandas:
  for col in ['segment','region','payment_type','auto_renew','promo_last_180d']:
      churn_df[col] = churn_df[col].fillna(churn_df[col].mode()[0])
  # or
  churn_df['payment_type'] = churn_df['payment_type'].fillna('Unknown')

Notes:
- Encode categories after imputation.
- Consider class weights or stratified splits to manage imbalance.
