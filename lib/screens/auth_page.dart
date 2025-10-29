import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'forgot_password_page.dart'; // --- NEW: Import this page ---

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() => _loading = true);

    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful!')),
          );
        }

        //Go to HomePage after login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully!')),
          );
        }

        // Go to HomePage after sign-up
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message ?? e.code}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // --- REMOVED the _resetPassword function ---
  // It's now handled by forgot_password_page.dart

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up'),
        backgroundColor: const Color(0xFF7A3E9D),
      ),
      backgroundColor: const Color(0xFFF6F2FB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            // Added AutofillGroup ---
            child: AutofillGroup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Added Icon ---
                  Icon(
                    Icons.lock_person,
                    size: 60,
                    color: const Color(0xFF7A3E9D),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLogin
                        ? 'Welcome back! Please log in.'
                        : 'Create your account below.',
                    style: const TextStyle(
                        fontSize: 16, color: Color(0xFF5B2C6F)),
                  ),
                  const SizedBox(height: 20),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _submitAuthForm,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // ---
                  // --- THIS BLOCK IS NOW SYNTACTICALLY CORRECT ---
                  // ---
                  // Forgot Password (visible only in login mode)
                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ), // Close MaterialPageRoute
                          ); // Close Navigator.push
                        }, // Close onPressed
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Color(0xFF7A3E9D)),
                        ),
                      ), // Close TextButton
                    ), // Close Align

                  const SizedBox(height: 10),

                  // Submit Button
                  _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submitAuthForm,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8E44AD),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 12),
                              textStyle: const TextStyle(fontSize: 16)),
                          child: Text(
                            _isLogin ? 'Login' : 'Sign Up',
                          ),
                        ),
                  const SizedBox(height: 10),

                  // Toggle between login & sign-up
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin
                          ? 'Don\'t have an account? Sign Up'
                          : 'Already have an account? Login',
                      style: const TextStyle(color: Color(0xFF7A3E9D)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ); // Close Scaffold
  }
}

