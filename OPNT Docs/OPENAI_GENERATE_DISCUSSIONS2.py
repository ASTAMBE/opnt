import feedparser
import openai
import mysql.connector
import random
from datetime import datetime
import argparse

# -----------------------------
# Configuration- adding ast comment
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

Reworded Title:"""
    
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=50,
        temperature=0.7,
    )
    return response["choices"][0]["message"]["content"].strip()

def process_news_with_gpt(news_title, description):
    """
    Classify whether the news favors Reformists or Elites and generate aligned and opposing comments.
    """
    prompt = f"""
    Given the following Nigerian political news headline: "{news_title}", classify whether it would be viewed favorably by 'Reformists' or 'Elites'. 
    Also, generate two comments: one that aligns with the viewpoint and one that opposes it.
    Return the classification, positive comment, and negative comment in this format:
    TITLE_CAMP: [Reformists or Elites]
    COMMENT_1: [Positive comment]
    COMMENT_2: [Negative comment]
    """
    
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "system", "content": "You are a political analyst."},
                  {"role": "user", "content": prompt}],
        max_tokens=100,
        temperature=0.7,
    )
    
    result = response["choices"][0]["message"]["content"].strip()
    lines = result.split("\n")
    title_camp = lines[0].split(": ")[1]
    comment_1 = lines[1].split(": ")[1]
    comment_2 = lines[2].split(": ")[1]
    
    comment_1_camp = title_camp
    comment_2_camp = "Reformists" if title_camp == "Elites" else "Elites"
    
    return title_camp, comment_1, comment_1_camp, comment_2, comment_2_camp

def process_and_store_news(country_code, interest_code, num_items):
    """
    Fetch news from Premium Times RSS feed, process and classify each item using GPT-3.5, and insert into MySQL.
    """
    feed_url = "https://www.premiumtimesng.com/feed"
    feed = feedparser.parse(feed_url)
    
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
        
        original_title = entry.title
        description = entry.description
        published_time = datetime(*entry.published_parsed[:6])
        news_url = entry.link
        
        discussion_title = generate_discussion_title(original_title, description)
        title_camp, comment_1, comment_1_camp, comment_2, comment_2_camp = process_news_with_gpt(discussion_title, description)
        
        sql_query = f"""
            INSERT INTO OPN_SFC_CONTENT 
            (COUNTRY_CODE, NEWS_DATE, INTEREST_CODE, NEWS_TITLE, TITLE_CAMP, COMMENT1_SENTIMENT, COMMENT_1, COMMENT1_CAMP, COMMENT2_SENTIMENT, COMMENT_2, COMMENT2_CAMP, NEWS_URL)
            VALUES 
            ('{country_code}', '{published_time.strftime("%Y-%m-%d %H:%M:%S")}', '{interest_code}', 
             '{discussion_title}', '{title_camp}', 'LOVE', '{comment_1}', '{comment_1_camp}', 'HATE', '{comment_2}', '{comment_2_camp}', '{news_url}');
        """
        
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
    parser = argparse.ArgumentParser()
    parser.add_argument("country_code", type=str, help="Country code, e.g., NGA")
    parser.add_argument("interest_code", type=str, help="Interest code, e.g., POLITICS")
    parser.add_argument("num_items", type=int, help="Number of news items to process")
    args = parser.parse_args()
    
    process_and_store_news(args.country_code, args.interest_code, args.num_items)
