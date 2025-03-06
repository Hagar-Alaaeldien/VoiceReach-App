import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../localization/localization.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay for 2 seconds before checking login state
    Future.delayed(const Duration(seconds: 2), () {
      _checkLoginState();
    });
  }

  // Check Firebase Authentication login state
  void _checkLoginState() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is logged in, navigate to Home Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // User is not logged in, stay on Splash Screen
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF23395B), // Dark blue background
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
        children: [
          // Top Decorative Shapes
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  left: -50,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: const Color(0xFF9ECAFE), // Light purple
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 50,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFA5D6A7), // Light green
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 30,
                  child: Transform.rotate(
                    angle: 0.7854, // Rotate 45 degrees
                    child: Container(
                      height: 50,
                      width: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50), // Increased spacing to move text down

          // Welcome Text
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add horizontal padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationHelper.translate(context, 'welcome_message'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    LocalizationHelper.translate(context, 'subtitle_message'),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20), // Additional spacing before the button

          // Get Started Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add horizontal padding
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationHelper.translate(context, 'get_started'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    height: 2,
                    width: 100,
                    color: const Color(0xFFA5D6A7), // Light green underline
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
