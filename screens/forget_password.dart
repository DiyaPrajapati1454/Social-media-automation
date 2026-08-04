
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_automation/screens/otp_verify.dart';
import 'package:social_media_automation/widgets/custom_scaffold.dart';

import '../themes/theme.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => ForgetPasswordScreenState();
}
class ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  TextEditingController email=new TextEditingController();
  final _formkey=GlobalKey<FormState>();
  Future<bool> _checkemail() async{
    try{
      QuerySnapshot query=await FirebaseFirestore.instance.collection("User").where('email',isEqualTo: email.text).get();
      if(query.docs.isNotEmpty){
        return true;
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
        return false;
      }

    }catch(e){
      print("Error ${e}");
      return false;
    }
  }
  Future<void> sendOtpToEmail(String email) async{
   EmailOTP.config(
       appName: "Social Media Automation",
       otpType: OTPType.numeric,
       expiry:30000,
       emailTheme: EmailTheme.v6,
       appEmail: "prajapatidiya547@gmail.com",
       otpLength: 6);
   EmailOTP.setSMTP(
       emailPort: EmailPort.port587,
       secureType: SecureType.tls,
       host: "smtp.gmail.com",
       username: "prajapatidiya547@gmail.com",
       password: "syzj viie ycyi wgxo");
   EmailOTP.setTemplate(
     template: '''
    <div style="background-color: #f4f4f4; padding: 20px; font-family: Arial, sans-serif;">
      <div style="background-color: #fff; padding: 20px; border-radius: 10px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);">
        <h1 style="color: #333;">{{appName}}</h1>
        <p style="color: #333;">Your OTP is <strong>{{otp}}</strong></p>
        <p style="color: #333;">This OTP is valid for  30 seconds.</p>
        <p style="color: #333;">Thank you for using our service.</p>
      </div>
    </div>
    ''',
   );
   bool res=await EmailOTP.sendOTP(email: email);
   if(res){
     print("Success");
   }else{
     print("Failed");
   }
  }
  @override
  Widget build(BuildContext context) {
    // return const Text('Forget Password');
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
                              controller: email,
                              validator: (email){
                                if(email==null || email.isEmpty){
                                  return "Please enter email";
                                }
                                String emailPattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
                                RegExp exp=RegExp(emailPattern);
                                if(!exp.hasMatch(email)){
                                  return "Please enter a valid email address";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  label: const Text("Email"),
                                  hintText: "Enter Email",
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
                                    if(_formkey.currentState!.validate()){
                                      showDialog(
                                          context: context,
                                          builder: (context)=>Center(child: CircularProgressIndicator(),),
                                      );
                                     try{
                                       if(await _checkemail()){
                                         Navigator.pop(context);
                                         Navigator.push(context,MaterialPageRoute(builder: (context)=>OtpVerify(Email:email.value.text)));
                                       }else{
                                         Navigator.pop(context);

                                       }
                                     }catch(e){
                                       Navigator.pop(context);
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         SnackBar(
                                           content: Text("Error occurred while sending OTP"),
                                           backgroundColor: Colors.red,
                                           duration: Duration(seconds: 5),
                                           behavior: SnackBarBehavior.floating,
                                           margin: EdgeInsets.only(top:50,left:20,right:20),
                                         ),
                                       );
                                     }
                                    }
                                  },
                                  child: Text("Verify Email",style: TextStyle(color: Colors.black,fontSize: 16),)),
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