import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:social_media_automation/globals.dart';
import 'package:url_launcher/url_launcher.dart';
class DisplayCrisisScreen extends StatefulWidget{
  const DisplayCrisisScreen({super.key,});
  @override
  State<DisplayCrisisScreen> createState()=>CrisisScreenState();
}
class CrisisScreenState extends State<DisplayCrisisScreen>{
  bool isLoading=true;
  List<dynamic> crisis=[];
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try{
      if (await launchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print("Could not launch url");
        throw 'Could not launch $url';
      }
    }catch(e){
      print("Exception generating while launching url ${e}");
    }
  }

  Future<void> generateCrisis() async{
    String ip=await getLocalIP();
    ip=ip.substring(0,ip.lastIndexOf('.'));
    final url=Uri.parse("http://${ip}.179:5000/display-crisis");
    try{
      final response=await http.post(
          url,
          headers: {"Content-Type":"application/json"},
          body: jsonEncode({
           // "Platform":selectedPlatform,
            //"Category":selectedCategory
          })
      );
      if(response.statusCode==200){
        setState(() {
          print(jsonDecode(response.body).runtimeType);
          print(jsonDecode(response.body));
          crisis=List<Map<String, dynamic>>.from(jsonDecode(response.body)['alerts']);;
          print(crisis);
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
    generateCrisis();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Crisis List"),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Show category selection only for YouTube
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : crisis.isEmpty
                ? Center(child: Text("No crisis available"))
                : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: crisis.length,
              itemBuilder: (context, index) {
                final cri = crisis[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    title: Text(crisis[index]['title']?? "Unknown",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle:Text(crisis[index]['description']?? "",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      final url=crisis[index]['url'];
                      print(url);
                      _launchURL(url);
                     // topic = trend.toString();
                     // generateTrendPost();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

  }

}