import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:social_media_automation/globals.dart';
import 'package:social_media_automation/screens/ai_display.dart';
import 'package:social_media_automation/widgets/custom_scaffold.dart';
class DisplayTrendScreen extends StatefulWidget{
  const DisplayTrendScreen({super.key,});
  @override
  State<DisplayTrendScreen> createState()=>TrendScreenState();
}
class TrendScreenState extends State<DisplayTrendScreen>{
  List<dynamic> trends=[];
  bool isLoading=true;
  String topic="";
  Map<String, String> youtubeCategories = {
    "0": "All Categories",
    "1": "Film & Animation",
    "10": "Music",
    "15": "Pets & Animals",
    "17": "Sports",
    "20": "Gaming",
    "22": "People & Blogs",
    "23": "Comedy",
    "24": "Entertainment",
    "25": "News & Politics",
    "26": "How-to & Style",
    "27": "Education",
    "28": "Science & Technology",
    "30": "Movies",
    "43": "Shows"
  };
  String selectedCategory = "0";
  Future<void> generateTrendPost() async{
    String ip=await getLocalIP();
    final _selectedContentType=["Text","Image"];
   await generateContent(
       context: context,
       topic: topic,
       contentTypes: _selectedContentType,
       length: "Medium",
       platform: selectedPlatform,
       retryFunction: generateTrendPost
   );
  }
  Future<void> regenerateTrends() async{
    setState(() {
      isLoading=true;
      trends.clear();
    });
    showDialog(
      context: context,
      builder: (context)=>Center(child: CircularProgressIndicator(),),
    );
    generateTrends();
  }
  Future<void> generateTrends() async{
    String ip=await getLocalIP();
    ip=ip.substring(0,ip.lastIndexOf('.'));
    print(ip);
    final url=Uri.parse("http://${ip}.179:5000/trend-post");
    try{
      print(selectedCategory);
      final response=await http.post(
        url,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "Platform":selectedPlatform,
          "Category":selectedCategory
        })
      );
      if(response.statusCode==200){
        setState(() {
          print(jsonDecode(response.body).runtimeType);
          print(jsonDecode(response.body));
          trends=List<String>.from(jsonDecode(response.body));
          print(trends);
          isLoading=false;
        });
      }else{
        setState(() {
          isLoading=true;
        });
        print("Error fetching trends");
      }
    }catch(e){
      setState(() {
      isLoading=false;
    });
      print("Exception generated ${e}");
    }
  }
  @override
  void initState(){
    super.initState();
    generateTrends();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("List of Trends"),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Show category selection only for YouTube
          if (selectedPlatform == "YouTube")
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: DropdownButtonFormField<String>(
                value: selectedCategory, // Currently selected category
                onChanged: (newCategory) {
                  setState(() {
                    selectedCategory = newCategory!;
                  });
                  generateTrends(); // Regenerate trends based on selection
                },
                items: youtubeCategories.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: "Select Category",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : trends.isEmpty
                ? Center(child: Text("No trends available"))
                : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: trends.length,
              itemBuilder: (context, index) {
                final trend = trends[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      trend is String ? trend : trend["title"] ?? "Unknown",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Center(child: CircularProgressIndicator(color: Colors.blue)),
                      );
                      topic = trend.toString();
                      generateTrendPost();
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              onPressed: generateTrends,
              icon: Icon(Icons.refresh),
              label: Text("Regenerate Trends"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );

  }

}