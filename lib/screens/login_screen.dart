import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../localization/localization.dart';
import 'signup_screen.dart'; // Replace with your actual sign-up screen
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        Navigator.pushReplacementNamed(
            context, '/home_screen'); // Replace with your home screen route
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage =
                LocalizationHelper.translate(context, 'error_user_not_found');
            break;
          case 'wrong-password':
            errorMessage =
                LocalizationHelper.translate(context, 'error_wrong_password');
            break;
          default:
            errorMessage =
                LocalizationHelper.translate(context, 'error_generic');
        }
        _showErrorDialog(errorMessage);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _googleSignIn() async {
    try {
      // Initialize GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Navigate to the home screen upon successful sign-in
      Navigator.pushReplacementNamed(context, '/home_screen');
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocalizationHelper.translate(context, 'error_generic')),
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(LocalizationHelper.translate(context, 'error_title')),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(LocalizationHelper.translate(context, 'ok')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationHelper.translate(context, 'login')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: LocalizationHelper.translate(context, 'email'),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocalizationHelper.translate(
                        context, 'error_email_required');
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return LocalizationHelper.translate(
                        context, 'error_invalid_email');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: LocalizationHelper.translate(context, 'password'),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocalizationHelper.translate(
                        context, 'error_password_required');
                  }
                  if (value.length < 6) {
                    return LocalizationHelper.translate(
                        context, 'error_password_length');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Implement forgot password logic
                    showDialog(
                      context: context,
                      builder: (context) {
                        final emailController = TextEditingController();
                        return AlertDialog(
                          title: Text(LocalizationHelper.translate(
                              context, 'reset_password_title')),
                          content: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: LocalizationHelper.translate(
                                  context, 'email'),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(LocalizationHelper.translate(
                                  context, 'cancel')),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await FirebaseAuth.instance
                                      .sendPasswordResetEmail(
                                    email: emailController.text.trim(),
                                  );
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          LocalizationHelper.translate(
                                              context, 'password_reset_sent')),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          LocalizationHelper.translate(
                                              context, 'error_password_reset')),
                                    ),
                                  );
                                }
                              },
                              child: Text(LocalizationHelper.translate(
                                  context, 'send')),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                      LocalizationHelper.translate(context, 'forgot_password')),
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      child:
                          Text(LocalizationHelper.translate(context, 'login')),
                    ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(LocalizationHelper.translate(context, 'or')),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _googleSignIn,
                icon: SvgPicture.asset(
                  '../assets/icons/google_icon.svg', // Path to your SVG icon
                  height: 24,
                  width: 24,
                ),
                label: Text(
                    LocalizationHelper.translate(context, 'google_sign_in')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(LocalizationHelper.translate(context, 'need_account')),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()),
                      );
                    },
                    child:
                        Text(LocalizationHelper.translate(context, 'signup')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
