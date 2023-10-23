import feedparser
from datetime import date, datetime, timedelta
from dateutil import parser

today = date.today()
## url
url1 = 'https://www.espncricinfo.com/rss/content/story/feeds/0.xml'
url2 = 'https://www.indiatoday.in/rss/1206550'
url3 = 'https://timesofindia.indiatimes.com/rssfeeds/4719148.cms'
url4 = 'https://timesofindia.indiatimes.com/rssfeeds/54829575.cms'
url5 = 'https://feeds.feedburner.com/ndtvsports-cricket'
url6 = 'https://feeds.feedburner.com/ndtvsports-latest'

rss = []


def convert_to_desired_format(rss_date):
    # Parse the date using dateutil parser, which can handle both formats
    dt_object = parser.parse(rss_date)

    # Convert the datetime object to the desired string format
    formatted_date = dt_object.strftime("%b/%d/%Y %H:%M:%S")
    return formatted_date


def find_pubdate_date(pub_date_str):
    # Parse the pubDate string to a datetime object
    pub_date = parser.parse(pub_date_str)

    # Get the date portion of the pubDate
    pub_date_date = pub_date.date()

    return pub_date_date


url_ls = [url1, url2, url3, url4, url5, url6]
scrape_src = ['ESPN/CRIC', 'ITODAY/SPORTS', 'TOI/SPORTS', 'TOI/CRIC', 'NDTV/CRIC', 'NDTV/SPORTS']
scrape_top = ['SPORTS', 'SPORTS', 'SPORTS', 'SPORTS', 'SPORTS', 'SPORTS']
coun_code = ['IND', 'IND', 'IND', 'IND', 'IND', 'IND']
tag1 = ['SPORTS', 'SPORTS', 'SPORTS', 'SPORTS', 'SPORTS', 'SPORTS']
tag2 = ['SPORTS', 'SPORTS', 'SPORTS', 'SPORTS', 'SPORTS', 'SPORTS']
tag3 = ['SPORTS', 'SPORTS', 'SPORTS', 'SPORTS', 'SPORTS', 'SPORTS']
ntag = ['PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE']

with open(f"INDSports{today.strftime('%d-%m-%Y')}.sql", 'w', encoding='utf-8') as f:
    for i in range(len(url_ls)):
        entry = {}
        entry['url_en'] = url_ls[i]
        entry['SCRAPE_SOURCE'] = scrape_src[i]
        entry['SCRAPE_TOPIC'] = scrape_top[i]
        entry['COUNTRY_CODE'] = coun_code[i]
        entry['SCRAPE_TAG1'] = tag1[i]
        entry['SCRAPE_TAG2'] = tag2[i]
        entry['SCRAPE_TAG3'] = tag3[i]
        entry['NEWS_TAGS'] = ntag[i]

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

            a = item.published
            published_date = convert_to_desired_format(a)
            date_only = find_pubdate_date(item.published)

            two_days_ago = today - timedelta(days=2)
            if date_only <= two_days_ago:
                continue

            entry_values = [entry['SCRAPE_SOURCE'], entry['SCRAPE_TOPIC'], today.strftime("%Y-%m-%d"),
                            entry['COUNTRY_CODE'],
                            entry['SCRAPE_TAG1'], entry['SCRAPE_TAG2'], entry['SCRAPE_TAG3'], entry['NEWS_TAGS'],
                            item.title.replace("'", "''"), item.link, published_date, s.replace("'", "''")
                , published_date]

            # Join the values with quotes and commas
            entry_values = ["'" + value + "'" for value in entry_values]
            items_to_insert.append(
                '(' + ','.join(entry_values).replace('\u2009', '').replace('\u20b9', '').replace('\u200b', '') + ')')

        if items_to_insert:
            f.write(
                "INSERT INTO WEB_SCRAPE_RAW_L(SCRAPE_SOURCE, SCRAPE_TOPIC, SCRAPE_DATE, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2,  SCRAPE_TAG3"
                ", NEWS_TAGS, NEWS_HEADLINE, NEWS_URL, NEWS_DTM_RAW, NEWS_EXCERPT, NEWS_DATE) VALUES ")
            f.write(',\n'.join(items_to_insert))
            f.write(';\n')
