from flask import request,jsonify,Blueprint
from PIL import Image
from io import BytesIO
import base64
from google import genai
from google.genai import types
import google.generativeai as gen
import os
# print("Flask script started")
# gen.configure(api_key="AIzaSyBQtXms_QgoFLsg8diBqVK9U2-zn6xH1J0")
# client= genai.Client(api_key="AIzaSyBQtXms_QgoFLsg8diBqVK9U2-zn6xH1J0")
# generate_blueprint=Blueprint('generate',__name__)
# UPLOAD_FOLDER = 'static/images'
# os.makedirs(UPLOAD_FOLDER, exist_ok=True)
# @generate_blueprint.route('/generate-content',methods=['POST'])
# def generate_content():
#     data=request.json
#     content_type=data.get("content-types",[])
#     content_length=data.get("content-length")
#     topic=data.get("topic").strip()
#     description=data.get("description","").strip()
#     platform=data.get("Platform","general").strip()
#     generated_content={}
#     if "Text" in content_type:
#         model=gen.GenerativeModel("gemini-1.5-pro")
#         text_prompt= (
#             f"You are an expert social media content creator. Based on the input below, generate a high-quality post "
#             f"suitable for the {platform} platform.\n\n"
#             f"Input:\n- Topic: {topic}\n"
#             f"- Description: {description if description else 'N/A'}\n"
#             f"- Platform: {platform}\n"
#             f"- Content Type: Text\n"
#             f"- Content Length: {content_length.capitalize()}\n\n"
#             f"Output:\nWrite the post in an engaging and platform-appropriate tone."
#         )
#         response=model.generate_content(text_prompt)
#         generated_content["Text"]=response.text
#     if "Image" in content_type:
#         image_prompt = (
#             f"Generate a creative, AI-style image for a social media post on the topic '{topic}' "
#             f"with the following description: {description if description else 'no description provided'}."
#         )
#         response=client._models.generate_content(
#             model="gemini-2.0-flash-exp",
#             contents=image_prompt,
#             config=types.GenerateContentConfig(
#                 response_modalities=["Text","Image"]
#             )
            
#         )
#         image_data=None
#         for part in response.candidates[0].content.parts:
#             if part.inline_data and hasattr(part.inline_data,"data"):
#                 image_data=part.inline_data.data
#                 break
#         if image_data:
#             image=Image.open(BytesIO(image_data))
#             buffered=BytesIO()
#             image.save(buffered,format="PNG")
#             image_filename = f"{topic.replace(' ', '_')}_image.png"
#             image_path = os.path.join(UPLOAD_FOLDER, image_filename)
#             with open(image_path, 'wb') as f:
#                 f.write(buffered.getvalue())

#             # Generate the URL for the image (relative URL to serve the image from Flask)
#             image_url = f"/static/images/{image_filename}"
#             generated_content["ImageURL"] = image_url
#             image_base64=base64.b64encode(buffered.getvalue()).decode("utf-8")
#             generated_content["Image"]=f"data:/image/png;base64,{image_base64}"
#         else:
#             generated_content["ImageURL"] = "No image generated"
#             generated_content["Image"]="No image was generated"
#     return jsonify(generated_content)

from flask import request, jsonify, Blueprint
import os
import requests
import time
from PIL import Image
from io import BytesIO
import base64
gen.configure(api_key="AIzaSyBQtXms_QgoFLsg8diBqVK9U2-zn6xH1J0")
client= genai.Client(api_key="AIzaSyBQtXms_QgoFLsg8diBqVK9U2-zn6xH1J0")
UPLOAD_FOLDER = 'static/images'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
generate_blueprint = Blueprint('generate', __name__)
UPLOAD_FOLDER = 'static/images'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

OPENROUTER_API_KEY = "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"  # Replace with your key

headers = {
    "Authorization": f"Bearer {OPENROUTER_API_KEY}",
    "Content-Type": "application/json"
}

@generate_blueprint.route('/generate-content', methods=['POST'])
def generate_content():
    data = request.json
    content_type = data.get("content-types", [])
    content_length = data.get("content-length", "medium")
    topic = data.get("topic", "").strip()
    description = data.get("description", "").strip()
    platform = data.get("Platform", "general").strip()
    
    generated_content = {}

    if "Text" in content_type:
        text_prompt = (
            f"You are a social media content expert. Create a high-quality post "
            f"for the platform '{platform}' on the topic:\n\n"
            f"- Topic: {topic}\n"
            f"- Description: {description or 'N/A'}\n"
            f"- Content Length: {content_length.capitalize()}\n\n"
            f"Write in an engaging, platform-suitable style."
        )

        text_payload = {
            "model": "mistralai/mistral-7b-instruct",  # ✅ Lightweight free model
            "max_tokens": 1024,  # ✅ Avoid token limit
            "messages": [
                {"role": "user", "content": text_prompt}
            ]
        }

        response = requests.post(
            "https://openrouter.ai/api/v1/chat/completions",
            headers=headers,
            json=text_payload
        )

        if response.status_code == 200:
            result = response.json()
            generated_content["Text"] = result["choices"][0]["message"]["content"]
        else:
            generated_content["Text"] = f"Error generating text: {response.text}"

    # Placeholder for Image — you can re-add later with retry logic
    if "Image" in content_type:
        image_prompt = (
            f"Generate a creative, AI-style image for a social media post on the topic '{topic}' "
            f"with the following description: {description if description else 'no description provided'}."
        )
        response=client._models.generate_content(
            model="gemini-2.0-flash-exp",
            contents=image_prompt,
            config=types.GenerateContentConfig(
                response_modalities=["Text","Image"]
            )
            
        )
        image_data=None
        for part in response.candidates[0].content.parts:
            if part.inline_data and hasattr(part.inline_data,"data"):
                image_data=part.inline_data.data
                break
        if image_data:
            image=Image.open(BytesIO(image_data))
            buffered=BytesIO()
            image.save(buffered,format="PNG")
            image_filename = f"{topic.replace(' ', '_')}_image.png"
            image_path = os.path.join(UPLOAD_FOLDER, image_filename)
            with open(image_path, 'wb') as f:
                f.write(buffered.getvalue())

            # Generate the URL for the image (relative URL to serve the image from Flask)
            image_url = f"/static/images/{image_filename}"
            generated_content["ImageURL"] = image_url
            image_base64=base64.b64encode(buffered.getvalue()).decode("utf-8")
            generated_content["Image"]=f"data:/image/png;base64,{image_base64}"
        else:
            generated_content["ImageURL"] = "No image generated"
            generated_content["Image"]="No image was generated"

    return jsonify(generated_content)
