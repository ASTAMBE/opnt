import os
import requests
import pandas as pd
from iso3166 import countries_by_alpha3
from dotenv import load_dotenv
import openai

# Load environment variables
load_dotenv("C:\\AST\\GitHub\\set_env.env")
NEWS_API_KEY = os.getenv("NEWSAPI_KEY")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
openai.api_key = OPENAI_API_KEY

# Input parameters
country_code = input("Enter TRUE_COUNTRY_CODE (e.g., GHA): ").strip().upper()
topic_input = input("Enter topic (e.g., politics, celebrities, sports, business, entertainment): ").strip().lower()

# Resolve country name from code
try:
    country_name = countries_by_alpha3[country_code].name
except KeyError:
    print(f"❌ Invalid country code: {country_code}")
    exit()

# Function to fetch headlines using NewsAPI
def get_newsapi_headlines(country_code, topic, max_results=10):
    url = "https://newsapi.org/v2/top-headlines"
    params = {
        "apiKey": NEWS_API_KEY,
        "pageSize": max_results,
        "language": "en",
        "country": country_code[:2].lower()
    }

    if topic in ["sports", "business", "entertainment"]:
        params["category"] = topic
    elif topic in ["politics", "celebrities"]:
        params["category"] = "general"
    else:
        print(f"❌ Unsupported topic: {topic}")
        return []

    try:
        res = requests.get(url, params=params)
        res.raise_for_status()
        articles = res.json().get("articles", [])
        return [(a['title'], a['url']) for a in articles if a.get('title') and a.get('url')]
    except Exception as e:
        print(f"❌ Error fetching from NewsAPI: {e}")
        return []

# Function to classify topic using OpenAI (only for general category)
def classify_topic(text):
    prompt = (
        "Categorize the following news headline as either 'politics', 'celebrities', or 'none'. "
        "Only respond with one of those three words.\n\n"
        f"Headline: {text}\nCategory:"
    )
    try:
        response = openai.Completion.create(
            engine="gpt-3.5-turbo-instruct",
            prompt=prompt,
            max_tokens=1,
            temperature=0
        )
        category = response.choices[0].text.strip().lower()
        return category if category in ["politics", "celebrities"] else "none"
    except Exception as e:
        print(f"❌ OpenAI error: {e}")
        return "none"

# Fetch and classify
raw_headlines = get_newsapi_headlines(country_code, topic_input)
classified = []

for title, url in raw_headlines:
    if topic_input in ["politics", "celebrities"]:
        category = classify_topic(title)
        if category != "none":
            classified.append({
                "COUNTRY_CODE": country_code,
                "TOPIC": category.capitalize(),
                "DISCUSSION_ITEM": title,
                "NEWS_URL": url
            })
    else:
        classified.append({
            "COUNTRY_CODE": country_code,
            "TOPIC": topic_input.capitalize(),
            "DISCUSSION_ITEM": title,
            "NEWS_URL": url
        })

# Display results
df = pd.DataFrame(classified)

if not df.empty:
    print("\n\u2705 Discussion items:")
    print(df.to_markdown(index=False))
else:
    print("\n⚠️ No relevant discussion items found.")
