import os
import feedparser
from iso3166 import countries_by_alpha3
from dotenv import load_dotenv
from urllib.parse import quote

# --- Load environment variables ---
load_dotenv("C:\\AST\\GitHub\\set_env.env")

# --- Fixed test input ---
country_code = "GHA"
topic = "sports"

try:
    country_name = countries_by_alpha3[country_code].name
except KeyError:
    print(f"❌ Invalid country code: {country_code}")
    exit()

print(f"\n🌍 Testing Part 3A: RSS Discovery for {country_code} ({country_name}) — Topic: {topic}")


# --- RSS Feed Discovery (placeholder logic) ---
def search_rss_feeds(country_name, topic):
    query = f"{country_name} {topic} RSS feed"
    print(f"🔍 Would search for: {query}")

    # ❗️ Replace with real search logic later
    # Temporary mock: 2 fake + 1 real RSS (for testing)
    return [
        "https://rss.nytimes.com/services/xml/rss/nyt/Sports.xml",  # Valid
        "https://example.com/invalid-feed.xml"  # Invalid
    ]


# --- Feed validation ---
def validate_rss(feed_url):
    try:
        parsed = feedparser.parse(feed_url)
        if parsed.bozo:
            return False
        return len(parsed.entries) > 0
    except Exception:
        return False


# --- Run discovery and validation ---
discovered_feeds = search_rss_feeds(country_name, topic)
valid_feeds = []

for url in discovered_feeds:
    print(f"\n🔗 Checking feed: {url}")
    if validate_rss(url):
        print(f"✅ Valid RSS feed with entries!")
        valid_feeds.append(url)
    else:
        print(f"❌ Invalid or empty feed.")

# --- Output results ---
if valid_feeds:
    print(f"\n✅ Final valid feeds (max 2):")
    for i, url in enumerate(valid_feeds[:2], 1):
        print(f"  FEED{i}: {url} (Type: RSS)")
else:
    print("\n🛑 No valid RSS feeds found — fallback to website needed (Part 3B)")
