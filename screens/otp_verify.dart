import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:social_media_automation/screens/forget_password.dart';
import 'package:social_media_automation/screens/reset_password.dart';
import 'package:social_media_automation/themes/theme.dart';
import 'package:social_media_automation/widgets/custom_scaffold.dart';

class OtpVerify extends StatefulWidget{
  final String Email;
  const OtpVerify({super.key,required this.Email});

  @override
  State<OtpVerify> createState() =>_OtpVerifyState();

}
class _OtpVerifyState extends State<OtpVerify>{
  String email="";
  TextEditingController pin=new TextEditingController();
  TextEditingController mail=new TextEditingController();
  final _formkey=GlobalKey<FormState>();
  Future<void> validateOTP() async{
    bool res=await EmailOTP.verifyOTP(otp: pin.value.text);
    print(ForgetPasswordScreenState().email.text);
    if(res){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ResetPasswordScreen(email: widget.Email,)));
    }else{
      print("${pin.value.text} and ${EmailOTP.getOTP()} and ${EmailOTP.isOtpExpired()}");
      print("Invalid");
    }
  }
  @override
  Widget build(BuildContext context) {
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
                            Text("Enter Otp sent to your email",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black26
                              ),
                            ),
                            const SizedBox(
                                height:40
                            ),
                            pinCodeTextField(context),
                            const SizedBox(
                                height:50
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
                                  onPressed: (){
                                    validateOTP();
                                  },
                                  child: Text("Verify OTP",style: TextStyle(color: Colors.black,fontSize: 16),)),
                            ),
                            const SizedBox(
                              height: 25.0,
                            ),
                            // don't have an account
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Didn\'t Receive OTP? ',
                                  style: TextStyle(
                                    color: Colors.black45,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    ForgetPasswordScreenState().sendOtpToEmail(widget.Email);
                                  },
                                  child: Text(
                                    'Resend',
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
                        )
                    ),
                  ),
                )
            )
          ],
        )
    );
  }
  Widget pinCodeTextField(BuildContext context){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: PinCodeTextField(
        controller: pin,
          appContext: context,
          length: 6,
        enableActiveFill: true,
        animationType: AnimationType.fade,
        animationDuration: Duration(microseconds: 300),
        keyboardType: TextInputType.number,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(10),
          fieldHeight: 60,
          fieldWidth: MediaQuery.of(context).size.width*0.12,
          inactiveColor: Colors.white12,
          activeColor: lightColorScheme.primary,
          activeFillColor: Colors.white,
          inactiveFillColor: Colors.black12,
          selectedFillColor: Colors.white
        ),
      ),
    );
  }
}