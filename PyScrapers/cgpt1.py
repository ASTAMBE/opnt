import openai
import mysql.connector
import random
import feedparser
from datetime import datetime

# -----------------------------
# Configuration
# -----------------------------
# OpenAI API Key


# Topic ID Mapping
TOPIC_ID_MAP = {
    "POLITICS": 1,
    "SPORTS": 2,
    "BUSINESS": 4,
    "ENTERTAINMENT": 5,
    "CELEBRITIES": 10
}

# Political Camps Mapping
POLITICAL_CAMPS = {
    "NGA": {"REFORM": "LOVE", "ELITES": "HATE"},
    "IND": {"PROMODI": "LOVE", "ANTIMODI": "HATE"},
    "USA": {"REPUB": "LOVE", "DEM": "HATE"}
}

# Country Name Mapping
COUNTRY_NAME_MAP = {
    "NGA": "Nigeria",
    "IND": "India",
    "USA": "United States"
}


# -----------------------------
# Functions
# -----------------------------

def fetch_parameters_from_db(row_id=None):
    """Fetch country, interest, RSS feeds, and news count parameters from OPN_TCC_PARAMS table."""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
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
        print(f"Fetched {len(params)} rows from OPN_TCC_PARAMS")
        return params
    except mysql.connector.Error as err:
        print(f"Database Connection Error: {err}")
        return []


def fetch_news_from_rss(feed_urls, num_topics_per_feed):
    """Fetch latest news articles from multiple RSS feeds, distributing the load across them."""
    articles = []
    total_articles = 0
    num_feeds = len([url for url in feed_urls if url])
    if num_feeds == 0:
        return []

    articles_per_feed = num_topics_per_feed  # Distribute evenly across feeds
    remaining_articles = num_topics_per_feed % num_feeds  # Distribute any leftovers

    for feed_url in feed_urls:
        if feed_url:
            try:
                feed = feedparser.parse(feed_url)
                count = num_topics_per_feed  # Distribute extra items evenly
                articles.extend([(entry.title, entry.link) for entry in feed.entries[:count]])
                if total_articles >= (num_topics_per_feed * len(feed_urls)):
                    break
            except Exception as e:
                print(f"Error fetching RSS feed {feed_url}: {e}")

    return articles[:num_topics_per_feed]
    """Fetch latest news articles from the RSS feeds provided."""
    articles = []
    for feed_url in feed_urls:
        if feed_url:
            try:
                feed = feedparser.parse(feed_url)
                for entry in feed.entries[:num_topics_per_feed]:
                    articles.append((entry.title, entry.link))
                if len(articles) >= num_topics_per_feed:
                    break
            except Exception as e:
                print(f"Error fetching RSS feed {feed_url}: {e}")
    return articles[:num_topics_per_feed]


def generate_debatable_statement(news_title, true_country_name):
    """Reword a news title into a debate-driven statement using OpenAI."""
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
    """Generate a user comment based on sentiment."""
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
    """Ask user if they want to process all rows or just a specific row from OPN_TCC_PARAMS."""
    user_choice = input("Run for all rows in OPN_TCC_PARAMS? (yes/no): ").strip().lower()
    if user_choice == "no":
        row_id = input("Enter ROW_ID to run for a specific row: ").strip()
        if not row_id.isdigit():
            print("Invalid ROW_ID. Exiting.")
            return
        params = fetch_parameters_from_db(row_id=int(row_id))
    else:
        params = fetch_parameters_from_db()

    if not params:
        print("No parameters found in OPN_TCC_PARAMS table.")
        return

    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
    except mysql.connector.Error as err:
        print(f"Database Connection Error: {err}")
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
            country_code, true_country_code, true_country_name, interest, topic_id, topic, content_camp, content_tone,
            comment1_tone, comment1_text, comment1_camp, comment2_tone, comment2_text, comment2_camp, news_url)

            try:
                cursor.execute(sql_query, values)
                conn.commit()
                processed_count += 1
            except mysql.connector.Error as err:
                print(f"Error inserting data: {err}")

    cursor.close()
    conn.close()
    print(f"Successfully processed {processed_count} discussion topics.")


if __name__ == "__main__":
    process_and_store_discussion_topics()