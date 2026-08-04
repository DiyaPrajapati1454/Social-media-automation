from flask import request,jsonify,Blueprint
import requests,json
import googleapiclient.discovery
import geocoder
import feedparser
import re
trend_blueprint=Blueprint('trend',__name__)
def general_trend():
    url="http://rss.cnn.com/rss/edition.rss"
    feed=feedparser.parse(url)
    trending_topics=[entry.title for entry in feed.entries[:20]]
    trends=[re.sub(r"(why|what|check out|explained|top \d+|on ott|today|now|trending)","",topic,flags=re.I).strip(" -") for topic in trending_topics]
    return trends 
def youtube_trend(category):
    location=geocoder.ip("me")
    country_code=location.country
    preferred_language=["en","hi"]
    if not country_code:
        country_code="US"
    api_key="AIzaSyDzYW2U9UI-rtRGM0bAA2lhqFvGz2FFTYY"
    youtube=googleapiclient.discovery.build("youtube","v3",developerKey=api_key)
    request=youtube.videos().list(part="snippet",chart="mostPopular",regionCode=country_code,videoCategoryId=category,maxResults=100)
    response=request.execute()
    trends = []
    
    for video in response.get("items", []):
        title = video["snippet"]["title"]
        language = video["snippet"].get("defaultAudioLanguage", "unknown")  # Get language
        # print(preferred_language)
        # Check if language is in preferred list
        if any(lang in language for lang in preferred_language):
            trends.append(title)

    return trends
    
@trend_blueprint.route('/trend-post',methods=['POST'])
def tred_post():
    data=request.json
    platform=data.get("Platform")
    category=data.get("Category")
    print(category)
    if(platform=="YouTube"):
        trends=youtube_trend(category)
    else:
        trends=general_trend()
    return jsonify(trends)
