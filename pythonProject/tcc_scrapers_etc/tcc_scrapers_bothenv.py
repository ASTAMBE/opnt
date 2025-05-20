import os
import openai
import mysql.connector
import random
import feedparser
import logging
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
load_dotenv("C:\\AST\\GitHub\\set_env.env")

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("discussion_topic_loader.log"),
        logging.StreamHandler()
    ]
)

# OpenAI API Client
client = openai.Client(api_key=os.getenv("OPENAI_API_KEY"))

# DB configurations
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

# Use both DBs
DB_CONFIGS = {
    "DEV": db_config["DEV"],
    "PROD": db_config["PROD"]
}

# Topic and Country Mappings
TOPIC_ID_MAP = {
    "POLITICS": 1,
    "SPORTS": 2,
    "BUSINESS": 4,
    "ENTERTAINMENT": 5,
    "CELEBRITIES": 10
}

POLITICAL_CAMPS = {
    "NGA": {"REFORM": "LOVE", "ELITES": "HATE"},
    "IND": {"PROMODI": "LOVE", "ANTIMODI": "HATE"},
    "USA": {"REPUB": "LOVE", "DEM": "HATE"}
}

COUNTRY_NAME_MAP = {
    "NGA": "Nigeria",
    "IND": "India",
    "USA": "United States"
}


def fetch_parameters_from_db(row_id=None, db_config=None):
    if db_config is None:
        logging.error("Missing DB config.")
        return []

    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        query = "SELECT ROW_ID, COUNTRY_CODE, TRUE_COUNTRY_CODE, INTEREST, NEWS_COUNT_PER_RUN, FEED_URL1, FEED_URL2, FEED_URL3 FROM OPN_TCC_PARAMS"
        if row_id:
            query += " WHERE ROW_ID = %s"
            cursor.execute(query, (row_id,))
        else:
            cursor.execute(query)
        params = cursor.fetchall()
        cursor.close()
        conn.close()
        # logging.info(f"Fetched {len(params)} rows from OPN_TCC_PARAMS")
        return params
    except mysql.connector.Error as err:
        logging.error(f"Database Connection Error: {err}")
        return []


def fetch_news_from_rss(feed_urls, num_topics_per_feed):
    articles = []
    for feed_url in feed_urls:
        if feed_url:
            try:
                feed = feedparser.parse(feed_url)
                fetched_articles = [(entry.title, entry.link) for entry in feed.entries[:num_topics_per_feed]]
                articles.extend(fetched_articles)
                #logging.info(f"Fetched {len(fetched_articles)} articles from {feed_url}")
            except Exception as e:
                logging.warning(f"Error fetching RSS feed {feed_url}: {e}")
    return articles


def generate_debatable_statement(news_title, true_country_name):
    prompt = f"""Rewrite the following news headline as a debatable opinionated statement that evokes strong agreement or disagreement. 
Ensure the topic is relevant to {true_country_name} and does not reference unrelated figures or foreign celebrities:
{news_title}"""

    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=100,
        temperature=0.8,
    )
    return response.choices[0].message.content.strip()


def generate_comment(statement, sentiment, country_code, true_country_name):
    prompt = f"""Write a {'detailed' if sentiment == 'HATE' else 'short'} user comment that expresses {sentiment.lower()} towards the statement: '{statement}'.
Ensure the comment is realistic, relevant to {true_country_name}, and does not reference foreign figures unless explicitly mentioned in the topic.
If the country is '{country_code}', consider using minor grammatical errors or informal phrasing to mimic regional speech patterns."""
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=150,
        temperature=0.7,
    )
    return response.choices[0].message.content.strip()


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

    connections = {}
    cursors = {}

    try:
        for env in DB_CONFIGS:
            connections[env] = mysql.connector.connect(**DB_CONFIGS[env])
            cursors[env] = connections[env].cursor()
            #logging.info(f"Connected to {env} database.")
    except mysql.connector.Error as err:
        logging.error(f"Database Connection Error: {err}")
        return

    processed_count = 0

    for param in params:
        country_code = param["COUNTRY_CODE"]
        true_country_code = param["TRUE_COUNTRY_CODE"]
        interest = param["INTEREST"]
        num_topics_per_feed = param["NEWS_COUNT_PER_RUN"]
        true_country_name = COUNTRY_NAME_MAP.get(true_country_code, true_country_code)
        topic_id = TOPIC_ID_MAP.get(interest, None)
        feed_urls = [param["FEED_URL1"], param["FEED_URL2"], param["FEED_URL3"]]

        news_articles = fetch_news_from_rss(feed_urls, num_topics_per_feed)

        for news_title, news_url in news_articles:
            topic = generate_debatable_statement(news_title, true_country_name)
            content_tone = random.choice(["LOVE", "HATE"])
            content_camp = next(
                (camp for camp, tone in POLITICAL_CAMPS.get(true_country_code, {}).items() if tone == content_tone),
                "UNKNOWN")
            comment1_text = generate_comment(topic, content_tone, true_country_code, true_country_name)
            comment1_tone = content_tone
            comment1_camp = content_camp
            comment2_tone = "HATE" if content_tone == "LOVE" else "LOVE"
            comment2_camp = next(
                (camp for camp, tone in POLITICAL_CAMPS.get(true_country_code, {}).items() if tone == comment2_tone),
                "UNKNOWN")
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
                comment2_tone, comment2_text, comment2_camp, news_url)

            for env in ["DEV", "PROD"]:
                try:
                    cursors[env].execute(sql_query, values)
                    connections[env].commit()
                    #logging.info(f"[{env}] Inserted discussion topic for '{true_country_name}' under '{interest}'.")
                except mysql.connector.Error as err:
                    logging.error(f"[{env}] Error inserting data: {err}")

            processed_count += 1

    for env in cursors:
        cursors[env].close()
        connections[env].close()
        logging.info(f"Closed {env} DB connection.")

    logging.info(f"Successfully processed and inserted {processed_count} discussion topics into both DEV and PROD.")


if __name__ == "__main__":
    process_and_store_discussion_topics()
