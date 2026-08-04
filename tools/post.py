from flask import request,jsonify,Blueprint
import requests
import json
import base64
import tempfile
import google.auth
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload
from moviepy import VideoFileClip, ImageClip, TextClip, CompositeVideoClip
from moviepy.audio.io.AudioFileClip import AudioFileClip
import os
post_blueprint=Blueprint('post',__name__)
# def create_video(content=None, image_data_base64=None):
#     duration = 10

#     if (not content or not content.strip()) and not image_data_base64:
#         return {"Success": False, "error": "Post must contain either text or image"}

#     clips = []

#     # Handle image if provided
#     if image_data_base64:
#         # Decode the image from base64 and save it temporarily
#         image_bytes = base64.b64decode(image_data_base64)
#         temp_img = tempfile.NamedTemporaryFile(delete=False, suffix=".png")
#         temp_img.write(image_bytes)
#         temp_img.close()

#         # Create ImageClip
#         image_clip = ImageClip(temp_img.name).set_duration(duration).resize(height=1080)
#         clips.append(image_clip)

#     # Handle text if provided
#     if content and content.strip():
#         text_clip = TextClip(content, fontsize=60, color='white', bg_color='black', size=(1920, 1080))
#         text_clip = text_clip.set_duration(duration)
#         clips.append(text_clip)

#     # Combine clips into one video
#     if len(clips) == 1:
#         final_clip = clips[0]
#     else:
#         final_clip = CompositeVideoClip(clips)

#     # Save video to a temporary file
#     temp_video = tempfile.NamedTemporaryFile(delete=False, suffix=".mp4")
#     final_clip.write_videofile(temp_video.name, fps=24)

#     # Optional: Clean up temp image file
#     if image_data_base64:
#         os.remove(temp_img.name)

#     return {"Success": True, "video_path": temp_video.name}
def post_on_youtube():
    # print()
    scopes=['https://www.googleapis.com/auth/youtube.upload']
    body = {
        'snippet': {
            'title': "",
            'description': "",
            'tags': "",
            'categoryId': ""
        },
        'status': {
            'privacyStatus': 'public',  # Options: "public", "private", or "unlisted"
        }
    }

    # MediaFileUpload object
    # media = MediaFileUpload(file_name, mimetype='video/*', resumable=True)

    # Upload the video
    # request = youtube.videos().insert(
        # part='snippet,status',
        # body=body,
        # media_body=media
    # )
    
    # Execute the upload
    response = request.execute()
    print(f'Video uploaded successfully! Video ID: {response["id"]}')
def post_on_instagram(access_token, ig_user_id, caption="", image_data_base64=None):
    if not image_data_base64:
        return {"Success": False, "error": "Image is required for Instagram post"}, 400

    # Step 1: Decode and save the image locally
    try:
        img_data = base64.b64decode(image_data_base64.split(",")[1])
        temp_img = tempfile.NamedTemporaryFile(delete=False, suffix=".jpg")
        temp_img.write(img_data)
        temp_img.close()
    except Exception as e:
        return {"Success": False, "error": f"Failed to decode image: {str(e)}"}, 400

    # Step 2: Upload image to Facebook server as container
    upload_url = f"https://graph.facebook.com/v19.0/{ig_user_id}/media"
    with open(temp_img.name, 'rb') as img_file:
        files = {
            'image_file': img_file
        }
        data = {
            'caption': caption,
            'access_token': access_token
        }
        upload_response = requests.post(upload_url, data=data, files=files)

    if upload_response.status_code != 200:
        os.remove(temp_img.name)
        return {"Success": False, "error": "Failed to create media container", "details": upload_response.json()}, 400

    creation_id = upload_response.json().get("id")

    # Step 3: Publish media using container ID
    publish_url = f"https://graph.facebook.com/v19.0/{ig_user_id}/media_publish"
    publish_data = {
        'creation_id': creation_id,
        'access_token': access_token
    }
    publish_response = requests.post(publish_url, data=publish_data)
    os.remove(temp_img.name)

    if publish_response.status_code == 200:
        return {"Success": True, "message": "Instagram post successful"}
    else:
        return {"Success": False, "error": "Failed to publish media", "details": publish_response.json()}, 400
