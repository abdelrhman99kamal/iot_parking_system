import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/components/custom_text_field.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});
  static const String id = 'register';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
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
              'Register',
              style: TextStyle(
                color: Color(0xFF00A63E),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Join',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  ' IOT Parking app',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  ' to find spots easily!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Add your login form or buttons here
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // email TextField
                  CustomTextField(
                    label: 'Name',
                    hint: 'Enter your name',
                    icon: Icons.mail_outline,
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name..!';
                      } else if (value.length < 3) {
                        return 'Please enter a valid name..!';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),

                  // email TextField
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    icon: Icons.mail_outline,
                    controller: _emailController,
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
                    hint: 'ُCreate a password',
                    icon: Icons.lock_outline,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password..!';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters long..!';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  // confirm password TextField
                  CustomTextField(
                    hint: 'Re-enter your password to confirm',
                    icon: Icons.lock_outline,
                    label: 'Confirm Password',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password..!';
                      } else if (value != _passwordController.text) {
                        return 'Passwords don\'t match..!';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 24),
                  // Login Button
                  GestureDetector(
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .createUserWithEmailAndPassword(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );

                          await userCredential.user!.updateDisplayName(
                            nameController.text.trim(),
                          );
                          await userCredential.user!.reload();

                          Navigator.pop(context);
                        } on FirebaseAuthException catch (e) {
                          String message = 'Something went wrong..!';
                          if (e.code == 'weak-password') {
                            message = 'The password provided is too weak.';
                          } else if (e.code == 'email-already-in-use') {
                            message =
                                'The account already exists for that email.';
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
                        } catch (e) {
                          if (context.mounted) {
                            await AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Error',
                              desc: 'Something went wrong: $e',
                            ).show();
                          }
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      margin: EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Color(0xFF00A63E),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      alignment: Alignment.center,
                      height: 60,
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
                  'Already have an account?',
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Login here',
                    style: TextStyle(
                      color: Color(0xFF00A63E),
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
