import requests
from bs4 import BeautifulSoup
import pandas as pd
from iso3166 import countries_by_alpha3

# Input parameters
country_code = input("Enter TRUE_COUNTRY_CODE (e.g., GHA): ").strip().upper()
topic = input("Enter topic (e.g., entertainment): ").strip().lower()

# Resolve country name from code
try:
    country_name = countries_by_alpha3[country_code].name
except KeyError:
    print(f"❌ Invalid country code: {country_code}")
    exit()

# Function to get Google News headlines
def get_google_news_headlines(country, topic, max_results=5):
    query = f"{country} {topic} site:news.google.com"
    headers = {
        "User-Agent": "Mozilla/5.0"
    }
    url = f"https://www.google.com/search?q={query.replace(' ', '+')}&hl=en"
    try:
        res = requests.get(url, headers=headers)
        soup = BeautifulSoup(res.text, "html.parser")

        results = []
        for g in soup.find_all('div', class_='Gx5Zad fP1Qef xpd EtOod pkphOe')[:max_results]:
            title_tag = g.find('h3')
            link_tag = g.find('a', href=True)
            if title_tag and link_tag:
                title = title_tag.text.strip()
                url = link_tag['href']
                results.append((title, url))

        return results
    except Exception as e:
        print(f"❌ Error fetching headlines: {e}")
        return []

# Fetch discussion items
headlines = get_google_news_headlines(country_name, topic)

# Prepare results table
df = pd.DataFrame([
    {
        "COUNTRY_CODE": country_code,
        "TOPIC": topic.capitalize(),
        "DISCUSSION_ITEM": title,
        "NEWS_URL": url
    }
    for title, url in headlines
])

if not df.empty:
    print("\n\u2705 Top discussion items found:")
    print(df.to_markdown(index=False))
else:
    print("\n⚠️ No discussion items found.")
