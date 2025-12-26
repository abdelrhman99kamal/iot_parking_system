import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/components/custom_text_field.dart';
import 'package:parking_app/screens/home_screen.dart';
import 'package:parking_app/screens/register_screen.dart';
import 'package:parking_app/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  static const String id = 'login';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF18181B),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 70),
            Image.asset('assets/images/logo.png', width: 100),
            const SizedBox(height: 12),
            const Text(
              'IOT Parking App',
              style: TextStyle(
                color: Color(0xFF25BAC1),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome back! Please log in to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 40),
            // login form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // email TextField
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    icon: Icons.mail_outline,
                    controller: _emailController,
                    isLoginTheme: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email..!';
                      } else if (!RegExp(r'^.+@.+\..+$').hasMatch(value)) {
                        return 'Please enter a valid email..!';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  // password TextField
                  CustomTextField(
                    label: 'Password',
                    hint: 'ُEnter your password',
                    icon: Icons.lock_outline,
                    controller: _passwordController,
                    isLoginTheme: true,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password..!';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters long..!';
                      }
                      return null;
                    },
                  ),
                  // Forgot Password Button
                  Row(
                    children: [
                      Spacer(),
                      TextButton(
                        onPressed: () async {
                          if (_emailController.text.trim().isEmpty) {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.warning,
                              animType: AnimType.rightSlide,
                              title: 'Missing Email',
                              desc: 'Please enter your email address.',
                            ).show();
                            return;
                          }

                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: _emailController.text.trim(),
                            );

                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.rightSlide,
                              title: 'Password Reset',
                              desc:
                                  'A password reset link has been sent to your email.',
                            ).show();
                          } catch (e) {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Error',
                              desc:
                                  'Please make sure the email you entered is correct!',
                            ).show();
                          }
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Login Button
                  GestureDetector(
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final user = await AuthService.signIn(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );

                          if (user != null) {
                            if (user.emailVerified) {
                              if (context.mounted) {
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed(HomeScreen.id);
                              }
                            } else {
                              await user.sendEmailVerification();
                              await AuthService.signOut();

                              if (context.mounted) {
                                await AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.warning,
                                  animType: AnimType.rightSlide,
                                  title: 'Email Verification Required',
                                  desc:
                                      'A verification link has been sent to your email. Please verify before logging in.',
                                ).show();
                              }
                            }
                          } else {
                            throw FirebaseAuthException(
                              code: 'unknown-error',
                              message: 'Error occurred',
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          String message;
                          if (e.code == 'user-not-found') {
                            message = 'No user found for that email.';
                          } else if (e.code == 'wrong-password') {
                            message = 'Wrong password provided for that user.';
                          } else {
                            message =
                                'An unexpected error occurred. Please try again later.';
                          }

                          if (context.mounted) {
                            await AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Error',
                              desc: message,
                            ).show();
                          }
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      margin: EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Color(0xFF25BAC1),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      alignment: Alignment.center,
                      height: 60,
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // OR Divider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white24,
                          thickness: 1,
                          indent: 18,
                          endIndent: 8,
                        ),
                      ),

                      Text('  OR  ', style: TextStyle(color: Colors.white38)),

                      Expanded(
                        child: Divider(
                          color: Colors.white24,
                          thickness: 1,
                          indent: 8,
                          endIndent: 18,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Continue with Google Button
                  GestureDetector(
                    onTap: () async {
                      try {
                        final userCredential =
                            await AuthService.signInWithGoogle();

                        if (userCredential != null &&
                            userCredential.user != null) {
                          print("Signed in as: ${userCredential.user!.email}");

                          // Navigate to the next page
                          Navigator.pushReplacementNamed(
                            context,
                            HomeScreen.id,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          AwesomeDialog(
                            context: context,
                            title: "Error",
                            desc: e.toString(),
                          ).show();
                        }
                        print("Login failed: $e");
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      margin: EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Color(0xFF14355E),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      alignment: Alignment.center,
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/google_icon.png',
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Continue with Google',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        color: Color(0xFF18181B),
        alignment: Alignment.center,
        child: Column(
          children: [
            Divider(color: Colors.white12, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account?',
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RegisterScreen.id);
                  },
                  child: Text(
                    'Register here',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
