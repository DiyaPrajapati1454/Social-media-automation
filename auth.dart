import 'dart:convert';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_instagram_api/flutter_instagram_api.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instagram_login/instagram_login.dart';
// import 'package:instagram_login/instagram_login.dart';
import 'package:signin_with_linkedin/signin_with_linkedin.dart';
import 'package:http/http.dart' as http;
import 'package:social_media_automation/OAuth_WebView.dart';
import 'package:social_media_automation/dashboard.dart';
import 'package:social_media_automation/database.dart';
import 'package:social_media_automation/globals.dart';
import 'package:social_media_automation/screens/home_page.dart';
import 'package:the_apple_sign_in/scope.dart' as apple;
import 'package:the_apple_sign_in/the_apple_sign_in.dart';


class Auth{
  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;
  User?get currentUser=>_firebaseAuth.currentUser;
  Stream<User?> get authStateChanges=>_firebaseAuth.authStateChanges();
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password
  }) async{
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
    );
  }
}
class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  signInWithGoogle(BuildContext context) async {
    bool isLoading=true;
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing it
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.blue),
              SizedBox(width: 20),
              Text("Signing in..."),
            ],
          ),
        );
      },
    );
    try{
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn
          .signIn();
      if (googleSignInAccount == null) {
        Navigator.pop(context); // Close the loading dialog
        return; // User canceled sign-in
      }
      final GoogleSignInAuthentication? googleSignInAuthentication = await googleSignInAccount
          ?.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication?.idToken,
          accessToken: googleSignInAuthentication?.accessToken
      );
      UserCredential result = await firebaseAuth.signInWithCredential(credential);
      User? userDetails = result.user;
      if (result != null) {
        Map<String, dynamic>userInfoMap = {
          "email": userDetails!.email,
          "name": userDetails.displayName,
          "id": userDetails.uid
        };
        await DatabaseMethods().addUser(userDetails.uid, userInfoMap).then((value){
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        });
      }
    }
    catch(e){
      Navigator.pop(context); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google Sign-In Failed!"),
            backgroundColor: Colors.red,
          ),
          );
    }
  }
  Future<User> signInWithApple({List<apple.Scope>scopes=const[]}) async{
   if(Platform.isIOS){
     final result=await TheAppleSignIn.performRequests(
         [AppleIdRequest(requestedScopes: scopes)]
     );
     switch(result.status){
       case AuthorizationStatus.authorized:
         final AppleIdCredential=result.credential!;
         final oAuthCredential=OAuthProvider('apple.com');
         final credential=oAuthCredential.credential(
             idToken: String.fromCharCodes(AppleIdCredential.identityToken!)
         );
         final UserCredential=await auth.signInWithCredential(credential);
         final firebaseUser=UserCredential.user!;
         if(scopes.contains(apple.Scope.fullName)){
           final fullName=AppleIdCredential.fullName;
           if(fullName!=null && fullName.givenName!=null && fullName.familyName!=null){
             final displayName='${fullName.givenName}${fullName.familyName}';
             await firebaseUser.updateDisplayName(displayName);
           }
         }
         return firebaseUser;
       case AuthorizationStatus.error:
         throw PlatformException(
             code: "Error_Authorization_Denied",
             message: result.error.toString()
         );
       case AuthorizationStatus.cancelled:
         throw PlatformException(
             code:"Error_Aborted_by_User",
             message:"Sign in Aborted by user"
         );
       default:
         throw UnimplementedError();
     }

   }else{
     throw PlatformException(code: "Support_IOS",message:"Supported on IOS only");
   }
}
}
class AppSignIn{
  void clearCookies() async{
    final cookieManager=WebViewCookieManager();
    await cookieManager.clearCookies();
  }
  void linkedSignin(BuildContext context) async{
    final _linkedInConfig = LinkedInConfig(
      clientId: "777vt4yxp6jh22",
      clientSecret:"WPL_AP1.nEg65ON8M0LpWS1a.VTsMWA==",
      redirectUrl: "https://automation.com/auth/linkedin",
      scope: ['openid', 'profile', 'email','w_member_social'],
    );
    SignInWithLinkedIn.signIn(
      context,
      config: _linkedInConfig,
      onGetAuthToken: (data) {
        print('Auth token: ${data.toJson()}');
        // accesstoken=data.toString();
        // TODO: Send data.authCode or data.accessToken to your server
      },
      onGetUserProfile: (data,user)async {
        print("Accesstoken: ${data.accessToken}");
        print("User details: ${user.toString()}");
        user_id=user.sub??'';
        accesstoken=data.accessToken??'';
        try{
          await storePlatformConnection(
              userId: FirebaseAuth.instance.currentUser!.uid,
              platformName: selectedPlatform,
              platformUserId: user.sub!,
              profileName: user.name!,
              profileEmail: user.email!,
              profilePicture:user.picture??'',
              accessToken: data.accessToken??''
          );
        }catch(e){
          print("Exception: ${e}");
          if (e is FirebaseException) {
            print('Firebase Error Code: ${e.code}');
            print('Firebase Error Message: ${e.message}');
          }
        }
        Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
      },
      onSignInError: (error) {
        print('Sign-in error: $error');
      },
    );
  }

}
class YouTubeSignIn extends StatelessWidget{
  final FirebaseAuth _auth=FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn=GoogleSignIn(
      scopes: ['https://www.googleapis.com/auth/youtube.upload']
    );
    Future<void> signInWithGoogle(BuildContext context)async{
      try{
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context)=>Center(child: CircularProgressIndicator(color: Colors.blue,)),);
        await _googleSignIn.signOut();
        final GoogleSignInAccount?googleUser=await _googleSignIn.signIn();
        if(googleUser==null){
          Navigator.pop(context);
          return;
        }
        final GoogleSignInAuthentication googleAuth=await googleUser.authentication;
        final AuthCredential credential=GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
       try {
         final userCredential = await _auth.signInWithCredential(credential);
         final user = userCredential.user;
         if (user != null) {
           await storePlatformConnection(
               userId: user.uid,
               platformName: selectedPlatform,
               platformUserId: googleUser.id,
               profileName: googleUser.displayName ?? '',
               profileEmail: googleUser.email,
               profilePicture: googleUser.photoUrl,
               accessToken: googleAuth.accessToken ?? ''
           );
         }
         Navigator.pop(context);
         Navigator.push(
             context, MaterialPageRoute(builder: (context) => HomePage()));
       }catch(e){
         print("Exception occurred ${e}");
       }
      }catch(e){
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("YouTube sign in failed ${e}"),
              backgroundColor: Colors.red,));
      }
    }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}
