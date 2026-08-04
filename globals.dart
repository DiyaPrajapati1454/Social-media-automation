import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:social_media_automation/screens/ai_display.dart';
import 'package:http/http.dart' as http;
String selectedPlatform="";
String accesstoken= "";
String user_id="";
String account_id="";
Future<String> getLocalIP() async{
  // for(var interface in await NetworkInterface.list()){
  //   for(var addr in interface.addresses){
  //     if(addr.type==InternetAddressType.IPv4 && !addr.isLoopback){
  //       return addr.address;
  //     }
  //   }
  // }
  return "192.168.32.179";
}
Future<void> generateContent({
  required BuildContext context,
  required String topic,
  required List<String> contentTypes,
  required String length,
  required String platform,
  String description = "",
  required Future<void> Function() retryFunction
}) async {
  String ip=await getLocalIP();
  ip=ip.substring(0,ip.lastIndexOf('.'));
  final url = Uri.parse("http://$ip.179:5000/generate-content");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "content-types": contentTypes,
        "content-length": length,
        "topic": topic,
        "description": description,
        "platform": platform,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print(response.body);
      bool wantText = contentTypes.contains("Text");
      bool wantImage = contentTypes.contains("Image");
      String? content = wantText ? responseData["Text"] : null;
      String? imageBase64 = wantImage ? responseData["Image"] : null;
      String? imageUrl=wantImage?responseData["ImageURL"]:null;

      if ((wantText && content == null) && (wantImage && imageBase64 == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No content generated. Try again!"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AiDisplayScreen(
            data: content ?? "",
            imagebase64: imageBase64,
            imageUrl: imageUrl,
            platform: platform,
            topic: topic,
            type: contentTypes,
            sendPostRequest: retryFunction,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Server Error"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 50, left: 20, right: 20),
        ),
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Unable to Connect"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 50, left: 20, right: 20),
      ),
    );
  }
}
Future<void> storePlatformConnection({
  required String userId,               // App User ID (Firebase UID)
  required String platformName,         // "LinkedIn", "YouTube", etc.
  required String platformUserId,       // ID from platform
  required String profileName,
  required String profileEmail,
  String? profilePicture,
  required String accessToken,

}) async {
  final connectionRef = FirebaseFirestore.instance
      .collection('Connection')
      .where('user_id', isEqualTo: userId)
      .where('platform_name', isEqualTo: platformName);

  final existing = await connectionRef.get();

  if (existing.docs.isNotEmpty) {
    // Update existing connection
    final docId = existing.docs.first.id;
    await FirebaseFirestore.instance
        .collection('Connection')
        .doc(docId)
        .update({
      'access_token': accessToken,
      'profile_name': profileName,
      'profile_email': profileEmail,
      'profile_picture': profilePicture,
      'platform_user_id': platformUserId,
      'is_active': true,
      'last_updated': Timestamp.now(),
    });
    print("Existing connection updated for $platformName.");
  } else {
    // Add new connection
    await FirebaseFirestore.instance.collection('Connection').add({
      'user_id': userId,
      'platform_name': platformName,
      'platform_user_id': platformUserId,
      'access_token': accessToken,
      'profile_name': profileName,
      'profile_email': profileEmail,
      'profile_picture': profilePicture,
      'connected_at': Timestamp.now(),
      'last_updated': Timestamp.now(),
      'is_active': true,
    });
    print("New connection stored for $platformName.");
  }
}
Future<String?> uploadImageToFirebase(String base64Image) async {
  try {
    final imageBytes = base64Decode(base64Image.split(',')[1]);
    final fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.png';
    final ref = FirebaseStorage.instance.ref().child(fileName);
    await ref.putData(imageBytes);
    return await ref.getDownloadURL();
  } catch (e) {
    print("Error uploading image: $e");
    return null;
  }
}
Future<void> storePost({
  required String userId,               // App User ID (Firebase UID)
  required String platformName,         // "LinkedIn", "YouTube", etc.
  required String platformUserId,       // ID from platform
  required String postContent,
  String? mediaUrl,
  required String topic,
  required String generatedType, // text, image, video
  //required DateTime scheduledTime,
  DateTime? postedTime,
  required String status, // posted, failed, pending
  String? responseMessage,
}) async {
  final postRef = FirebaseFirestore.instance
      .collection('Posts');
  final newPostRef = postRef.doc(); // auto-generated ID
  final postId = newPostRef.id;
  //String? media="";
  // if(mediaUrl!=null){
  //   String base64=mediaUrl;
  //   media=await uploadImageToFirebase(base64);
  // }
  try{
    await newPostRef.set({
      'user_id':userId,
      'platform_user_id':platformUserId,
      'post_Id':postId,
      'platform': platformName,
      'postContent': postContent,
      'mediaUrl': mediaUrl,
      'topic': topic,
      'generatedType': generatedType,
      // 'scheduledTime': scheduledTime,
      'postedTime': postedTime??'',
      'status': status,
      'responseMessage': responseMessage,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print("Post data stored");
  }catch(e){
    print("Error generated ${e}");
  }
    // await FirebaseFirestore.instance.collection('Posts').add({
    //   'user_id': userId,
    //   'platform_name': platformName,
    //   'platform_user_id': platformUserId,
    //   'connected_at': Timestamp.now(),
    //   'last_updated': Timestamp.now(),
    //   'is_active': true,
    // });
  }






