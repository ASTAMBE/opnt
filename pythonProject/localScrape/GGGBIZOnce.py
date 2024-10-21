import feedparser
from datetime import date, datetime, timedelta
import pytz
from dateutil import parser

indTz = pytz.timezone("Asia/Kolkata")
today = datetime.now(indTz)
current_time = today.strftime("%H:%M:%S")

today = date.today()
## url
url1 = 'https://www.businessdailyafrica.com/latestrss.rss'
url2 = 'https://bmmagazine.co.uk/feed/'
url3 = 'https://www.cnbc.com/id/100727362/device/rss/rss.html'
url4 = 'https://www.theguardian.com/uk/business/rss'
url5 = 'https://markets.businessinsider.com/rss/news'
url6 = ''
url7 = ''
url8 = ''

rss = []

def convert_to_desired_format(rss_date):
    # Parse the date using dateutil parser, which can handle both formats
    dt_object = parser.parse(rss_date)

    # Convert the datetime object to the desired string format
    formatted_date = dt_object.strftime("%b %d, %Y %H:%M:%S")
    return formatted_date


def find_pubdate_date(pub_date_str):
    # Parse the pubDate string to a datetime object
    pub_date = parser.parse(pub_date_str)

    # Get the date portion of the pubDate
    pub_date_date = pub_date.date()

    return pub_date_date

url_ls = [url1, url2, url3, url4, url5, url6, url7, url8]
scrape_src = ['BIZAFRC/BIZ', 'BMAG/BIZ', 'CNBC/EUROBIZ', 'GUARD/BIZ', 'BIZINS/BIZ', 'LAT/BUSINESS', 'WAPO/BUSINESS', 'USNEWS/BUSINESS']
scrape_top = ['BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS']
coun_code = ['GGG', 'GGG', 'GGG', 'GGG', 'GGG', 'GGG', 'GGG', 'GGG']
tag1 = ['BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS']
tag2 = ['BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS']
tag3 = ['BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS']
ntag = ['PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE']


#with open(f"../../scraper/GGGALL/GGGPOLOnce{today.strftime('%d-%m-%Y')}.sql", 'w') as f:
with open(f"../../scraper/GGGALL/GGGBIZOnce{today.strftime('%d-%m-%Y')}.sql", 'w', encoding='utf-8') as f:
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
            # Check if 'summary' attribute exists
            if 'summary' in item:
                s = item.summary
            else:
                # If 'summary' is not present, use 'title' as a fallback
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
            items_to_insert.append('(' + ','.join(entry_values).replace('\u2009','').replace('\u20b9','').replace('\u200b','') + ')')

        if items_to_insert:
            f.write(
                "INSERT INTO WEB_SCRAPE_RAW_L(SCRAPE_SOURCE, SCRAPE_TOPIC, SCRAPE_DATE, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2,  SCRAPE_TAG3"
                ", NEWS_TAGS, NEWS_HEADLINE, NEWS_URL, NEWS_DTM_RAW, NEWS_EXCERPT, NEWS_DATE) VALUES ")
            f.write(',\n'.join(items_to_insert))
            f.write(';\n')