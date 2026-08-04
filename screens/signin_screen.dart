import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:social_media_automation/auth.dart';
import 'package:social_media_automation/screens/signup_screen.dart';
import 'package:social_media_automation/widgets/custom_scaffold.dart';
import '../firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import '../themes/theme.dart';
import 'package:social_media_automation/dashboard.dart';
import 'forget_password.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}


class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  final email=TextEditingController();
  final password=TextEditingController();
  String?errormsg="";
  bool isLogin=true;
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
      print("Firebase exception occurred $e");
    }
  }
  Future<void> signInWithEmailAndPassword() async{
    try{
      await Auth().signInWithEmailAndPassword(
          email: email.text,
          password: password.text
      );
      Navigator.push(context, MaterialPageRoute(builder:(context)=>DashboardScreen()));
    } on FirebaseAuthException catch(e){
      QuerySnapshot query=await FirebaseFirestore.instance.collection("User").where('email',isEqualTo: email.text).get();
      if(query.docs.isNotEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid Credentials"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top:50,left:20,right:20),
          ),
        );
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("User doesn't exist register first"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top:50,left:20,right:20),
          ),
        );
      }
      Navigator.pop(context);
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
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
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
                      TextFormField(
                        obscureText: true,
                        obscuringCharacter: '*',
                        controller: password,
                        validator: (password) {
                          if (password == null || password.isEmpty) {
                            return 'Please enter Password';
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberPassword,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberPassword = value!;
                                  });
                                },
                                activeColor: lightColorScheme.primary,
                              ),
                              const Text(
                                'Remember me',
                                style: TextStyle(
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgetPasswordScreen()));
                            },
                            child: Text(
                              'Forget password?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
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
                          onPressed: () {
                            if (_formSignInKey.currentState!.validate() &&
                                rememberPassword) {
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   const SnackBar(
                              //     content: Text('No such user exist'),
                              //     backgroundColor: Colors.red,
                              //     duration: Duration(seconds: 5),
                              //     behavior: SnackBarBehavior.floating,
                              //     margin: EdgeInsets.only(top:50,left:20,right:20),
                              //   ),
                              // );
                              if(isLogin){
                                showDialog(
                                  context: context,
                                  builder: (context)=>Center(child: CircularProgressIndicator(),),
                                );
                                signInWithEmailAndPassword();
                              }
                            } else if (!rememberPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please agree to the processing of personal data')),
                              );
                            }
                          },
                          child: const Text('Sign In',style: TextStyle(color: Colors.black,fontSize: 16),),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            child: Text(
                              'Sign in with',
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          Logo(Logos.facebook_f),
                          Logo(Logos.twitter),
                          GestureDetector(
                              onTap: (){
                          AuthMethods().signInWithGoogle(context);
                          },
                              child: Logo(Logos.google)
                          ),
                          GestureDetector(
                            onTap: () async {
                              try{
                                await AuthMethods().signInWithApple();
                              }on PlatformException catch(e){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("${e.message}"),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 5),
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(top:50,left:20,right:20),
                                    ),
                                  );
                              }
                            },
                              child: Logo(Logos.apple)
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // don't have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
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