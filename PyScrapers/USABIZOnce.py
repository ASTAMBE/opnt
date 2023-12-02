import feedparser
from datetime import date, datetime, timedelta
import pytz
from dateutil import parser

indTz = pytz.timezone("Asia/Kolkata")
today = datetime.now(indTz)
currBUSINESS_time = today.strftime("%H:%M:%S")

today = date.today()
## url
url1 = 'https://moxie.foxbusiness.com/google-publisher/latest.xml'
url2 = 'https://fortune.com/feed'
url3 = 'https://financialpost.com/feed'
url4 = 'https://finance.yahoo.com/news/rssindex'
url5 = 'https://feeds.washingtonpost.com/rss/business?itid=lk_inline_manual_37'
url6 = 'https://www.washingtontimes.com/rss/headlines/news/business-economy/'
url7 = 'https://www.latimes.com/business/rss2.0.xml'
url8 = 'https://nypost.com/business/feed/'


rss = []
url_ls = [url1, url2, url3, url4, url5, url6, url7, url8]
scrape_src = ['FOX/BIZ', 'FORT/BUSINESS', 'FPOST/BIZ', 'YAH/BIZ', 'WAPO/BIZ', 'WATIME/BIZ', 'LAT/BIZ', 'NYPOST/BIZ']
scrape_top = ['BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS']
coun_code = ['USA', 'USA', 'USA', 'USA', 'USA', 'USA', 'USA', 'USA']
tag1 = ['BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS']
tag2 = ['BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS']
tag3 = ['BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS', 'BUSINESS']
ntag = ['PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE']

# with open(f"../../scraper/USAALL/USABUSINESSOnce{today.strftime('%d-%m-%Y')}.sql", 'w') as f:
with open(f"/var/www/html/scraper/USAALL/USABUSINESSOnce{today.strftime('%d-%m-%Y')}.sql", 'w', encoding='utf-8') as f:
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
            print("Exception occurred:",e)
            continue

        newsItem = f1.entries

        items_to_insert = []
        for item in newsItem:
            try:
                if 'summary' in item:
                    s = item.summary
                else:
                    s = item.title

                if len(s) >= 500:
                    s = s[:500]

                if not item.published:  # Check if item.published is empty
                    continue

                a = item.published.split()
                try:
                    published_date = datetime.strptime(" ".join(a[:-1]), "%a, %d %b %Y %H:%M:%S")
                except ValueError:
                    try:
                        published_date = parser.parse(item.published)
                    except ValueError:
                        print("Error parsing date:", item.published)
                        continue
                    continue

                published_date = datetime.strptime(" ".join(a[:-1]), "%a, %d %b %Y %H:%M:%S")
                date_only = published_date.date()

                two_days_ago = today - timedelta(days=2)
                if date_only <= two_days_ago:
                    continue

                BUSINESSry_values = [entry['SCRAPE_SOURCE'], entry['SCRAPE_TOPIC'],
                                     today.strftime("%Y-%m-%d"),
                                     entry['COUNTRY_CODE'],
                                     entry['SCRAPE_TAG1'], entry['SCRAPE_TAG2'], entry['SCRAPE_TAG3'], entry['NEWS_TAGS'],
                                     item.title.replace("'", "''"), item.link, item.published, s.replace("'", "''")]

                # Join the values with quotes and commas
                BUSINESSry_values = ["'" + value + "'" for value in BUSINESSry_values]
                items_to_insert.append(
                    '(' + ','.join(BUSINESSry_values).replace('\U0001f933', '').replace('\U0001f440', '') + ')')

            except UnicodeDecodeError:
                # Skip rows with Unicode decode errors
                continue

        if items_to_insert:
            f.write(
                "INSERT INTO WEB_SCRAPE_RAW_L(SCRAPE_SOURCE, SCRAPE_TOPIC, SCRAPE_DATE, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2"
                ", NEWS_TAGS,  SCRAPE_TAG3, NEWS_HEADLINE, NEWS_URL, NEWS_DTM_RAW, NEWS_EXCERPT) VALUES ")
            f.write(',\n'.join(items_to_insert))
            f.write(';\n')
