# Do rising real yields hurt growth stocks? How sensitive has the NASDAQ-100 been to changes in US real interest rates?

## Overview 

The 10-year real yield (DFII10, 10-Year Treasury Inflation-Protected Security yield) represents the inflation-adjusted return available from lending money to the US government for approx 10 years. 

Real yields matter for risk assets because they set the effective "hurdle rate" for riskier investments. When real yields are low or negative, investors have less incentive to sit in safe govt. debt, so capital tends to flow toward equities, tech stocks, crypto, etc. When real yields rise, safe bonds become more attractive on their own merit. 

This added pressure typically shows up as lower valuations for growth-oriented assets, since their value depends heavily on future cash flows being discounted at a now higher rate. 

This project investigates that relationship empircally, using QQQ (used here as a proxy for large-cap growth/tech equities) and DFII10 as a real-world test case. Specifically, it asks what kind of statistical relationship, if any, exists between daily changes in the real yield and daily returns on QQQ. 


## Research Question
When the inflation-adjusted return available on safe government bonds rises, do growth equities tend to perform worse?

This project tests that question along four dimensions:

- Is the correlation between real yield changes and QQQ returns negative, as theory predicts?
- How strong is that relationship, in practical terms (not just whether it exists)?
- Is it statistically distinguishable from random noise?
- Does the relationship hold up when tested rigorously, or does it weaken under scrutiny?

The underlying economic logic being tested: Restrictive monetary policy tends to push real yields higher. Higher real yields raise the discount rate used to value future cash flows, which lowers the present value of growth stocks in particular (since more of their expected value sits further in the future). This should, in theory, make safe bonds relatively more attractive than risk-on assets like QQQ — meaning periods of rising real yields should coincide with weaker QQQ performance. This project tests whether that theoretical relationship is actually visible in the data at a daily level. 

## Data
- **Source:** FRED, Yahoo Finance
- **Time period:** Jan 2025 – Aug 2026
- **Granularity:** Daily OHLCV
- **Size:** ()
- **Access method:** CSV download, direct pull from Yahoo Finance 

## Tools & Methods
- **Database:** DuckDB (SQL) for storage, cleaning, and aggregation
- **Language:** Python (pandas, numpy, matplotlib/plotly, scipy.stats, statsmodels)
- **Key techniques used:** window functions, GROUP BY aggregation, OLS regression

## Pipeline

