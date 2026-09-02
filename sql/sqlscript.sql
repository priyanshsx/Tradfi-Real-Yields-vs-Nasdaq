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

-- Observations 
-- 1. DFII10 seems to have 17 entries with NULL in DFII10 column. 
-- 2. There are no NULL values in qqq. 
-- 3. 