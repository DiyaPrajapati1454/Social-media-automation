import 'package:flutter/material.dart';
import 'package:social_media_automation/screens/signin_screen.dart';
import 'package:social_media_automation/screens/signup_screen.dart';
import 'package:social_media_automation/widgets/custom_scaffold.dart';
import 'package:social_media_automation/widgets/welcome_button.dart';
import 'package:social_media_automation/themes/theme.dart'; // Ensure lightColorScheme is defined

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Welcome Back!\n',
                          style: TextStyle(
                            fontSize: 45.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: '\nAI-powered content automation for seamless scheduling and optimization.',
                          style: TextStyle(fontSize: 20, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 30, // ✅ Adjusted position to place the buttons correctly
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: WelcomeButton(
                    buttonText: 'Sign in',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignInScreen()),
                      );
                    },
                    color: Colors.transparent,
                    textColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: WelcomeButton(
                    buttonText: 'Sign up',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    color: Colors.white,
                    textColor: lightColorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}