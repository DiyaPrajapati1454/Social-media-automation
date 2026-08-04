import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media_automation/globals.dart';
import 'package:social_media_automation/screens/ai_post.dart';
import 'package:social_media_automation/widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http;

class AiDisplayScreen extends StatefulWidget{
  final String data;
  final String ?imagebase64;
  final String?imageUrl;
  final String platform;
  final topic;
  final type;
  final Future<void> Function() sendPostRequest;
  const AiDisplayScreen({super.key,required this.data,required this.imagebase64,required this.imageUrl,required this.platform,required this.topic,required this.type,required this.sendPostRequest});
  @override
  State<AiDisplayScreen> createState()=>_AiDisplayScreenState();
}
class _AiDisplayScreenState extends State<AiDisplayScreen>{
    void postToPlatform(String postContent,String image_base64)async{
      String ip=await getLocalIP();
      ip=ip.substring(0,ip.lastIndexOf('.'));
      print("Sending request to post");
      final url = Uri.parse("http://$ip.179:5000/post_Content");
      final response=await http.post(
          url,
          headers: {
            "Content-Type":"application/json"
          },
          body: jsonEncode({
            "platform":selectedPlatform,
            "access_token":accesstoken,
            "user_id":user_id,
            "content":postContent ?? "",
            "image_base64":image_base64 ?? ""
          }),
      );
      if(response.statusCode==200 ){
        print("Access Token: $accesstoken");
        print("Post successful ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Post successful"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top: 50, left: 20, right: 20),
          ),
        );
        try{

         //String imageUrl=;
          await storePost(
              userId: FirebaseAuth.instance.currentUser!.uid,
              platformName: selectedPlatform,
              platformUserId: user_id,
              postContent: widget.data,
              mediaUrl: widget.imageUrl??'',
              topic: widget.topic,
              generatedType: widget.type.toString(),
              postedTime: DateTime.now(),
              status: 'posted',
          );
        }catch(e){
          print("Exception: ${e}");
          if (e is FirebaseException) {
            print('Firebase Error Code: ${e.code}');
            print('Firebase Error Message: ${e.message}');
          }
        }

      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Unable to Post"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top: 50, left: 20, right: 20),
          ),
        );
      }
    }
    @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Uint8List?imageBytes;
    if(widget.imagebase64!=null && widget.imagebase64!.isNotEmpty){
      try{
        imageBytes=base64Decode(widget.imagebase64!.split(',')[1]);
      }catch(e){
        print("Error occurred ${e}");
      }
    }
    return CustomScaffold(
        child: Column(
        children: [
        const Expanded(
        flex:1,
        child: SizedBox(
        height:10
        )
      ),
      Expanded(
        flex:7,
        child: Container(
        padding:const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
        decoration:const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40.0),
        topRight: Radius.circular(40.0)
      )
      ),
      child: SingleChildScrollView(
        child: Column(
         // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if(widget.data.isNotEmpty)...[
              Text("Generated Text",style: TextStyle(fontSize:21,fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Text(
                  widget.data,
                  style: TextStyle(fontSize: 18),
              ),
            ],
            const SizedBox(
              height: 30.0,
            ),
            if(imageBytes!=null)...[
              Text("Generated Image",style: TextStyle(fontSize:21,fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Image.memory(imageBytes)
            ],
            const SizedBox(
              height: 30.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  // width:double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:Colors.blue, // Regular blue for "Connect"
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        if(mounted){
                          showDialog(
                            context: context,
                            builder: (context)=>Center(child: CircularProgressIndicator(color: Colors.blue,),),
                          );
                          widget.sendPostRequest();
                          if (mounted) Navigator.pop(context);
                        }else{
                          print("Cannot");
                        }
                      },
                      child: Text("Regenerate",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),)),
                ),
                SizedBox(
                  // width:double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Regular blue for "Connect"
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {

                          postToPlatform(widget.data,widget.imagebase64??"");
                         // postToLinkedIn(accesstoken,widget.data);

                      },
                      child: Text("Post on ${widget.platform}",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),)),
                ),
              ],
            )
          ],
        ),
      ),
    ),
      ),
      ],
    ),
    );
  }
}