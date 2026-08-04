import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_automation/Notification_helper.dart';
import 'package:social_media_automation/screens/display_crisis.dart';
import 'package:social_media_automation/screens/display_trends.dart';
import 'package:social_media_automation/screens/engagement_graph.dart';
import 'package:social_media_automation/screens/post_schedule.dart';
import 'package:social_media_automation/screens/voice_post.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'ai_post.dart';

class HomePage extends StatelessWidget {
  Future<void> schedulePost() async{
    tz.initializeTimeZones();
    await Firebase.initializeApp();
    await NotificationHelper.initialize();
  }
  void selectFeature(String title,BuildContext context){
    if(title=="Post Scheduling"){
      schedulePost();
      Navigator.push(context, MaterialPageRoute(builder: (context) => PostSchedulerScreen()),);
    } else if(title=="AI Post Creation"){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>AiPostScreen()));
    } else if(title=="Trend-Based Posts"){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>DisplayTrendScreen()));
    }else if(title=="Voice Post Creation"){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>VoicePostGenerator()));
    }else if(title=='Crisis Analysis'){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>DisplayCrisisScreen()));
    }else if(title=="Competition Tracking"){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>PostEngagementGraphScreen()));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Social Media Automation',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStorySection(),
            SizedBox(height: 10),
            _buildFeedSection(),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildStorySection() {
    return Container(
      height: 110,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: features.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: (){
              selectFeature(features[index]["title"], context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.lightBlueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        features[index]['icon'],
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    features[index]['title'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedSection() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: (){
            selectFeature(features[index]["title"], context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 5),
                ],
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2.5),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.lightBlueAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          features[index]['icon'],
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          features[index]['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Explore the feature of ${features[index]['title']} for your business.",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

final List<Map<String, dynamic>> features = [
  {'icon': Icons.schedule, 'title': 'Post Scheduling'},
  {'icon': Icons.auto_awesome, 'title': 'AI Post Creation'},
  {'icon': Icons.mic, 'title': 'Voice Post Creation'},
  {'icon': Icons.trending_up, 'title': 'Trend-Based Posts'},
  {'icon': Icons.warning, 'title': 'Crisis Analysis'},
  {'icon': Icons.analytics, 'title': 'Competition Tracking'},
];

