import feedparser
from datetime import date, datetime, timedelta

today = date.today()
## url
url1 = 'https://www.newindianexpress.com/Entertainment/English/rssfeed/?id=194&getXmlFeed=true'
url2 = 'https://feeds.feedburner.com/bignewsnetwork/alSnr13fEUK'
url3 = 'https://www.thehindu.com/entertainment/movies/feeder/default.rss'
url4 = 'https://www.huffpost.com/section/celebrity/feed'
url5 = 'https://thehill.com/homenews/administration/feed/'
url6 = 'https://feeds.washingtonpost.com/rss/SPORTS'
rss = []
url_ls = [url1, url2, url3, url4, url5, url6]
scrape_src = ['ESPN/CRIC', 'HINDU/SPORTS', 'NYT/POL', 'HUFF/CELEB', 'HILL/ADMIN', 'WAPO/POL']
scrape_top = ['SPORTS', 'SPORTS', 'SPORTS', 'CELEB', 'SPORTS', 'SPORTS']
coun_code = ['IND', 'IND', 'IND', 'IND', 'IND', 'IND']
tag1 = ['SPORTS', 'SPORTS', 'SPORTS', 'CELEB', 'SPORTS', 'SPORTS']
tag2 = ['SPORTS', 'SPORTS', 'SPORTS', 'CELEB', 'SPORTS', 'SPORTS']
tag3 = ['SPORTS', 'SPORTS', 'SPORTS', 'CELEB', 'SPORTS', 'SPORTS']

with open("INDSports.sql", 'w') as f:
    for i in range(len(url_ls)):
        entry = {}
        entry['url_en'] = url_ls[i]
        entry['SCRAPE_SOURCE'] = scrape_src[i]
        entry['SCRAPE_TOPIC'] = scrape_top[i]
        entry['COUNTRY_CODE'] = coun_code[i]
        entry['SCRAPE_TAG1'] = tag1[i]
        entry['SCRAPE_TAG2'] = tag2[i]
        entry['SCRAPE_TAG3'] = tag3[i]
        rss.append(entry)

        f1 = feedparser.parse(entry['url_en'])
        newsItem = f1.entries

        items_to_insert = []
        for item in newsItem:
            s = item.summary
            if len(s) <= 0:
                s = item.title
            if len(s) >= 500:
                s = item.summary[:500]

            a = item.published.split()
            published_date = datetime.strptime(" ".join(a[:-1]), "%a, %d %b %Y %H:%M:%S")
            date_only = published_date.date()

            two_days_ago = today - timedelta(days=2)
            if date_only <= two_days_ago:
                continue

            entry_values = [entry['SCRAPE_SOURCE'], entry['SCRAPE_TOPIC'], today.strftime("%m/%d/%Y"),
                            entry['COUNTRY_CODE'],
                            entry['SCRAPE_TAG1'], entry['SCRAPE_TAG2'], entry['SCRAPE_TAG3'],
                            item.title.replace("'", "''"), item.link, item.published, s.replace("'", "''")]

            # Join the values with quotes and commas
            entry_values = ["'" + value + "'" for value in entry_values]
            items_to_insert.append('(' + ','.join(entry_values) + ')')

        if items_to_insert:
            f.write(
                "INSERT INTO WEB_SCRAPE_RAW(SCRAPE_SOURCE, SCRAPE_TOPIC, SCRAPE_DATE, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2,  SCRAPE_TAG3, NEWS_HEADLINE, NEWS_URL, NEWS_DTM_RAW, NEWS_EXCERPT) VALUES ")
            f.write(',\n'.join(items_to_insert))
            f.write(';\n')