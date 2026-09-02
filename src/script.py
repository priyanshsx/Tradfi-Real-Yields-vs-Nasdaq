import pandas as pd
import matplotlib.pyplot as plt
import duckdb
from scipy import stats

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