import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../globals.dart';
import 'ai_display.dart';
class VoicePostGenerator extends StatefulWidget {
  @override
  _VoicePostGeneratorState createState() => _VoicePostGeneratorState();
}

class _VoicePostGeneratorState extends State<VoicePostGenerator> {
  late stt.SpeechToText _speech;
  Future<void> _requestPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }
  bool _isListening = false;
  String _spokenText = '';
  Set<String> _selectedType = {}; // 'text' or 'image'

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    Future.delayed(Duration(milliseconds: 500), () async {
      await _requestPermissions();
      _initSpeech();
    });
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );
    print('Speech available: $available');
  }

  void _startListening() async {
    await Future.delayed(Duration(milliseconds: 300));
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          setState(() {
            _spokenText = val.recognizedWords;
          });
        },
        localeId: 'en_US', // Optional
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }
  Future<void>generatePost() async{
    final List<String> _selectedContentType=[];
    if (_selectedType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one content type")),
      );
      return;
    }
    if(_selectedType.contains("Text")){
      _selectedContentType.add("Text");
    }
    if(_selectedType.contains("Image")){
      _selectedContentType.add("Image");
    }
    await generateContent(
        context: context,
        topic: _spokenText,
        contentTypes: _selectedContentType,
        length: "Medium",
        platform: selectedPlatform,
        retryFunction: generatePost
    );
  }
  void _submitPost() {
    if (_spokenText.trim().isEmpty) return;

    // TODO: Send _spokenText and _selectedType to Python backend via HTTP

    print("POST TYPE: $_selectedType");
    print("CONTENT: $_spokenText");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sent for post generation")),
    );
    generatePost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice-Based Post Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display spoken text
            Text(
              _spokenText.isEmpty ? 'Speak something...' : _spokenText,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Type selection: Text or Image
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilterChip(
                  label: Text('Text'),
                  selected: _selectedType.contains('Text'),
                  onSelected: (isSelected) {
                    setState(() {
                      isSelected
                          ? _selectedType.add('Text')
                          : _selectedType.remove('Text');
                    });
                  },
                ),
                const SizedBox(width: 10),
                FilterChip(
                  label: Text('Image'),
                  selected: _selectedType.contains('Image'),
                  onSelected: (isSelected) {
                    setState(() {
                      isSelected
                          ? _selectedType.add('Image')
                          : _selectedType.remove('Image');
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Microphone button
            FloatingActionButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Icon(_isListening ? Icons.mic: Icons.mic_off),
              tooltip: _isListening ? 'Stop Listening' : 'Start Listening',
            ),
            const SizedBox(height: 30),

            // Submit button
            ElevatedButton.icon(
              icon: Icon(Icons.send),
              label: Text("Generate Post"),
              onPressed: _spokenText.isNotEmpty ? _submitPost : null,
            ),
          ],
        ),
      ),
    );
  }
}
