import yfinance as yf

qqq = yf.download("QQQ", start="2025-01-01", auto_adjust=False)
qqq.to_csv("QQQ.csv")
print(qqq.tail(10))