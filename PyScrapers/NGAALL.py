from newsapi import NewsApiClient

# Initialize the NewsAPI client
API_KEY = "0dbc12a2265b471cac98f9f4b5eee620"
newsapi = NewsApiClient(api_key=API_KEY)


def get_latest_political_news(country="in",  page_size=5):
    """
    Fetches the latest political news articles based on country and category.
    :param country: Country code (default is "in" for India).
    :param category: News category (default is "politics").
    :param page_size: Number of articles to fetch (default is 5).
    :return: List of news articles.
    """
    # Fetch top headlines with category and country filters
    top_headlines = newsapi.get_top_headlines(
        country=country,
        page_size=page_size
    )

    # Extract articles from the response
    articles = top_headlines.get("articles", [])

    if not articles:
        print("No articles found for the given parameters.")
    return articles


# Example usage
if __name__ == "__main__":
    news_articles = get_latest_political_news(country="in")

    for idx, article in enumerate(news_articles, start=1):
        print(f"{idx}. Title: {article['title']}")
        print(f"   Source: {article['source']['name']}")
        print(f"   Published At: {article['publishedAt']}")
        print(f"   URL: {article['url']}\n")