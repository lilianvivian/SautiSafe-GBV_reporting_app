import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;

  // --- Life-cycle Enhancement ---
  // Always dispose of controllers to prevent memory leaks
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // --- Main Logic ---
  Future<void> _resetPassword() async {
    // Prevent multiple submissions while loading
    if (_loading) return;

    final email = _emailController.text.trim();

    // Let Firebase handle email validation, we just check for empty
    if (email.isEmpty) {
      _showErrorDialog("Please enter your email address.");
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      
      // Use our new success dialog
      _showSuccessDialog(
        "Password reset link sent! Please check your email inbox (and spam folder).",
      );

    } on FirebaseAuthException catch (e) {
      // --- Error Handling Enhancement ---
      // Translate complex error codes into user-friendly messages
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user was found for that email. Please check your spelling or sign up.";
          break;
        case 'invalid-email':
          errorMessage = "The email address is not valid. Please enter a valid email.";
          break;
        default:
          errorMessage = "An error occurred. Please try again.";
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog("Something went wrong. Please try again.");
    } finally {
      // This will run whether it succeeds or fails
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // --- User Feedback Enhancement ---
  // A clean, modal dialog for success
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button
      builder: (ctx) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
              Navigator.of(context).pop(); // Go back to the login screen
            },
          ),
        ],
      ),
    );
  }

  // A clean, modal dialog for errors
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- UI Enhancement ---
              // Added an icon for better visual cue
              Icon(
                Icons.lock_reset,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter your registered email to receive a password reset link.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                // Disable field while loading
                enabled: !_loading, 
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                // --- Loading State Enhancement ---
                // Disable button when loading, but don't remove it
                onPressed: _loading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: _loading
                    // Show loader inside the button
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text('Send Reset Link'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}