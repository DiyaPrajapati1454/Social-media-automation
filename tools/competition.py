from flask import Flask, request, jsonify, send_file,Blueprint
import requests
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import os
import uuid
post_engagement=Blueprint('post-engagement',__name__)
STATIC_DIR = "./static"
if not os.path.exists(STATIC_DIR):
    os.makedirs(STATIC_DIR)
@post_engagement.route('/post-engagement', methods=['POST'])
def fetch_post_engagement():
    data = request.get_json()
    platform = data['platform']
    access_token = data['accessToken']
    user_id = data['userId']
    print(platform)
    if platform == 'LinkedIn':
        posts = fetch_linkedin_posts(user_id, access_token)
        # print("Received posts: ",posts)
        graph_path = create_engagement_graph(posts)
        host_url=request.host_url.rstrip('/')
        return jsonify({'graphUrl': f'{host_url}/static/{graph_path}'})
    elif platform=='Instagram':
        data = request.json
        access_token = data.get("accessToken")
        instagram_account_id = data.get("userId")
        if not access_token or not instagram_account_id:
            print("Missing token")
            return jsonify({"error": "Missing access_token or instagram_account_id"}), 400
        posts = fetch_instagram_posts_metrics(access_token, instagram_account_id)
        if not posts:
            print("No post")
            return jsonify({"error": "No posts found or invalid token"}), 400
        graph_file = instagram_create_engagement_graph(posts)

    # Assuming your Flask app is running on localhost:5000 or replace with your URL
        host_url = request.host_url.rstrip('/')
        graph_url = f"{host_url}/static/{graph_file}"
        return jsonify({"graph_url": graph_url})
    else:
        print("No platform")
        return jsonify({'error': 'Platform not supported'}), 400

def fetch_linkedin_posts(user_id, token):
    headers = {'Authorization': f'Bearer {token}'}
    url = f"https://api.linkedin.com/v2/shares?q=owners&owners=urn:li:person:{user_id}"
    
    response = requests.get(url, headers=headers)
    data = response.json()
    results = []
    print("Linkedin Data: ",data)
    for post in data.get('elements', []):
        post_urn = post['id']
        reactions_url = f"https://api.linkedin.com/v2/reactions?object={post_urn}"
        comments_url = f"https://api.linkedin.com/v2/socialActions/{post_urn}/comments"

        likes = len(requests.get(reactions_url, headers=headers).json().get('elements', []))
        comments = len(requests.get(comments_url, headers=headers).json().get('elements', []))
        shares = post.get('distribution', {}).get('shareCount', 0)

        results.append({
            'post_id': post_urn[-6:],  # just last 6 chars for labeling
            'engagement': likes + comments + shares
        })

    return results
def fetch_instagram_posts_metrics(access_token, instagram_account_id):
    """Fetch posts and their engagement (likes + comments) from Instagram Business account."""
    base_url = f"https://graph.facebook.com/v19.0/{instagram_account_id}/media"
    params = {
        "fields": "id,caption,like_count,comments_count",
        "access_token": access_token
    }
    response = requests.get(base_url, params=params)
    posts_data = response.json()

    posts = []
    for post in posts_data.get("data", []):
        post_id = post.get("id")
        caption = post.get("caption", "")[:20]  # short label
        likes = post.get("like_count", 0)
        comments = post.get("comments_count", 0)
        total_engagement = likes + comments
        posts.append({"post_id": post_id, "caption": caption, "engagement": total_engagement})

    return posts

def instagram_create_engagement_graph(posts):
    labels = [p["caption"] or p["post_id"][-6:] for p in posts]
    engagements = [p["engagement"] for p in posts]

    plt.figure(figsize=(12, 6))
    plt.bar(labels, engagements, color='skyblue')
    plt.xlabel("Post (caption snippet)")
    plt.ylabel("Total Engagement (likes + comments)")
    plt.title("Instagram Post Engagement")
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()

    filename = f"{uuid.uuid4()}.png"
    filepath = os.path.join(STATIC_DIR, filename)
    plt.savefig(filepath)
    plt.close()
    return filename
def create_engagement_graph(data):
    post_ids = [d['post_id'] for d in data]
    engagements = [d['engagement'] for d in data]

    plt.figure(figsize=(10, 5))
    plt.bar(post_ids, engagements, color='skyblue')
    plt.xlabel("Post ID")
    plt.ylabel("Total Engagement (likes + comments + shares)")
    plt.title("Post Engagement Overview")

    STATIC_DIR = "D:/Android/social_media_automation/static"  # use full path
    filename = f"{uuid.uuid4()}.png"
    filepath = os.path.join(STATIC_DIR, filename)
    plt.savefig(filepath)
    plt.close()
    return filename


