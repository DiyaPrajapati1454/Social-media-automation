import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:social_media_automation/screens/forget_password.dart';
import 'package:social_media_automation/screens/signin_screen.dart';

import '../themes/theme.dart';
import '../widgets/custom_scaffold.dart';

class ResetPasswordScreen extends StatefulWidget{
  final String email;
  const ResetPasswordScreen({super.key,required this.email});
  @override
  State<ResetPasswordScreen> createState()=>_ResetPasswordScreenState();
}
class _ResetPasswordScreenState extends  State<ResetPasswordScreen>{
  TextEditingController password=new TextEditingController();
  TextEditingController confirmpassword=new TextEditingController();
  final _formkey=GlobalKey<FormState>();
  Future<void> _changePassword() async{
    try{
      QuerySnapshot query=await FirebaseFirestore.instance.collection("User").where('email',isEqualTo: widget.email).get();
      if(query.docs.isNotEmpty){
       DocumentSnapshot userDoc=query.docs.first;
       String userId=userDoc.id;
       await FirebaseFirestore.instance.collection("User").doc(userId).update({"password":password.text});
       print("Password updated successfully");
       Navigator.push(context, MaterialPageRoute(builder: (context)=>SignInScreen()));
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("User doesn't exist"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top:50,left:20,right:20),
          ),
        );
      }

    }catch(e){
      print("Error ${e}");
    }
  }
  @override
  Widget build(BuildContext context){
    return CustomScaffold(
        child:Column(
          children: [
            const Expanded(
                flex:1,
                child: SizedBox(
                    height:20
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
                            Text("Reset Password",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: lightColorScheme.primary
                              ),
                            ),
                            const SizedBox(
                                height:50
                            ),
                            TextFormField(
                              controller: password,
                              obscureText: true,
                              obscuringCharacter: '*',
                              validator: (password) {
                                if (password == null || password.isEmpty) {
                                  return 'Please enter Password';
                                }
                                if(password.length<8){
                                  return "Password must be 8 character long";
                                }
                                if(!password.contains(RegExp(r'[A-Z]'))){
                                  return "Password must contain at least one upper case";
                                }
                                if(!password.contains(RegExp(r'[a-z]'))){
                                  return "Password must contain at least one lower case";
                                }
                                if(!password.contains(RegExp(r'[0-9]'))){
                                  return "Password must contain at least one digit";
                                }
                                if(!password.contains(RegExp(r'[!@#%^&*]'))){
                                  return "Password must contain special symbol as !,@,#,%,^,&,*";
                                }
                                if(password.contains(RegExp(r'[(),.?":{}|<>]'))){
                                  return "Password must contain special symbol as !,@,#,%,^,&,*";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('New Password'),
                                hintText: 'Enter Password',
                                hintStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(
                                height:50
                            ),
                            TextFormField(
                              controller: confirmpassword,
                              obscureText: true,
                              obscuringCharacter: '*',
                              validator: (confirm) {
                                if (confirm == null || confirm.isEmpty) {
                                  return 'Please enter Password';
                                }
                                if(confirmpassword.value.text!=password.value.text){
                                  return 'Password and Confirm Password must be same';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('Confirm Password'),
                                hintText: 'Enter Password',
                                hintStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(
                                height:40.0
                            ),
                            SizedBox(
                              width:double.infinity,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white, // Default color
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ).copyWith(
                                    backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                                      if (states.contains(MaterialState.pressed)) {
                                        return Colors.blue; // Change to red when pressed
                                      }
                                      return Colors.white70; // Default color
                                    }),
                                  ),
                                  onPressed: () async{
                                    // print("${password.value.text}  and ${confirmpassword.value.text}");
                                    if(_formkey.currentState!.validate()){
                                      _changePassword();
                                    }
                                  },
                                  child: Text("Reset Password",style: TextStyle(color: Colors.black,fontSize: 16),)),
                            )
                          ],
                        )
                    ),
                  ),
                )
            )
          ],
        )
    );
  }
}