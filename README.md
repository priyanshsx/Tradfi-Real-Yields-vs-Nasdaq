# Do rising real yields hurt growth stocks? How sensitive has the NASDAQ-100 been to changes in US real interest rates?

## Overview

    The 10-year real yield represents the inflation-adjusted return available from lending money essentially risk-free to the US government for approximately 10 years. 
    
    Breakeven inflation rate is calculated as the difference between the 10Y treasury yield and the 10Y TIPS yield. 
    
    When the real yield tends to be below 0, investors may be more willing to take risk in equities, tech stocks, crypto, real estate, commodities. But if these real yields rise up then investors are likely to rely on bonds as they also reduce the credit risk for the investors. Thus, the hurdle rate for risky investments becomes higher. This puts pressure on asset valuations. 
    
    This project investigates what the relation between real yields and NASDAQ is. And, specifically, it attempts to answer what kind of correlation exists between the two. 

## Research Question
    This project raises the crucial question: When the inflation-adjusted return available on safe government bonds rises, do growth equities tend to perform worse? Then we test: 
        - Is the correlation negative? 
        - How strong is the relationship? 
        - Is it distinguishable from noise? 
        - Does the relationship persist through time?
    
    We attempt to follow this workflow:
    A restrictive monetary policy impacts real yields positively. This further increases the discount rates, lowering the present value of growth stocks. Thus, it flips the attractiveness of risk-on assets like the NASDAQ against the bonds.  

## Workflow 
    1. Decide on data sources. 
        - Made a decision on which source to use exactly. 
        variable | economic meaning | frequency | source | units | date range 
        We will go with QQQ because its the tradable wrapper around the Nasdaq-100 Index.
        Further, we will choose the DFII10 from FRED because it offers the 10y real yield that we're looking to compare against QQQ.  
    2. Define the raw data inputs. 
       QQQ: Date, Open, High, Low, Close, Adjusted Close, Volume 
       DFII10: Date, Real_Yield_10Y
       Period: 2025-01-01 through 2026-08-31
    3. Build the raw-data layer. Use source_qqq.py to reproduce qqq.csv for the given duration.
        Raw data is untouched: main.db created with two tables: 
            1. qqq
            2. dfii10  
        Processed data should be separate. 
        Acquisition script should be reproducible. 
    4. Inspect data quality. 
        We're checking for: 
            - date range 
            - missing obversations 
            - duplicates
            - data types 
            - weekends/holidays 
            - null values 
    5. Build the analytical dataset. 

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

A simple OLS regression finds a small, negative, and boderline-significant relationship between daily 10-year real yield changes and QQQ daily returns: 
    coefficient = -0.0004
    p = 0.048 
This explains the under 1% of return variance (R² = 0.009).

Given non-normal, fat-tailed residuals (confirmed via Jarque-Bera test), this borderline p-value should be interpreted cautiously - the true relationship may not be statistically distinguishable from noise under more robust testing. This weak daily-level result motivates examining the relationship at a regime level (sustained multi-week yield trends) rather than day-to-day, where the relationship may be more pronounced. 


## Visualization
Embed or link your key chart(s) here. One strong chart that tells the whole story is worth more than five mediocre ones.

`![chart description](path/to/chart.png)`

## Limitations & Caveats
Be honest — this signals analytical maturity, not weakness.

> Example: Volatility was measured using simple high-low range rather than realized volatility from tick data; results may differ at higher granularity. Data covers only [exchange name], which may not represent the full market.

## What I'd Do Next
Shows you're thinking beyond the scope of this one project — good signal for interviews.

> Example: Extend this to compare volatility patterns across BTC, ETH, and SOL to see if the timing pattern is BTC-specific or market-wide.

## How to Reproduce
```bash
# Clone repo
git clone [repo link]

# Install dependencies
pip install -r requirements.txt

# Run the analysis
python analysis.py
```

## Project Structure
```
project-folder/
├── data/                  # raw and/or processed data (or note if excluded from repo)
├── notebooks/             # exploratory analysis
├── scripts/               # reusable/production code (data pull, cleaning, etc.)
├── outputs/               # charts, exported results
├── README.md
└── requirements.txt
```

---
*Author: [Your name] | [LinkedIn/portfolio link] | [Date completed]*