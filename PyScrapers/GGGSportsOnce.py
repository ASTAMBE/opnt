import feedparser
from datetime import date, datetime, timedelta

today = date.today()
## url
url1 = 'https://www.sportsworldnews.com/rss/sections/soccer.xml'
url2 = 'https://moxie.foxnews.com/google-publisher/world.xml'
url3 = 'https://rss.nytimes.com/services/xml/rss/nyt/World.xml'
url4 = 'https://www.huffpost.com/section/world-news/feed'
url5 = 'https://www.sciencedaily.com/rss/all.xml'
url6 = 'https://feeds.washingtonpost.com/rss/business/technology'
url7 = 'https://www.wired.com/feed/category/science/latest/rss'
url8 = 'http://feeds.bbci.co.uk/news/rss.xml'
url9 = 'https://feeds.washingtonpost.com/rss/world'

rss = []

url_ls = [url1, url2, url3, url4, url5, url6, url7, url8, url9 ]
scrape_src = ['SPWORLD/SPORTS', 'FOX/GLOBAL', 'NYT/GLOBAL', 'HUFF/GLOBAL', 'SCIDAILY/SCI', 'WAPO/TECH', 'WIRED/SCI', 'BBC/POL', 'WAPO/GLOBAL' ]
scrape_top = ['SPORTS', 'POLITICS', 'POLITICS', 'POLITICS', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'POLITICS', 'POLITICS'  ]
coun_code = ['GGG', 'GGG', 'GGG', 'GGG', 'GGG', 'GGG', 'GGG', 'GGG', 'GGG']
tag1 = ['SPORTS', 'GPOL', 'GPOL', 'GPOL', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'GPOL', 'GPOL' ]
tag2 = ['SPORTS', 'GPOL', 'GPOL', 'GPOL', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'GPOL', 'GPOL' ]
tag3 = ['SPORTS', 'GPOL', 'GPOL', 'GPOL', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'GPOL', 'GPOL' ]

with open("GGGSportsOnce0712.sql", 'w') as f:
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
            '''
            a = item.published.split()
            published_date = datetime.strptime(" ".join(a[:-1]), "%a, %d %b %Y %H:%M:%S")
            date_only = published_date.date()

            two_days_ago = today - timedelta(days=2)
            if date_only <= two_days_ago:
                continue
            '''
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