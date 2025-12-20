
Notepad README — Time Series (Energy) NA Imputation
---------------------------------------------------

TASK: Forecast hourly energy_kWh
Columns: timestamp, site_id, temperature_F, energy_kWh

Principles:
- Preserve temporal order.
- Use time-aware interpolation rather than global statistics.

Recommended:
1) temperature_F: Linear interpolation (smooth changes).
   pandas:
   energy_df['temperature_F'] = energy_df['temperature_F'].interpolate(method='linear')

2) energy_kWh: Time interpolation or forward-fill/backward-fill for short gaps.
   pandas:
   energy_df['energy_kWh'] = energy_df['energy_kWh'].interpolate(method='time')
   # fallback
   energy_df['energy_kWh'] = energy_df['energy_kWh'].fillna(method='ffill').fillna(method='bfill')

Alternative:
- Rolling window mean (e.g., 24-hour):
  energy_df['energy_kWh'] = energy_df['energy_kWh'].fillna(
      energy_df['energy_kWh'].rolling(24, min_periods=1).mean()
  )

Notes:
- Detect outages/spikes before imputation; consider flag features for anomalies.
- Split train/test by time; compute imputation on training portion only.
