import feedparser
from datetime import date, datetime, timedelta
import pytz
from dateutil import parser

indTz = pytz.timezone("Asia/Kolkata")
today = datetime.now(indTz)
current_time = today.strftime("%H:%M:%S")

today = date.today()
## url
url1 = 'https://www.slashfilm.com/feed/'
'''
url2 = 'https://soapdirt.com/feed/'
url3 = 'https://www.tmz.com/rss.xml'
url4 = 'https://abcnews.go.com/abcnews/entertainmentheadlines'
url4 = 'https://www.slashfilm.com/feed/'
url5 = 'https://www.giantfreakinrobot.com/feed'
url6 = 'https://www.latimes.com/entertainment-arts/rss2.0.xml'
url7 = 'https://feeds.washingtonpost.com/rss/entertainment'
url8 = 'https://www.usmagazine.com/category/entertainment/feed/'
'''


rss = []
url_ls = [url1]
scrape_src = ['GFROBOT/ENT']
scrape_top = ['ENT']
coun_code = ['USA']
tag1 = ['ENT']
tag2 = ['ENT']
tag3 = ['ENT']
ntag = ['PYSCRAPE']

# with open(f"../../scraper/USAALL/USAENTOnce{today.strftime('%d-%m-%Y')}.sql", 'w') as f:
# with open(f"/var/www/html/scraper/USAALL/USAENTOnce{today.strftime('%d-%m-%Y')}.sql", 'w', encoding='utf-8') as f:
with open("c:/AST/scrapefiles/feedchk1.sql", 'w', encoding='utf-8') as f:
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
            s = item.summary if 'summary' in item else item.title
            if len(s) >= 500:
                s = s[:500]

            # Check for 'dc:date' as the date field
            if 'published' in item:
                date_str = item.published
            elif 'updated' in item:
                date_str = item.updated
            elif 'dc:date' in item:
                date_str = item['dc:date']
            else:
                # Skip this entry if no date field is available
                continue

            # Parse the date string
            try:
                # Use `dateutil.parser.parse` to automatically handle different date formats
                published_date = parser.parse(date_str)

                # Format the date as 'YYYY-MM-DD hh:mm:ss'
                formatted_date = published_date.strftime("%Y-%m-%d %H:%M:%S")
            except Exception as e:
                print(f"Error parsing date: {e}")
                continue

            date_only = published_date.date()

            # Compare date with two days ago
            two_days_ago = today - timedelta(days=2)
            if date_only <= two_days_ago:
                continue

            entry_values = [entry['SCRAPE_SOURCE'], entry['SCRAPE_TOPIC'], today.strftime("%Y-%m-%d"),
                            entry['COUNTRY_CODE'],
                            entry['SCRAPE_TAG1'], entry['SCRAPE_TAG2'], entry['SCRAPE_TAG3'], entry['NEWS_TAGS'],
                            item.title.replace("'", "''"), item.link, date_str, formatted_date, s.replace("'", "''")]

            # Join the values with quotes and commas
            entry_values = ["'" + value + "'" for value in entry_values]
            items_to_insert.append(
                '(' + ','.join(entry_values).replace('\U0001f933', '').replace('\U0001f440', '') + ')')

        if items_to_insert:
            f.write(
                "INSERT INTO WEB_SCRAPE_RAW_L(SCRAPE_SOURCE, SCRAPE_TOPIC, SCRAPE_DATE, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2"
                ", NEWS_TAGS,  SCRAPE_TAG3, NEWS_HEADLINE, NEWS_URL, NEWS_DTM_RAW, NEWS_DATE, NEWS_EXCERPT) VALUES ")
            f.write(',\n'.join(items_to_insert))
            f.write(';\n')