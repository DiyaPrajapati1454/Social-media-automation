import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_automation/globals.dart';
import 'package:social_media_automation/screens/ai_display.dart';
import 'package:social_media_automation/widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http;

import '../themes/theme.dart';

class AiPostScreen extends StatefulWidget{
  //final String platform;
  const AiPostScreen({super.key,});
  @override
  State<AiPostScreen> createState()=>AiPostScreenState();

}
class AiPostScreenState extends State<AiPostScreen>{
  final _formkey=GlobalKey<FormState>();
  Map<String, bool> _contentTypes = {
    "Text": false,
    "Image": false,
  };
  TextEditingController topic=new TextEditingController();
  TextEditingController description=new TextEditingController();
  String _selectedLength = "Short";
  final List<String> _contentLengths = ["Short", "Medium", "Long"];
  Future<void> sendPostRequest() async{
    String ip=await getLocalIP();
    final _selectedContentType=_contentTypes.entries.where((entry)=>entry.value).map((entry)=>entry.key).toList();
    print("Executed");
    print(ip);
    await generateContent(
        context: context,
        topic: topic.text,
        contentTypes: _selectedContentType,
        length: _selectedLength,
        platform: selectedPlatform,
        description:description.text,
        retryFunction: sendPostRequest,

    );
  }
  @override
  Widget build(BuildContext context) {
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
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Generate Ai based Post",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: lightColorScheme.primary
                ),
              ),
              const SizedBox(
                  height:30.0
              ),
                TextFormField(
                  controller: topic,
                  validator: (topic){
                    if(topic==null || topic.isEmpty){
                      return "Please enter topic";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      label: const Text("Topic",style: TextStyle(color: Colors.black),),
                      hintText: "Enter Topic",
                      hintStyle: const TextStyle(
                          color: Colors.black26
                      ),
                      border:OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white12,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),

                  ),
                ),
                const SizedBox(
                    height:25.0
                ),
                Text("Select Content type: ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                Column(
                  children: _contentTypes.keys.map((String key){
                    return CheckboxListTile(
                      title: Text(key),
                        checkColor: Colors.white,
                        activeColor: Colors.blue,
                        value: _contentTypes[key],
                        onChanged: (bool ? value){
                        setState(() {
                          _contentTypes[key]=value!;
                        });
                        }
                    );
                  }).toList(),
                ),
                const SizedBox(
                  height: 25.0,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedLength,
                  items: _contentLengths.map((length){
                    return DropdownMenuItem(value: length,child: Text(length));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedLength=newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Content Length",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                    height:25.0
                ),
                TextFormField(
                  controller: description,
                  validator: (description){
                    return null;
                  },
                  decoration: InputDecoration(
                      label: const Text("Description"),
                      hintText: "Enter description (Optional)",
                      hintStyle: const TextStyle(
                          color: Colors.black26
                      ),
                      border:OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      )
                  ),
                ),
                const SizedBox(
                    height:25.0
                ),
                SizedBox(
                  width:double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Regular blue for "Connect"
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        if(_formkey.currentState!.validate()){
                          showDialog(
                            context: context,
                            builder: (context)=>Center(child: CircularProgressIndicator(color: Colors.blue,),),
                          );
                          sendPostRequest();
                        }
                      },
                      child: Text("Generate Post",style: TextStyle(color: Colors.white),)),
                ),
                const SizedBox(
                  height:20.0
                )
            ]
            )
            )
          )
        )
       )
        ],
      )
    );
  }

}