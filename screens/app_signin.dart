import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_automation/auth.dart';
import 'package:social_media_automation/widgets/custom_scaffold.dart';

import '../themes/theme.dart';

class AppSignInScreen extends StatefulWidget{
  final String platformName;
  const AppSignInScreen({super.key,required this.platformName});
  @override
  State<AppSignInScreen> createState()=>_AppSignInScreenState();
}
class _AppSignInScreenState extends State<AppSignInScreen>{

  final _formAppSignInkey=GlobalKey<FormState>();
  bool rememberPassword = true;
  TextEditingController email=new TextEditingController();
  TextEditingController password=new TextEditingController();
  @override
  Widget build(BuildContext context) {
    String pname=widget.platformName;
   return CustomScaffold(
     child: Column(
       children: [
         const Expanded(
           flex:1,
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
                  key: _formAppSignInkey,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      Text(
                          'Sign in to ${widget.platformName}',
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
                                            // Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgetPasswordScreen()));
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
                                  onPressed: () {
                                      if (_formAppSignInkey.currentState!.validate() && rememberPassword) {
                                        if(pname=="Instagram"){
                                          // AppLogin().loginWithInstagram(context);
                                        }else if(pname=="Facebook"){

                                        }else if(pname=="Twitter"){

                                        }else if(pname=="LinkedIn"){
                                          // AppLogin().loginWithLinkedIn(context);
                                        }else if(pname=="YouTube"){

                                        }else if(pname=="Google Business Profile"){

                                        }
                                      }
                                      else if (!rememberPassword) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                            content: Text(
                                                  'Please agree to the processing of personal data')),
                                            );
                                      }
                                  },
                                  child: const Text('Sign in'),
                                ),
                              ),
                              const SizedBox(
                                  height: 25.0,
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