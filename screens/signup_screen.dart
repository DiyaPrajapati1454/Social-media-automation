import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:social_media_automation/screens/signin_screen.dart';
import 'package:social_media_automation/themes/theme.dart';
import 'package:social_media_automation/widgets/custom_scaffold.dart';

import '../firebase_options.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //runApp(MyApp());
}
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final name=TextEditingController();
  final email=TextEditingController();
  final password=TextEditingController();
  final date=DateTime.now();
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  bool isFirebaseInitialised=false;
  @override
  void initState(){
    super.initState();
    _initializeFirebase();
  }
  Future<void> _initializeFirebase() async{
    try{
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      setState(() {
        isFirebaseInitialised=true;
      });
    }catch(e){
      print("Firebased exception occured $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                // get started form
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // get started text
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      // full name
                      TextFormField(
                        controller: name,
                        validator: (name) {
                          if (name == null || name.isEmpty) {
                            return 'Please enter Full name';
                          }
                          if(!name.contains(RegExp(r'[A-Z]')) || !name.contains(RegExp(r'[a-z]'))){
                            return "Please enter alphabets only";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Full Name'),
                          hintText: 'Enter Full Name',
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
                        height: 25.0,
                      ),
                      // email
                      TextFormField(
                        controller: email,
                        validator: (email) {
                          if (email == null || email.isEmpty) {
                            return 'Please enter Email';
                          }
                          String emailPattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
                          RegExp regex = RegExp(emailPattern);
                          if(!regex.hasMatch(email)){
                            return "Please Enter valid email address";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter Email',
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
                        height: 25.0,
                      ),
                      // password
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
                          label: const Text('Password'),
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
                        height: 25.0,
                      ),
                      // i agree to the processing
                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (bool? value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                            activeColor: lightColorScheme.primary,
                          ),
                          const Text(
                            'I agree to the processing of ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          Text(
                            'Personal data',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: lightColorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // signup button
                      SizedBox(
                        width: double.infinity,
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
                          onPressed: () async {
                            if (_formSignupKey.currentState!.validate() &&
                                agreePersonalData) {
                              CollectionReference colref=FirebaseFirestore.instance.collection("User");
                              try{
                                UserCredential userCredential=await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                    email: email.text,
                                    password: password.text,);
                                String uid=userCredential.user!.uid;
                                await colref.add({
                                  "uid":uid,
                                  "name":name.text,
                                  "email":email.text,
                                  "password":password.text,
                                  "date":date
                                });
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>SignInScreen()));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("User registered successfully"),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 5),
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.only(top:50,left:20,right:20),
                                  ),
                                );
                              }on FirebaseAuthException catch(e){
                               if(e.code=="email-already-in-use"){
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                     content: Text("Already register please login to continue"),
                                     backgroundColor: Colors.red,
                                     duration: Duration(seconds: 5),
                                     behavior: SnackBarBehavior.floating,
                                     margin: EdgeInsets.only(top:50,left:20,right:20),
                                   ),
                                 );
                               }
                              }

                            } else if (!agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please agree to the processing of personal data')),
                              );
                            }
                            //print("Adding User");
                          },
                          child: const Text('Sign up',style: TextStyle(color: Colors.black,fontSize: 16),),
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Create an account.',
                        style: TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                      ]
                  )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}