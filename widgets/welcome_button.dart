import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  const WelcomeButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    required this.color,
    required this.textColor,
  });

  final String buttonText;
  final VoidCallback onTap; // ✅ Fixed: should be a function, not a Widget
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // ✅ Calls the function passed as onTap
      child: Container(
        padding: const EdgeInsets.all(20.0), // ✅ Reduced padding for better UI
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30), // ✅ Improved rounded corners
        ),
        child: Center(
          child: Text(
            buttonText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}