class InstagramLoginPage extends StatefulWidget {
  @override
  _InstagramLoginPageState createState() => _InstagramLoginPageState();
}

class _InstagramLoginPageState extends State<InstagramLoginPage> {
  late final WebViewController _controller;

  final String clientId = '851589090414734';
  final String clientSecret = '16ff67397ae943bfafc273c03b3c684e';
  final String redirectUri = 'https://socialmediaautomation-56e23.web.app/';
  final String authUrl =
      'https://www.instagram.com/oauth/authorize?enable_fb_login=0&force_authentication=1&client_id=851589090414734&redirect_uri=https://socialmediaautomation-56e23.web.app/&response_type=code&scope=instagram_business_basic%2Cinstagram_business_manage_messages%2Cinstagram_business_manage_comments%2Cinstagram_business_content_publish%2Cinstagram_business_manage_insights';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print('Page started loading: $url');
            if (url.startsWith(redirectUri)) {
              final uri = Uri.parse(url);
              final code = uri.queryParameters['code'];
              if (code != null) {
                print('Authorization code: $code');
                // Exchange the code for access token
                _fetchAccessToken(code);
                // Stop loading further
                _controller.loadHtmlString('<h3>You can close this page now.</h3>');
              }
            }
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            print('Web resource error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(authUrl));
  }

  Future<void> _fetchAccessToken(String code) async {
    final url = Uri.parse('https://api.instagram.com/oauth/access_token');

    try {
      final response = await http.post(url, body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
        'code': code,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
         final userId = data['user_id'];
       // accesstoken=data['access-token'];
      //  user_id=data['user_id'];
        print('Access Token: $accessToken');
        print('User ID: $userId');

        // Now you can proceed to fetch user info or save token as needed

        // Example: Navigate to home page or show success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        );
        final userInfo = await _fetchUserInfo(accessToken);
        if (userInfo != null) {
          print(userInfo);
          print(accesstoken);
          try{
            await storePlatformConnection(
                userId: FirebaseAuth.instance.currentUser!.uid,
                platformName: selectedPlatform,
                platformUserId: user_id,
                profileName: userInfo['username'],
                profileEmail: '',
                profilePicture:userInfo['profile_picture_url']??'',
                accessToken: accessToken
            );
            accesstoken=accessToken.toString();
            user_id=userId.toString();
            account_id=fetchBusinessAccountId(accessToken).toString();
          }catch(e){
            print("Exception: ${e}");
            if (e is FirebaseException) {
              print('Firebase Error Code: ${e.code}');
              print('Firebase Error Message: ${e.message}');
            }
          }
          Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to fetch user info!')),
          );
        }
        // Close webview or navigate elsewhere

      } else {
        print('Failed to get access token: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get access token')),
        );
      }
    } catch (e) {
      print('Error fetching access token: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching access token')),
      );
    }
  }
  Future<Map<String, dynamic>?> _fetchUserInfo(String accessToken) async {
    final userInfoUrl = Uri.parse(
        'https://graph.instagram.com/me?fields=id,username,account_type,media_count,profile_picture_url&access_token=$accessToken');

    try {
      final response = await http.get(userInfoUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('User info: $data');
        return data;
      } else {
        print('Failed to fetch user info: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching user info: $e');
      return null;
    }
  }
  Future<String?> fetchBusinessAccountId(String accessToken) async {
    final url = Uri.parse('https://graph.facebook.com/v19.0/me/accounts?access_token=$accessToken');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final pages = json.decode(response.body)['data'];
      if (pages.isNotEmpty) {
        final pageId = pages[0]['id'];
        final pageToken = pages[0]['access_token'];

        final pageInfoUrl = Uri.parse('https://graph.facebook.com/v19.0/$pageId?fields=instagram_business_account&access_token=$pageToken');
        final pageInfoResponse = await http.get(pageInfoUrl);

        if (pageInfoResponse.statusCode == 200) {
          final igAccountId = json.decode(pageInfoResponse.body)['instagram_business_account']['id'];
          print('Instagram Business Account ID: $igAccountId');
          return igAccountId;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instagram Login'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
