import os
import mysql.connector
from dotenv import load_dotenv
import feedparser
from iso3166 import countries_by_alpha3
import time

# Load environment variables
load_dotenv("C:\\AST\\GitHub\\set_env.env")

# Ask for environment selection
environment = input("Enter environment (DEV/PROD): ").strip().upper()
while environment not in ["DEV", "PROD"]:
    environment = input("Invalid choice. Enter environment (DEV/PROD): ").strip().upper()

db_config = {
    "DEV": {
        "host": os.getenv("DEV_DB_HOST"),
        "user": os.getenv("DEV_DB_USER"),
        "password": os.getenv("DEV_PWD"),
        "database": os.getenv("DEV_DATABASE"),
    },
    "PROD": {
        "host": os.getenv("PROD_DB_HOST"),
        "user": os.getenv("PROD_DB_USER"),
        "password": os.getenv("PROD_PWD"),
        "database": os.getenv("PROD_DATABASE"),
    },
}

DB_CONFIG = db_config[environment]

# Topic mapping
TOPICS = {
    1: "politics",
    2: "sports",
    4: "business",
    5: "entertainment",
    10: "celebrities"
}

# Connect to DB
conn = mysql.connector.connect(**DB_CONFIG)
cursor = conn.cursor(dictionary=True)

# Ask user: one country or all
scope = input("Run for (A)ll countries or (O)ne specific TRUE_COUNTRY_CODE? ").strip().upper()
if scope == 'O':
    true_country_code = input("Enter the TRUE_COUNTRY_CODE (e.g., SLE): ").strip().upper()
    cursor.execute("SELECT * FROM OPN_TCC_COUNTS WHERE TRUE_COUNTRY_CODE = %s", (true_country_code,))
else:
    cursor.execute("SELECT * FROM OPN_TCC_COUNTS")

countries = cursor.fetchall()

def get_country_name(alpha3):
    try:
        return countries_by_alpha3[alpha3].name
    except:
        return None

# Placeholder function for RSS feed lookup (replace with real search logic)
def find_rss_feeds(country_name, topic):
    # TODO: Replace with real feed discovery logic
    return [
        f"https://example.com/{country_name.lower().replace(' ', '-')}/{topic}/rss",
        f"https://news.example.com/{topic}/{country_name.lower().replace(' ', '-')}.xml"
    ]

for row in countries:
    code = row['TRUE_COUNTRY_CODE']
    name = row['TRUE_COUNTRY_NAME']
    if not name:
        name = get_country_name(code)
        if name:
            cursor.execute("UPDATE OPN_TCC_COUNTS SET TRUE_COUNTRY_NAME = %s WHERE TRUE_COUNTRY_CODE = %s", (name, code))
            conn.commit()
            print(f"\u2705 Updated country name for {code}: {name}")
        else:
            print(f"\u274C Could not resolve country name for {code}")
            continue

    for topic_id, topic in TOPICS.items():
        feeds = find_rss_feeds(name, topic)
        for feed_url in feeds:
            parsed = feedparser.parse(feed_url)
            print(f"🔍 Testing feed for {name} / {topic}: {feed_url}")
            print(f"    ➤ Bozo: {parsed.bozo}, Entries: {len(parsed.entries)}")

            if parsed.bozo:
                continue
            if not parsed.entries:
                continue

            # Check if already exists
            cursor.execute("""
                SELECT 1 FROM OPN_TCC_PARAMS 
                WHERE TRUE_COUNTRY_CODE = %s AND TOPICID = %s AND FEED_URL = %s
            """, (code, topic_id, feed_url))
            if cursor.fetchone():
                continue

            title = parsed.feed.get("title", f"{topic.title()} Feed")
            cursor.execute("""
                INSERT INTO OPN_TCC_PARAMS (TRUE_COUNTRY_CODE, TOPICID, FEED_URL, FEED_NAME, LAST_UPDATED_DTM)
                VALUES (%s, %s, %s, %s, NOW())
            """, (code, topic_id, feed_url, title))
            conn.commit()
            print(f"\u2705 Inserted {topic} feed for {name}: {feed_url}")
            time.sleep(1)

cursor.close()
conn.close()
print("\n\u2705 All done!")
