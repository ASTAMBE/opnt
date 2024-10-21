import feedparser
from datetime import date, datetime, timedelta, timezone
from dateutil import parser
import os

today = date.today()
## url
url1 = 'https://www.hindustantimes.com/feeds/rss/india-news/rssfeed.xml'
url2 = 'https://www.thehindu.com/news/national/feeder/default.rss'
url3 = 'https://www.news18.com/rss/politics.xml'
url4 = 'https://feeds.feedburner.com/ndtvnews-top-stories'
url5 = 'https://www.livemint.com/rss/politics'
url6 = ''
url7 = ''
url8 = ''
url9 = ''
url10 = ''

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

url_ls = [url1, url2, url3, url4, url5, url6, url7, url8, url9, url10]
scrape_src = ['HT/TOP', 'HINDU/TOP', 'NEWS18/POL', 'NDTV/TOP', 'MINT/POL', 'ESPN/NCF', 'FOX/NASCAR', 'CBS/GOLF', 'YAHOO/POLITICS', 'SILLU/POLITICS']
scrape_top = ['POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS']
coun_code = ['IND', 'IND', 'IND', 'IND', 'IND', 'IND', 'IND', 'IND', 'IND', 'IND']
tag1 = ['POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS']
tag2 = ['POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS']
tag3 = ['POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS', 'POLITICS']
ntag = ['PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE']

# os.chown('/var/www/html/scraper/INDALL/', 1000,1000)

with open(f"INDPOLOnce{today.strftime('%d-%m-%Y')}.sql", 'w', encoding='utf-8') as f:
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
        try:
            f1 = feedparser.parse(entry['url_en'])
        except Exception as e:
            print("Exception occurred in INDPOL:",e)
            continue
        newsItem = f1.entries

        items_to_insert = []
        for item in newsItem:
            try:
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
                                item.title.replace("'", "''"), item.link, published_date, s.replace("'", "''"),
                                published_date]

                # Join the values with quotes and commas
                entry_values = ["'" + value + "'" for value in entry_values]
                items_to_insert.append(
                    '(' + ','.join(entry_values).replace('\u0101', '').replace('\u2015', '').replace('\u202f',
                                                                                                     '').replace(
                        '\u0107', '') + ')')

            except UnicodeDecodeError:
                # Skip rows with Unicode decode errors
                continue

        # Write the INSERT statements to the file
        if items_to_insert:
            f.write(
                "INSERT INTO WEB_SCRAPE_RAW_L(SCRAPE_SOURCE, SCRAPE_TOPIC, SCRAPE_DATE, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3"
                ", NEWS_TAGS, NEWS_HEADLINE, NEWS_URL, NEWS_DTM_RAW, NEWS_EXCERPT, NEWS_DATE) VALUES ")
            f.write(',\n'.join(items_to_insert))
            f.write(';\n')