import pandas as pd
import matplotlib.pyplot as plt
import duckdb
from scipy import stats
import statsmodels.api as sm
import numpy as np

con = duckdb.connect('/home/priyansh/Documents/d/Tradfi Real Yields vs Nasdaq/db/main.duckdb') 

df = con.sql("""
    SELECT date, daily_yield_change, daily_return_qqq
    FROM merged
    WHERE daily_yield_change IS NOT NULL and daily_return_qqq IS NOT NULL
    """).df()

corr, p_value = stats.pearsonr(df['daily_yield_change'], df['daily_return_qqq'])
print(f"Correlation: {corr:.4f}")
print(f"p-value: {p_value: .4f}")

# scatter plot 

plt.figure(figsize=(10,6))
plt.scatter(df['daily_yield_change'], df['daily_return_qqq'], alpha=0.5, s=15)
plt.xlabel('Daily Yield Change (bps)')
plt.ylabel('Daily QQQ Returns')
plt.title('QQQ Return vs. 10-Year Real Yield Change')
plt.grid(alpha=0.3)
plt.show()

# running the OLS regression 
reg_df = df[['daily_return_qqq', 'daily_yield_change']].dropna()

X = reg_df['daily_yield_change'] # independent variable
Y = reg_df['daily_return_qqq'] # dependent variable

X = sm.add_constant(X) # since qqq returns and daily yield change are not moving in exact tandem
model = sm.OLS(Y, X).fit() 
print(model.summary())

# Scatter of the actual data
plt.figure(figsize=(10, 6))
plt.scatter(reg_df['daily_yield_change'], reg_df['daily_return_qqq'], alpha=0.4, s=15, label='Daily observations')

# Build a smooth range of x-values to draw the fitted line across
x_range = np.linspace(reg_df['daily_yield_change'].min(), reg_df['daily_yield_change'].max(), 100)
X_range = sm.add_constant(x_range)  # must add constant here too, matching how the model was fit

# Get predictions + confidence interval from the fitted model
predictions = model.get_prediction(X_range)
pred_summary = predictions.summary_frame(alpha=0.05)  # 95% CI

# Plot the fitted regression line
plt.plot(x_range, pred_summary['mean'], color='red', linewidth=2, label='Fitted regression line')

# Shade the 95% confidence interval around the line
plt.fill_between(x_range, pred_summary['mean_ci_lower'], pred_summary['mean_ci_upper'],
                  color='red', alpha=0.15, label='95% confidence interval')

plt.xlabel('Daily Yield Change (bps)')
plt.ylabel('Daily QQQ Return')
plt.title(f'QQQ Return vs. Yield Change (R² = {model.rsquared:.3f}, p = {model.pvalues["daily_yield_change"]:.3f})')
plt.axhline(0, color='gray', linewidth=0.5)
plt.axvline(0, color='gray', linewidth=0.5)
plt.legend()
plt.grid(alpha=0.3)
plt.show()