1. **Ingestion**: Daily QQQ price data (OHLCV) and DFII10 (10-year Treasury Inflation-Indexed Security, real yield) data were downloaded as CSVs and loaded into DuckDB tablees using read_csv_auto(). The QQQ file rqeuired skipping 3 header rows due to a multi-row ticker/metadata header/ 
2. **Cleaning**: DFII10 contained 17 NULL values, all falling on US market holidays (confirmed by cross-referencing against QQQ's missing dates using EXCEPT). These were resolved using a forward-fill, carrying the last known yield forward. A 2-3 publication lag was identified between QQQ and DFII10(FRED, delayed). QQQ's most recent unmatched dates were left as NULL post-join and excluded from analysis via WHERE...IS NOT NULL. Duplicate dates were checked for and confirmed absent in both tables prior to merging. 
3. **Transformation**: Two derived columns were created using LAG() window functions in SQL: (1) daily_return_qqq, the standard percentage return (price - previous_price / previous_price_ and 2)daily_yield_change, the raw day-over-day change in DFII10 expressed in basis points (yield - previous_yield) * 100. Basis points were used for the yield series, since yields are already normalized rates where absolute point movement is the economically meaningful unit. 
4. **Exploratory Analysis (EDA)**: Summary statistics (mean, median, standard deviation, min/max) were computed in SQL for both derived series. An initial scatter plot of daily_yield_change vs. daily_return_qqq showed no visually obvious linear patter. This prompted further statistical tests rather than relying on visual inspection alone. 
5. **Statistical Analysis / Modeling**: Pearson correlation (r = -0.097, p = 0.0481) and a simple OLS regression (coefficient = -0.0004, p = 0.048, R-squared = 0.009) were run in Python to formally test the relationship. Both methods agree: there is a small, negative, borderline-significant relationship between daily yield changes and QQQ returns, but it explains under 1% of daily return variance. Regression diagnostics (Jarque-Bera, kurtos = 16) indicate non-normal, fat-tailed residuals. This suggests that the borderline p-value should be interpreted cautiously rather than treated as strong evidence of a real daily-level effect. 
6. **Visualization**: A scatter plot with the fitted OLS regression line and 95% confidence interval was produced in Python to visually communicate both the weak negative slope and the substantial uncertainty/noise surrounding it, reinforcing the statistical finding that the relationship, while directionally present, is not practically meaningful at the daily level. 

## Key Findings

- Daily changes in the 10-year real real yield (DFII10) show a weak negative correlation with   QQQ's daily returns (r = -0.097, p = 0.048), just below the conventional 5% significance threshold. 
- However, this relationship explains less than 1% of the variation in QQQ's daily returns (R-squared = 0.009) even though the effect is likely not due to pure chance, it is too small to be practically meaningful for understanding or predicting daily QQQ performance. 
- The regression's residuals are strongly non-normal (Jarque-Bera test, kurtosis = 16), a common feature of daily financial return data. Given the p-value sits right at the 0.05 boundary, this result should be treated as borderline rather than robust evidence of a real daily-level effect. 
- Overall, the data suggests that if a relationship between real yields and QQQ exists, it does not manifest a consistent economically meaningful pattern at the single-day level, motivating further analysis at a regime/multi-week level rather than a day-to-day one. 

## Visualization

Please refer to the "figures" folder. 

## Limitations & Caveats
This was my first end-to-end data analysis project, and I built it primarily to get comfortable with the full pipeline (SQL + Python) rather than to produce a polished, publication-ready research finding. So please give me room to improve in future! 

- Single asset, single macro variable: I only looked at QQQ against one yield series (DFII10). I picked this pair because it was a manageable starting point for learning joins, window functions, and regression. And not because I had strong priors that this was the most important relationship to test. A more rigorous version of this project would test multiple assets and multiple macro variables before drawing conclusions about "the" relationship between rates and equities. 
- Daily granularity only: I didn't explore intraday data or longer horizons (weekly/monthly), both of which are common in real macro-finance research and might reveal a relationship that daily data is too noisy to detect. 
- I didn't correct for the non-normal residuals I found: I flagged that my regression's errors are fat-tailed (via the Jarque-Bera test), but I used standard OLS rather than a more robust method that might handle this better. I understand why this matters conceptually, but implementing a fix was beyond what I've learned so far. But that will be my next target. 
- Simple linear relationship: I only tested a linear regression. It's possible the real relationship (if any) is non-linear, threshold-based, or only shows up during specific volatility regimes. 
- No out-of-sample testing: I analyzed the full dataset at once rather than splitting it into a training/test period, so I can't say whether any pattern I found would have actually held up if I'd tried to use it predictively in advance. 
- Forward-filling assumption: I forward-filled DFII10's missing values on holidays, which is a common convention, but it does mean those days aren't "real" observations. 

## What I'd Do Next
This project was really about learning the mechanics (SQL joins, window functions, forward-filling, linear regression, and connecting SQL to Python). Now that the pipeline works end to end, here's what I'd want to explore if I were to continue building on this analysis: 
- Move from daily to regime-level analysis: This was actually my original motivation for starting this project. I wanted to eventually classify sustained "rising yield" vs "falling yield" periods (using a rolling average) and compare QQQ's behaviour across those regimes, rather than day-to-day. The daily-level result ehre (weak, borderline relationship) is what pushed me to want to try this next. 
- Add more assets: Repeat this same analysis for other tickers to see whether QQQ's weak relationship with real yields is typical or unusual compared to other assets. 
- Try a more robust statistical test: Now that I understand why my residuals being non-normal is a problem, I'd like to learn how to apply robust standard errors or a bootstrap-based significance test, and see whether my borderline p-value holds up. 
- Learn multi-variable regression: Right now I only tested one predictor at a time. A natural next step would be adding more variables (like VIX or overall market volume) to see whether yield changes still matter once other factors are accounted for. 
- Get more comfortable with the Python/SQL fit: this project taught me a lot about when to reach for SQL vs. Python. I'd like to keep sharpening that muscle and practice it on even bigger datasets. 

## How to Reproduce
### 1. Clone the repo
git clone []
cd [Tradfi-Real-Yields-vs-Nasdaq]

### 2. Install dependencies
pip install duckdb pandas matplotlib scipy statsmodels

### 3. Raw data
Place the raw QQQ and DFII10 CSV files in raw_data/
(see Data section above for sources)

### 4. Build the database and load raw data
Run the SQL scripts in sql/ against a new DuckDB file, e.g.:
python3 src/script.py

### 5. Run the analysis
python3 src/script.py

## Project Structure
```
project-folder/
├── data/                  # raw and/or processed data (or note if excluded from repo)
├── notebooks/             # exploratory analysis
├── scripts/               # reusable/production code (data pull, cleaning, etc.)
├── outputs/               # charts, exported results
├── README.md
```

---
*Author: Priyansh Saxena | https://www.linkedin.com/in/priyansh-saxena/ | 3rd September, 2026*