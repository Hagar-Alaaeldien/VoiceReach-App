import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../localization/localization.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showErrorDialog(
            LocalizationHelper.translate(context, 'error_password_mismatch'));
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Navigate to Home Screen
        Navigator.pushReplacementNamed(
            context, '/home_screen'); // Use your HomeScreen route
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage =
                LocalizationHelper.translate(context, 'error_email_in_use');
            break;
          case 'weak-password':
            errorMessage =
                LocalizationHelper.translate(context, 'error_weak_password');
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
        title: Text(LocalizationHelper.translate(context, 'signup')),
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
                  border: const OutlineInputBorder(),
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
                  border: const OutlineInputBorder(),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText:
                      LocalizationHelper.translate(context, 'confirm_password'),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocalizationHelper.translate(
                        context, 'error_confirm_password_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _signUp,
                      child:
                          Text(LocalizationHelper.translate(context, 'signup')),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Navigate back to Login
                },
                child: Text(
                    LocalizationHelper.translate(context, 'back_to_login')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
