from flask import Flask
from aicontent import generate_blueprint
from trendpost import trend_blueprint
from post import post_blueprint
from crisis import crisis_blueprint
from competition import post_engagement
app=Flask(__name__,static_folder="D:/Android/social_media_automation/static")
app.register_blueprint(generate_blueprint)
app.register_blueprint(trend_blueprint)
app.register_blueprint(post_blueprint)
app.register_blueprint(crisis_blueprint)
app.register_blueprint(post_engagement)
if __name__=='__main__':
    app.run(host="0.0.0.0",port=5000,debug=True)
