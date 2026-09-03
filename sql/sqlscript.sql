-- Checking for matching dates 

con.sql("SELECT MIN(date) AS earliest, MAX(date) AS latest" FROM qqq).show()
con.sql("SELECT MIN(date) AS earliest, MAX(date) AS latest" FROM dfii10).show()

-- Renamed the observation date column in the dfii10 table 
con.sql("ALTER TABLE dfii10 RENAME observation_date TO date")
con.sql("SELECT * FROM dfii10 LIMIT 5").show()

-- Checking for NULL values 
con.sql("SUMMARIZE qqq").show()
con.sql("SUMMARIZE dfii10").show()
con.sql("SELECT * FROM dfii10 WHERE DFII10 IS NULL").show()

-- Checking for duplicate dates 
con.sql("SELECT date, COUNT(*) AS occurrences FROM qqq GROUP BY date HAVING COUNT(*) > 1")
con.sql("SELECT date, COUNT(*) AS occurrences FROM dfii10 GROUP BY date HAVING COUNT(*) > 1")

-- Checking for dates in QQQ but missing in DFII10
con.sql("SELECT date FROM qqq EXCEPT SELECT date FROM dfii10 ORDER BY date").show()
con.sql("SELECT date FROM dfii10 EXCEPT SELECT date FROM qqq ORDER BY date").show()

-- Forward-filling data in dfii10 
con.sql("CREATE TABLE dfii10_filled AS SELECT 
        date, COALESCE(dfii10, LAST_VALUE(DFII10 IGNORE NULLS) 
        OVER
        (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        AS dfii10)
        FROM dfii10
        ORDER BY date")

-- qqq: building the daily returns column 
con.sql("ALTER TABLE qqq ADD COLUMN daily_return_qqq DOUBLE")

con.sql("""
UPDATE qqq 
SET daily_return_qqq = sub.daily_return
FROM (
    SELECT date,
    (adj_close - LAG(adj_close) OVER (ORDER BY date)) / LAG(adj_close) OVER (ORDER BY date) AS daily_return)
    FROM qqq
    ) sub
WHERE qqq.date = sub.date
""")

-- Quick sanity check 
con.sql("SELECT * FROM qqq LIMIT 5")

-- dfii10_filled: building the daily_yield_change 

con.sql("ATLER TABLE dfii10_filled ADD COLUMN daily_yield_change DOUBLE")

con.sql("""
UPDATE dfii10_filled
SET daily_yield_change = sub.daily_yield_change 
FROM (
    SELECT date,
    (dfii10 - LAG(dfii10) OVER (ORDER BY date) * 100 AS daily_yield_change)
    FROM dfi110_filled
    ) sub
WHERE dfii10_filled.date = sub.date
""")

-- sanity check 
con.sql("SELECT * FROM dfii10_filled LIMIT 5").show()

-- merging using LEFT JOIN 
con.sql("""
CREATE TABLE merged AS
    SELECT qqq.date, qqq.adj_close, qqq.daily_return_qqq,
    dfii10_filled.dfii10, dfii10_filled.daily_yield_change
    FROM qqq
    LEFT JOIN dfii10_filled
    ON qqq.date = dfii10_filled.date
    ORDER BY qqq.date
""").show()

-- computing basic stats in SQL before python
con.sql("""
SELECT 
    AVG(daily_return_qqq) AS avg_qqq_return,
    AVG(daily_yield_change) AS avg_yield_change,
    STDDEV(daily_return_qqq) AS stddev_qqq_return,
    STDDEV(daily_yield_change) AS stddev_daily_yield_change,
    MIN(daily_return_qqq) AS min_qqq_return,
    MAX(daily_return_qqq) AS max_qqq_return,
    MIN(daily_yield_change) AS min_yield_change,
    MAX(daily_yield_change) AS max_yield_change,
    MEDIAN(daily_qqq_return) AS median_qqq_return,
    MEDIAN(daily_yield_change) AS median_yield_change
FROM merged
WHERE daily_yield_change IS NOT NULL AND daily_return_qqq IS NOT NULL 
""").show()