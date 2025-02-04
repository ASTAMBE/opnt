import feedparser
import openai
import mysql.connector
import random
from datetime import datetime

# -----------------------------
# Configuration
# -----------------------------
# Set your OpenAI API Key
openai.api_key = "your_openai_api_key_here"

# MySQL Database Connection Parameters
DB_CONFIG = {
    "host": "your_mysql_host",
    "user": "your_mysql_user",
    "password": "your_mysql_password",
    "database": "your_database_name",
}

# -----------------------------
# Functions
# -----------------------------
def generate_discussion_title(original_title, description):
    """
    Reword the original news title and description into a discussion-oriented statement 
    that invites either agreement or disagreement.
    """
    prompt = f"""Reword the following news title and description into a discussion-oriented statement that invites both agreement and disagreement.

Original Title: {original_title}
Description: {description}

Please provide only the reworded title, a statement that can be interpreted either positively or negatively.
Example:
- For "Dangote refinery to start fuel production next month", a possible statement: "Dangote refinery's fuel production will solve Nigeria’s fuel crisis."
- For "Nigeria's plan to boost delta drilling sparks anger", a possible statement: "Reviving oil drilling in the Niger Delta will help Nigeria’s economy."

Reworded Title:"""
    
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=50,
        temperature=0.7,
    )
    return response["choices"][0]["message"]["content"].strip()

def generate_comment(news_title, description, sentiment):
    """
    Generate a user comment for the given news item and sentiment.
    Randomly, some comments will include minor grammatical errors to mimic lower language proficiency.
    """
    # Randomly decide whether to introduce grammatical errors (approx. 33% chance)
    introduce_errors = random.choice([True, False, False])
    error_instruction = ""
    if introduce_errors:
        error_instruction = ("Include some minor grammatical errors, such as missing articles, "
                             "incorrect verb tenses, or awkward phrasing, to mimic a user with lower language proficiency.")
    
    prompt = f"""Write a user comment on the following news item based on the given sentiment.

News Title: {news_title}
Description: {description}
Sentiment: {sentiment}
{error_instruction}

Example:
- Correct: "This is a fantastic development for the country! It will improve our economy and create jobs."
- With errors: "This great move, Nigeria need this kind of progress. Hope it work well for people."

Provide only the comment."""
    
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=100,
        temperature=0.7,
    )
    return response["choices"][0]["message"]["content"].strip()

def process_and_store_news(country_code, interest_code, num_items):
    """
    Fetch news from the Premium Times RSS feed, process each item to generate a discussion-oriented title and two comments,
    and insert the data into the MySQL table OPN_SFC_CONTENT.
    """
    feed_url = "https://www.premiumtimesng.com/feed"
    feed = feedparser.parse(feed_url)
    
    # Connect to MySQL database
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
    except mysql.connector.Error as err:
        print(f"Database Connection Error: {err}")
        return
    
    processed_count = 0
    
    for entry in feed.entries:
        if processed_count >= num_items:
            break
        
        # Extract data from the feed entry
        original_title = entry.title
        description = entry.description
        published_time = datetime(*entry.published_parsed[:6])
        news_url = entry.link
        
        # Generate a discussion-oriented title using GPT-3.5-turbo
        discussion_title = generate_discussion_title(original_title, description)
        
        # Randomly choose the initial sentiment for this news item (either LOVE or HATE)
        initial_sentiment = random.choice(["LOVE", "HATE"])
        
        # Generate two comments:
        # Comment 1 uses the initial sentiment.
        comment1 = generate_comment(discussion_title, description, initial_sentiment)
        # Comment 2 uses the opposite sentiment.
        opposite_sentiment = "HATE" if initial_sentiment == "LOVE" else "LOVE"
        comment2 = generate_comment(discussion_title, description, opposite_sentiment)
        
        # Create the SQL INSERT statement
        sql_query = f"""
            INSERT INTO OPN_SFC_CONTENT 
            (COUNTRY_CODE, NEWS_DATE, INTEREST_CODE, NEWS_TITLE, NEWS_SENTIMENT, 
             COMMENT1_SENTIMENT, COMMENT_1, COMMENT2_SENTIMENT, COMMENT_2, NEWS_URL)
            VALUES 
            ('{country_code}', '{published_time.strftime("%Y-%m-%d %H:%M:%S")}', '{interest_code}', 
             '{discussion_title}', '{initial_sentiment}', '{initial_sentiment}', '{comment1}', 
             '{opposite_sentiment}', '{comment2}', '{news_url}');
        """
        
        # Execute the SQL query
        try:
            cursor.execute(sql_query)
            conn.commit()
            processed_count += 1
            print(f"Inserted news item: {discussion_title}")
        except mysql.connector.Error as err:
            print(f"Error inserting data: {err}")
    
    cursor.close()
    conn.close()
    print(f"Successfully processed {processed_count} news items.")

# -----------------------------
# Main Execution
# -----------------------------
if __name__ == "__main__":
    # Parameters: COUNTRY_CODE is "NGA", INTEREST_CODE is "POLITICS", and num_items is how many news items to process.
    process_and_store_news(country_code="NGA", interest_code="POLITICS", num_items=5)
