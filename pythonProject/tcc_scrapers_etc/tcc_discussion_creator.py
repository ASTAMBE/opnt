import os
import openai
import mysql.connector
import random
import feedparser
import logging
from datetime import datetime
from dotenv import load_dotenv
import json

# Load environment variables
load_dotenv("C:\\AST\\GitHub\\set_env.env")

# Set up logging
logging.basicConfig(
    level=logging.ERROR,  # Change to WARNING to suppress INFO logs
    format='[%(asctime)s] %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("discussion_topic_loader.log"),
        logging.StreamHandler()
    ]
)

client = openai.Client(api_key=os.getenv("OPENAI_API_KEY"))

DB_CONFIGS = {
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

TOPIC_ID_MAP = {"POLITICS": 1, "SPORTS": 2, "BUSINESS": 4, "ENTERTAINMENT": 5, "CELEBRITIES": 10}
POLITICAL_CAMPS = {
    "NGA": {"REFORM", "ELITES"},
    "IND": {"PROMODI", "ANTIMODI"},
    "USA": {"REPUB", "DEM"},
    "GHA": {"REFORM", "ELITES"},
    "KEN": {"AZIMIO", "UDA"},
    "PAK": {"ISLAMIST", "MODERN"},
}
COUNTRY_NAME_MAP = {"NGA": "Nigeria", "IND": "India", "USA": "United States", "GHA": "Ghana"}

def fetch_parameters_from_db(row_id=None, db_config=None):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        query = "SELECT ROW_ID, COUNTRY_CODE, TRUE_COUNTRY_CODE, INTEREST, NEWS_COUNT_PER_RUN, FEED_URL1, FEED_URL2, FEED_URL3 FROM OPN_TCC_PARAMS"
        if row_id:
            query += " WHERE ROW_ID = %s"
            cursor.execute(query, (row_id,))
        else:
            cursor.execute(query)
        results = cursor.fetchall()
        cursor.close()
        conn.close()
        return results
    except mysql.connector.Error as err:
        logging.error(f"Database Connection Error: {err}")
        return []

def fetch_news_from_rss(feed_urls, num_topics_per_feed):
    articles = []
    for feed_url in feed_urls:
        if feed_url:
            local_processed = 0
            local_skipped = 0
            try:
                feed = feedparser.parse(feed_url)
                feed_articles = [(entry.title, entry.link) for entry in feed.entries[:num_topics_per_feed]]
                articles.extend(feed_articles)

                for title, _ in feed_articles:
                    assessment = assess_news_item_for_discussion(title, "", "")
                    if assessment.get("status") == "PROCEED":
                        local_processed += 1
                    else:
                        local_skipped += 1

                print(f"Completed processing: {feed_url} → {local_processed} items converted, {local_skipped} items discarded.")
            except Exception as e:
                logging.warning(f"Error fetching RSS feed {feed_url}: {e}")
    return articles

def assess_news_item_for_discussion(headline, country_name, topic):
    prompt = f"""
You are an editorial assistant helping assess whether a news item is suitable for public discourse in {country_name} under the topic '{topic}'.

Headline: {headline}

Classify it into one of the following categories:
- SKIP: Not interesting, irrelevant, or unlikely to provoke any discussion
- POLITICAL: Likely to provoke strong opposing views among ideological camps
- UNIVERSAL_LOVE: Celebratory news (e.g. awards, births, national wins) that most would love
- UNIVERSAL_HATE: Tragic or horrific news (e.g. deaths, terrorism) that most would hate
- GRAY: Discussion-worthy but not necessarily polarizing

Respond strictly in this JSON format:
{{"status": "PROCEED" or "SKIP", "category": "POLITICAL" | "UNIVERSAL_LOVE" | "UNIVERSAL_HATE" | "GRAY", "reason": "one-sentence justification"}}
"""
    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=200,
            temperature=0.5,
        )
        return json.loads(response.choices[0].message.content.strip())
    except Exception as e:
        logging.error(f"Error assessing news item: {e}")
        return {"status": "SKIP", "category": "SKIP", "reason": "Exception raised"}

def is_news_politically_interpretable(statement, topic, country):
    prompt = f"""
The following statement was generated from a news article under the topic '{topic}' in {country}:

"{statement}"

Can this statement be reasonably interpreted through a political lens by people in {country} — meaning, would people's opinions about it likely vary depending on their political camp?

In {country}, even topics such as economic reports, development achievements, nationalistic events, or failures in public service often evoke politically divided reactions. For example:
- Praise for economic growth may be embraced by ruling party supporters and doubted by opposition.
- Cultural or celebrity achievements may sometimes align with ideological narratives.

Respond with "YES" or "NO" only.
"""
    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=10,
            temperature=0.3,
        )
        return response.choices[0].message.content.strip().upper() == "YES"
    except Exception as e:
        logging.warning(f"Could not determine political interpretability: {e}")
        return False

def infer_camp_for_statement(statement, tone, camps, country):
    prompt = f"""
Given this statement:
'{statement}'

Assume a person feels '{tone}' toward it. Which of the following political camps from {country} is most likely to hold that view?
Camps: {list(camps)}

Respond with only the camp name.
"""
    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=20,
            temperature=0.3,
        )
        camp = response.choices[0].message.content.strip().upper()
        if camp not in camps:
            logging.warning(f"GPT returned invalid camp '{camp}'. Falling back to random from {camps}.")
            camp = random.choice(list(camps))
        return camp
    except Exception as e:
        logging.warning(f"Camp inference failed: {e}")
        return random.choice(list(camps))

