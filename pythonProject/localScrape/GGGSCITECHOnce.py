import feedparser
from datetime import date, datetime, timedelta
from dateutil import parser

today = date.today()
## url
url1 = 'https://timesofindia.indiatimes.com/rssfeeds/66949542.cms'
url2 = 'https://feeds.feedburner.com/gadgets360-latest'
url3 = 'https://feeds.skynews.com/feeds/rss/technology.xml'
url4 = 'https://www.newscientist.com/section/news/feed/'
url5 = 'https://www.sciencedaily.com/rss/all.xml'
url6 = 'https://feeds.washingtonpost.com/rss/business/technology'
url7 = 'https://www.newscientist.com/feed/home/'
url8 = 'https://www.techradar.com/rss'
url9 = 'https://www.wired.com/feed/rss'

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

url_ls = [url1, url2, url3, url4, url5, url6, url7, url8, url9 ]
scrape_src = ['TOI/TECH', 'NDTV/TECH', 'SKY/TECH', 'NEWSCI/NEWS', 'SCIDAILY/SCI', 'WAPO/TECH', 'NEWSCI/ALL', 'TECHRADAR/TECH', 'WIRED/TECH' ]
scrape_top = ['SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE' ]
coun_code = ['GGG', 'GGG', 'GGG', 'GGG', 'GGG', 'GGG', 'GGG', 'GGG', 'GGG']
tag1 = ['SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE' ]
tag2 = ['SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE' ]
tag3 = ['SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE', 'SCIENCE' ]
ntag = ['PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE', 'PYSCRAPE']

#with open(f"/var/www/html/scraper/GGGALL/GGGSCIOnce{today.strftime('%d-%m-%Y')}.sql", 'w', encoding='utf-8') as f:
with open(f"c:/AST/scrapefiles/GGGSCIOnce{today.strftime('%d-%m-%Y')}.sql", 'w', encoding='utf-8') as f:
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
            print("Exception occurred:", e)
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
