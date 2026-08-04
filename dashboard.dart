import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_automation/auth.dart';
import 'package:social_media_automation/screens/app_signin.dart';
import 'package:social_media_automation/screens/profile.dart';
import 'package:social_media_automation/screens/welcome_screen.dart';
import 'dart:io';



import 'globals.dart';

class DashboardScreen extends StatefulWidget {
  // final Function(bool) toggleTheme;
  // final bool isDarkMode;

  const DashboardScreen({super.key, });

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  User? user;
  String _userName ="Loading";
  String _userEmail ="Loading";
  File? _profileImage;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    user=FirebaseAuth.instance.currentUser;
    _userName=user?.displayName??"No Name";
    _userEmail=user?.email??"No email";
  }
  // Function to navigate to Edit Profile Screen
  Future<void> _navigateToEditProfile(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentName: _userName,
          currentEmail: _userEmail,
          currentImage: _profileImage,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _userName = result["name"];
        _userEmail = result["email"];
        _profileImage = result["image"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        // backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.blue,
        backgroundColor: Colors.blue,
        title: const Text("Dashboard", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          Builder(
            builder: (context){
              return _buildProfileAvatar(context);
            },
          )
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnectedAccounts(),
          ],
        ),
      ),
    );
  }

  // -------------------- PROFILE AVATAR (TOP RIGHT) -------------------- //
  Widget _buildProfileAvatar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => Scaffold.of(context).openDrawer(),
        child: CircleAvatar(
          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : const AssetImage("assets/profile.jpg") as ImageProvider,
        ),
      ),
    );
  }

  // -------------------- FULL-SCREEN PROFILE DRAWER -------------------- //
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      // backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color:Colors.blue),
            // decoration: BoxDecoration(color: widget.isDarkMode ? Colors.grey[800] : Colors.blue),
            accountName: Text(
              _userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              _userEmail,
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: _profileImage != null ? FileImage(_profileImage!) : const AssetImage("assets/profile.jpg") as ImageProvider,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text("Edit Profile"),
            onTap: () {
              Navigator.pop(context);
              _navigateToEditProfile(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {


              _showLogoutDialog(context);

            },
          ),
        ],
      ),
    );
  }

  // -------------------- CONNECTED ACCOUNTS -------------------- //
  Widget _buildConnectedAccounts() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Connected Accounts",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: socialPlatforms.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal:0), // Equal spacing
                  child: _socialAccountCard(socialPlatforms[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialAccountCard(Map<String, dynamic> platform) {
    return Card(
      color: Colors.grey[100], // Light grey background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: platform["color"].withOpacity(0.1),
                  radius: 24,
                  child: Image.asset(platform["logo"], width: 50, height: 50),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(platform["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      platform["status"],
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: platform["status"] == "Connected"
                    ? Colors.lightBlue[200] // Lighter blue shade for "Manage"
                    : Colors.blue, // Regular blue for "Connect"
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                selectedPlatform=platform["name"];
                // print(name);
                if(selectedPlatform=="LinkedIn"){
                 //LinkedSignInPage().clearCookies();
                  AppSignIn().linkedSignin(context);
                 // Navigator.push(context, MaterialPageRoute(builder: (context) => LinkedSignInPage()),);
                }else if(selectedPlatform=="Instagram"){
                  // AppSignIn().clearCookies();
                  // AppSignIn().instagramSignIn(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => InstagramLoginPage()),);
                }else if(selectedPlatform=="YouTube"){
                  YouTubeSignIn().signInWithGoogle(context);
                }
                else{
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AppSignInScreen(platformName: selectedPlatform),),);
                }

              },
              child: Text(
                platform["status"] == "Connected" ? "Manage" : "Connect",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- LOGOUT DIALOG -------------------- //
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>WelcomeScreen()));
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// -------------------- DUMMY SOCIAL ACCOUNTS DATA -------------------- //
final List<Map<String, dynamic>> socialPlatforms = [
  // {
  //   "logo": "assets/icons/facebook.png",
  //   "name": "Facebook",
  //   "status": "Connect",
  //   "color": Colors.blue,
  // },
  // {
  //   "logo": "assets/icons/twitter.png",
  //   "name": "Twitter",
  //   "status": "Connect",
  //   "color": Colors.lightBlue,
  // },
  {
    "logo": "assets/icons/linkedin.png",
    "name": "LinkedIn",
    "status": "Connect",
    "color": Colors.blueAccent,
  },
  // {
  //   "logo": "assets/icons/google.png",
  //   "name": "Google Business Profile",
  //   "status": "Connect",
  //   "color": Colors.red,
  // },
  {
    "logo": "assets/icons/instagram.png",
    "name": "Instagram",
    "status": "Connect",
    "color": Colors.purple,
  },
  {
    "logo": "assets/icons/youtube.png",
    "name": "YouTube",
    "status": "Connect",
    "color": Colors.redAccent,
  },
];