def generate_debatable_statement(news_title, true_country_name):
    prompt = f"""
Rewrite the following news headline as a strongly opinionated, assertive, and emotionally charged statement that would spark disagreement or support from different people in {true_country_name}. 

Avoid phrasing it as a question. Take a clear stance either in support or against the implication of the headline. Do not include ambiguity or neutrality.

Headline: {news_title}
"""
    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=100,
            temperature=0.8,
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        logging.error(f"Error generating debatable statement: {e}")
        return news_title

def generate_comment(statement, sentiment, country_code, true_country_name):
    prompt = f"""
Write a {'detailed' if sentiment == 'HATE' else 'short'} user comment that expresses {sentiment.lower()} towards the statement: '{statement}'.
Ensure the comment is realistic, relevant to {true_country_name}, and does not reference foreign figures unless explicitly mentioned in the topic.
If the country is '{country_code}', consider using minor grammatical errors or informal phrasing to mimic regional speech patterns.
"""
    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=150,
            temperature=0.7,
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        logging.error(f"Error generating comment: {e}")
        return "[Comment generation failed]"

def process_and_store_discussion_topics():
    user_choice = input("Run for all rows in OPN_TCC_PARAMS? (yes/no): ").strip().lower()
    if user_choice == "no":
        row_id = input("Enter ROW_ID to run for a specific row: ").strip()
        if not row_id.isdigit():
            logging.error("Invalid ROW_ID. Exiting.")
            return
        params = fetch_parameters_from_db(row_id=int(row_id), db_config=DB_CONFIGS["DEV"])
    else:
        params = fetch_parameters_from_db(db_config=DB_CONFIGS["DEV"])

    if not params:
        logging.warning("No parameters found in OPN_TCC_PARAMS table.")
        return

    connections = {env: mysql.connector.connect(**DB_CONFIGS[env]) for env in DB_CONFIGS}
    cursors = {env: connections[env].cursor() for env in DB_CONFIGS}
    processed_count = 0
    skipped_count = 0
    total_items_examined = 0

    for param in params:
        country_code = param["COUNTRY_CODE"]
        true_country_code = param["TRUE_COUNTRY_CODE"]
        interest = param["INTEREST"]
        num_topics_per_feed = param["NEWS_COUNT_PER_RUN"]
        true_country_name = COUNTRY_NAME_MAP.get(true_country_code, true_country_code)
        topic_id = TOPIC_ID_MAP.get(interest)
        feed_urls = [param["FEED_URL1"], param["FEED_URL2"], param["FEED_URL3"]]

        news_articles = fetch_news_from_rss(feed_urls, num_topics_per_feed)

        for news_title, news_url in news_articles:
            total_items_examined += 1
            assessment = assess_news_item_for_discussion(news_title, true_country_name, interest)
            if assessment.get("status") != "PROCEED":
                skipped_count += 1
                continue

            category = assessment["category"]
            topic = generate_debatable_statement(news_title, true_country_name)
            content_tone = random.choice(["LOVE", "HATE"])
            camps = POLITICAL_CAMPS.get(true_country_code, {"NEUTRAL"})

            if category == "POLITICAL":
                content_camp = infer_camp_for_statement(topic, content_tone, camps, true_country_name)
                comment1_camp = content_camp
                comment2_camp = random.choice(list(camps - {content_camp})) if len(camps) > 1 else content_camp
            elif category in ["UNIVERSAL_LOVE", "UNIVERSAL_HATE"]:
                content_tone = "LOVE" if category == "UNIVERSAL_LOVE" else "HATE"
                content_camp = random.choice(list(camps))
                comment1_camp = random.choice(list(camps))
                comment2_camp = random.choice(list(camps))
            elif category == "GRAY":
                if is_news_politically_interpretable(topic, interest, true_country_name):
                    content_camp = infer_camp_for_statement(topic, content_tone, camps, true_country_name)
                    comment1_camp = content_camp
                    comment2_camp = random.choice(list(camps - {content_camp})) if len(camps) > 1 else content_camp
                else:
                    content_camp = random.choice(list(camps))
                    comment1_camp = random.choice(list(camps))
                    comment2_camp = random.choice(list(camps))

            comment1_tone = content_tone
            comment1_text = generate_comment(topic, comment1_tone, true_country_code, true_country_name)

            comment2_tone = "HATE" if content_tone == "LOVE" else "LOVE"
            comment2_text = generate_comment(topic, comment2_tone, true_country_code, true_country_name)

            sql_query = """
                INSERT INTO OPN_SFC_CONTENT 
                (COUNTRY_CODE, TRUE_COUNTRY_CODE, TRUE_COUNTRY_NAME, CONTENT_DTM, CONTENT_DATE, INTEREST, TOPICID, CONTENT_TITLE, CONTENT_CAMP, CONTENT_TONE, COMMENT1_TONE, COMMENT1_TEXT, COMMENT1_CAMP, COMMENT2_TONE, COMMENT2_TEXT, COMMENT2_CAMP, CONTENT_URL)
                VALUES 
                (%s, %s, %s, NOW(), CURDATE(), %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
            """
            values = (
                country_code, true_country_code, true_country_name, interest, topic_id, topic, content_camp,
                content_tone, comment1_tone, comment1_text, comment1_camp,
                comment2_tone, comment2_text, comment2_camp, news_url
            )

            for env in ["DEV", "PROD"]:
                try:
                    cursors[env].execute(sql_query, values)
                    connections[env].commit()
                except mysql.connector.Error as err:
                    logging.error(f"[{env}] Error inserting data: {err}")

            processed_count += 1

    for env in cursors:
        cursors[env].close()
        connections[env].close()
    print(f"Total news items examined: {total_items_examined}")
    print(f"Discussion-worthy items inserted: {processed_count}")
    print(f"Items skipped (not important): {skipped_count}")

if __name__ == "__main__":
    print("Launching discussion topic loader...")
    process_and_store_discussion_topics()
