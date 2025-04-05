import os
import requests
from dotenv import load_dotenv
from pathlib import Path

# Load environment variables
env_file = Path("C:\\AST\\GitHub\\set_env.env")
print(f"🔍 Env file exists: {env_file.exists()}")
load_dotenv(env_file)

# NOW read the key
NEWS_API_KEY = os.getenv("NEWSAPI_KEY")
print(f"🔑 NEWSAPI_KEY loaded as: {NEWS_API_KEY}")

def test_newsapi_key():
    url = "https://newsapi.org/v2/top-headlines"
    params = {
        "apiKey": NEWS_API_KEY,
        "country": "us",
        "category": "sports",
        "pageSize": 5
    }

    try:
        print(f"API Key: {NEWS_API_KEY}")
        print(f"Calling NewsAPI with params: {params}")

        res = requests.get(url, params=params)
        res.raise_for_status()
        articles = res.json().get("articles", [])
        print(f"✅ NewsAPI key is working. Fetched {len(articles)} articles.")
        for i, article in enumerate(articles, 1):
            print(f"{i}. {article.get('title')} ({article.get('url')})")
    except Exception as e:
        print(f"❌ NewsAPI error: {e}")

test_newsapi_key()
