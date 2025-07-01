import requests
import feedparser
from bs4 import BeautifulSoup
import re
from collections import defaultdict

# Mapping from topic keywords to your topic IDs
TOPIC_KEYWORDS = {
    "politics": 1,
    "sports": 2,
    "business": 4,
    "entertainment": 5,
    "celebrities": 10,
}

# GitHub raw README.md URL
GHANA_FEEDS_URL = "https://raw.githubusercontent.com/yavuz/news-feed-list-of-countries/master/README.md"

def categorize_feed(url, title):
    """Attempt to categorize feed based on URL or title"""
    combined = f"{url} {title}".lower()
    for keyword, topic_id in TOPIC_KEYWORDS.items():
        if keyword in combined:
            return keyword, topic_id
    return None, None

def get_ghana_feeds():
    """Scrape the GitHub HTML and extract RSS feed URLs under the Ghana section."""
    url = "https://github.com/yavuz/news-feed-list-of-countries"
    response = requests.get(url)
    soup = BeautifulSoup(response.text, "html.parser")

    feed_urls = []
    ghana_start = None

    # Step 1: Find the heading with text "Ghana"
    for h3 in soup.find_all("h3"):
        if "Ghana" in h3.get_text(strip=True):
            ghana_start = h3
            break

    if not ghana_start:
        print("❌ Ghana section header not found.")
        return []

    # Step 2: Collect links until the next h3 (next country)
    for sibling in ghana_start.find_next_siblings():
        if sibling.name == "h3":
            break  # End of Ghana section
        for a in sibling.find_all("a", href=True):
            href = a['href'].strip()
            if href.startswith("http"):
                feed_urls.append(href)

    print(f"✅ Found {len(feed_urls)} RSS URLs.")
    return feed_urls


def validate_and_categorize(feeds):
    """Check feeds for availability and categorize them"""
    categorized = defaultdict(list)
    for url in feeds:
        try:
            parsed = feedparser.parse(url)
            if parsed.bozo or not parsed.entries:
                continue
            title = parsed.feed.get("title", "")
            topic, topic_id = categorize_feed(url, title)
            if topic and len(categorized[topic]) < 3:
                categorized[topic].append(url)
        except Exception:
            continue
    return categorized

def generate_sql_statements(categorized_feeds):
    """Build SQL statements per topic"""
    statements = []
    for topic, feeds in categorized_feeds.items():
        topic_id = TOPIC_KEYWORDS[topic]
        interest_upper = topic.upper()
        # Pad feeds to always have 3 slots
        padded = feeds + [""] * (3 - len(feeds))
        sql = f"""
INSERT INTO OPN_TCC_PARAMS (
    TRUE_COUNTRY_CODE, COUNTRY_CODE, COUNTRY_NAME, INTEREST, TOPICID,
    FEED_URL1, FEED_URL2, FEED_URL3,
    FEED1_TYPE, FEED2_TYPE, FEED3_TYPE,
    NEWS_COUNT_PER_RUN
)
VALUES (
    'GHA', 'GGG', 'Ghana', '{interest_upper}', {topic_id},
    '{padded[0]}', '{padded[1]}', '{padded[2]}',
    'rss', 'rss', 'rss',
    5
)
ON DUPLICATE KEY UPDATE
    FEED_URL1 = VALUES(FEED_URL1),
    FEED_URL2 = VALUES(FEED_URL2),
    FEED_URL3 = VALUES(FEED_URL3),
    FEED1_TYPE = VALUES(FEED1_TYPE),
    FEED2_TYPE = VALUES(FEED2_TYPE),
    FEED3_TYPE = VALUES(FEED3_TYPE),
    NEWS_COUNT_PER_RUN = VALUES(NEWS_COUNT_PER_RUN);
""".strip()
        statements.append((interest_upper, sql))
    return statements

if __name__ == "__main__":
    print("🔍 Fetching Ghana RSS feeds...")
    feeds = get_ghana_feeds()
    print(f"✅ Found {len(feeds)} RSS URLs.")

    print("🧪 Checking which feeds are live and categorizing them...")
    categorized = validate_and_categorize(feeds)

    print("📦 Generating SQL insert/update statements:")
    sqls = generate_sql_statements(categorized)
    for topic, sql in sqls:
        print(f"\n--- Topic: {topic} ---")
        print(sql)
