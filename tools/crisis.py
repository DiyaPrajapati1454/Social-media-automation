from newsapi import NewsApiClient
from flask import request,jsonify,Blueprint
from textblob import TextBlob
import datetime

# Initialize NewsAPI
newsapi = NewsApiClient(api_key='a056f368d8ad4ecd9464f7c10c8a001a')  # Replace with your key
crisis_blueprint=Blueprint('crisis',__name__)
# Function to fetch crisis-related news
def fetch_crisis_news(keyword="crisis", from_days_ago=1):
    date = (datetime.datetime.now() - datetime.timedelta(days=from_days_ago)).strftime('%Y-%m-%d')
    articles = newsapi.get_everything(q=keyword, from_param=date, language='en', sort_by='relevancy', page_size=5)
    return articles['articles']

# Generate a summary for crisis alert
@crisis_blueprint.route('/display-crisis',methods=['POST'])
def generate_crisis_post(keyword="crisis"):
    articles = fetch_crisis_news(keyword)
    alert_posts = []

    for article in articles:
        title = article['title']
        description = article.get('description', '')
        url = article['url']
        content = f"{title}. {description}"

        # Sentiment analysis to detect urgency
        sentiment = TextBlob(content).sentiment
        print(f"Title: {article['title']}, Polarity: {sentiment.polarity}")
        if sentiment.polarity < 0.05:  # Negative = likely a crisis
             alert_posts.append({
                "title": title,
                "description": description,
                "url": url
            })
    return jsonify({"alerts": alert_posts})

# Example usage

