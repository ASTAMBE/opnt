import feedparser
from datetime import date, datetime, timedelta

today = date.today()
## url
url1 = 'http://thehill.com/policy/international/feed/'
url2 = 'http://indianexpress.com/section/sports/feed/'
rss = []
f1 = feedparser.parse(url2)
print(f1)

