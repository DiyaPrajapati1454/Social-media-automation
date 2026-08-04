import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:social_media_automation/globals.dart';

class PostEngagementGraphScreen extends StatefulWidget {
  const PostEngagementGraphScreen({Key? key}) : super(key: key);

  @override
  State<PostEngagementGraphScreen> createState() => _PostEngagementGraphScreenState();
}

class _PostEngagementGraphScreenState extends State<PostEngagementGraphScreen> {
  String? graphUrl;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchGraph() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    String ip=await getLocalIP();
    ip=ip.substring(0,ip.lastIndexOf('.'));
    String apiUrl = 'http://${ip}.179:5000/post-engagement';
    String accessToken = accesstoken;
    String userId = user_id;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'platform': selectedPlatform, // or 'youtube' if you support others
          'accessToken': accessToken,
          'userId': account_id,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          graphUrl = responseData['graphUrl'];
          print(graphUrl);
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to connect to backend.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Engagement Graph"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: fetchGraph,
              child: const Text("Fetch Engagement Graph"),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            if (graphUrl != null && !isLoading)
              Expanded(
                child: Image.network(
                  graphUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Failed to load image.');
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