def post_on_linkedin(access_token,use_urn,content=None,image_data_base64=None):
    headers={
        "Authorization":f"Bearer {access_token}",
        "Content-Type":"application/json",
        "X-Restli-Protocol-Version":"2.0.0",
        "LinkedIn-Version":"202503"
    }
    content=content or ""
    if not content.strip and not image_data_base64:
        return {"Success":False,"error":"Post must contain either text or image"}
    if image_data_base64:
        upload_url = "https://api.linkedin.com/v2/assets?action=registerUpload"
        image_register_payload = {
            "registerUploadRequest": {
                "owner": use_urn,
                "recipes": ["urn:li:digitalmediaRecipe:feedshare-image"],
                "serviceRelationships": [
                    {
                        "identifier": "urn:li:userGeneratedContent",
                        "relationshipType": "OWNER"
                    }
                ]
            }
        }
        upload_response = requests.post(upload_url, headers=headers, json=image_register_payload)
        if upload_response.status_code!=200:
            return {"Success":False,"error":"Image register upload failed"},201
        upload_data = upload_response.json()
        asset_urn = upload_data["value"]["asset"]
        upload_link = upload_data["value"]["uploadMechanism"]["com.linkedin.digitalmedia.uploading.MediaUploadHttpRequest"]["uploadUrl"]
        # 2. Upload the image to the upload URL
        img_data = base64.b64decode(image_data_base64.split(",")[1])
        upload_img_response = requests.put(upload_link, data=img_data, headers={"Authorization": f"Bearer {access_token}", "Content-Type": "image/jpeg"})
        if upload_img_response.status_code!=201:
            return {"Success":False,"error":"Image upload failed"},400
        payload={
            "author":use_urn,
            "lifecycleState":"PUBLISHED",
            "specificContent":{
                "com.linkedin.ugc.ShareContent":{
                    "shareCommentary":{
                        "text":content
                    },
                    "shareMediaCategory":"IMAGE",
                    "media":[
                        {
                            "status":"READY",
                            "description":{"text":"Image"},
                            "media":asset_urn,
                            "title":{"text":"Image post"}
                        }
                    ]
                }
            },
            "visibility":{
                "com.linkedin.ugc.MemberNetworkVisibility":"PUBLIC"
            }
        }
    else:
        payload={
        "author":use_urn,
        "lifecycleState":"PUBLISHED",
        "specificContent":{
            "com.linkedin.ugc.ShareContent":{
                "shareCommentary":{
                    "text":content
                },
                "shareMediaCategory":"NONE"
            }
        },
        "visibility":{
            "com.linkedin.ugc.MemberNetworkVisibility":"PUBLIC"
        }
    }
    url="https://api.linkedin.com/v2/ugcPosts"
    response=requests.post(url,headers=headers,data=json.dumps(payload))
    if response.status_code==201:
        return {"Success":True,"message":"Post Successful!"}
    else:
        return {"Success":False,"error":response.json()} ,201
@post_blueprint.route("/post_Content",methods=["POST"])
def post_Content():
    data=request.json
    platform=data.get("platform")
    if platform=="LinkedIn":
        access_token=data.get("access_token")
        user_id=data.get("user_id")
        use_urn=f"urn:li:person:{user_id}"
        print("Access token ",access_token)
        print("Author urn: ",use_urn)
        content=data.get("content","")
        image_base64=data.get("image_base64",None)
        if not all([access_token,use_urn]):
            return jsonify({"error": "Missing Parameters"}),400
        result=post_on_linkedin(access_token,use_urn,content,image_base64)
    elif platform=="Instagram":
        access_token=data.get("access_token")
        ig_user_id = data.get("user_id")  # Instagram Business ID
        print(access_token," ",ig_user_id)
        content=data.get("content","")
        image_base64=data.get("image_base64",None)
        if not all([access_token, ig_user_id]):
            return jsonify({"error": "Missing Parameters"}), 400
        result = post_on_instagram(access_token, ig_user_id, content, image_base64)

    elif platform=="YouTube":
        # create_video(content,image_base64)
        # post_on_youtube()
        pass
    else:
        result={"Success":False,"error":"Unknown Platform"} ,201
    return jsonify(result)



