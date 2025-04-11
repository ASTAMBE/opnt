# populateSFC.py

import requests
from bs4 import BeautifulSoup
from datetime import datetime

# Hardcoded curated sources for GHA with topic-assigned URLs
curated_sources = {
    "GHA": {
        "name": "Ghana",
        "urls": [
            {"url": "https://www.ghanaweb.com/GhanaHomePage/SportsArchive/", "topic": "SPORTS"},
            {"url": "https://www.ghanaweb.com/GhanaHomePage/business/", "topic": "BUSINESS"},
            {"url": "https://www.ghanaweb.com/GhanaHomePage/entertainment/", "topic": "ENTERTAINMENT"}
        ]
    }
}

TOPIC_ID_MAP = {
    "POLITICS": 1,
    "SPORTS": 2,
    "BUSINESS": 4,
    "ENTERTAINMENT": 5,
    "CELEBRITIES": 10
}

def detect_topic_from_text(text, href):
    text = text.lower()
    href = href.lower()

    if any(keyword in text or keyword in href for keyword in ["sport", "football", "soccer"]):
        return "SPORTS"
    elif any(keyword in text or keyword in href for keyword in ["business", "economy", "finance"]):
        return "BUSINESS"
    elif any(keyword in text or keyword in href for keyword in ["entertainment", "music", "movie", "show"]):
        return "ENTERTAINMENT"
    elif any(keyword in text or keyword in href for keyword in ["celebrity", "celeb", "star"]):
        return "CELEBRITIES"
    elif any(keyword in text or keyword in href for keyword in ["politic", "government", "election"]):
        return "POLITICS"
    else:
        return None

def scrape_and_generate_insert():
    today = datetime.today().strftime("%Y-%m-%d")
    insert_statements = []

    for cc, meta in curated_sources.items():
        for entry in meta["urls"]:
            site_url = entry["url"]
            known_topic = entry.get("topic")

            try:
                response = requests.get(site_url, headers={"User-Agent": "Mozilla/5.0"}, timeout=10)
                soup = BeautifulSoup(response.content, "html.parser")

                for a in soup.find_all("a", href=True):
                    href = a["href"]
                    title = a.get_text(strip=True)
                    if not title or len(title) < 20:
                        continue

                    topic = known_topic if known_topic else detect_topic_from_text(title, href)
                    if topic and topic in TOPIC_ID_MAP:
                        full_url = href if href.startswith("http") else site_url.rstrip("/") + "/" + href.lstrip("/")
                        sql = f"""INSERT INTO OPN_SFC_CONTENT \
(TRUE_COUNTRY_CODE, COUNTRY_CODE, TRUE_COUNTRY_NAME, TOPICID, INTEREST, CONTENT_DTM, CONTENT_DATE, CONTENT_TITLE, CONTENT_URL) \
VALUES ('{cc}', 'GGG', '{meta["name"]}', {TOPIC_ID_MAP[topic]}, '{topic}', NOW(), '{today}', \"{title}\", \"{full_url}\");"""
                        insert_statements.append(sql)
                        if len(insert_statements) >= 10:
                            break
            except Exception as e:
                insert_statements.append(f"-- Error fetching {site_url}: {e}")

    return insert_statements

if __name__ == "__main__":
    for stmt in scrape_and_generate_insert():
        print(stmt)
