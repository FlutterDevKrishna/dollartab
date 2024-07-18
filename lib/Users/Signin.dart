import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:userdollartab/HomeScreen/Home.dart';
import '../constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:html'; // Add this import for web-specific APIs

class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailResendController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscureText = true;
  bool _isLoading = false; // New variable to control loading state


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        // Check if the user exists in Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // If userCredential is null, the user does not exist
        if (userCredential == null) {
          throw FirebaseAuthException(code: 'user-not-found', message: 'No user found with this email. Please register.');
        }

        String uid = userCredential.user!.uid;
        print('User UID: $uid');

        // Save the user's UID to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('uid', uid);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully signed in!')),
        );

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      } on FirebaseAuthException catch (e) {
        String errorMessage;

        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'The email address is badly formatted.';
            break;
          case 'user-disabled':
            errorMessage = 'This user has been disabled.';
            break;
          case 'user-not-found':
            errorMessage = 'No user found with this email. Please register.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password provided.';
            break;
          default:
            errorMessage = 'An unexpected error occurred. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }




  void _resetPassword() async {
    if( _emailResendController.text.trim().isNotEmpty)
      {
        try {
          await _auth.sendPasswordResetEmail(email: _emailResendController.text.trim());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Password reset email sent',style: TextStyle(color: Colors.white),),
            ),
          );
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(e.message ?? 'An error occurred',style: TextStyle(color: Colors.white),),
            ),
          );
        }
      }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red,
          content: Text('Enter Valid Email Address',style: TextStyle(color: Colors.white),),
        ),
      );
    }

  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(8),
      width: 380,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Colors.red),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: Colors.red),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  obscureText: _obscureText,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _showForgotPasswordDialog(context);
                    },
                    child: const Text('Forgot Password?',
                        style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: double.infinity,
                  child:ElevatedButton(
                    onPressed: _isLoading ? null : _signIn, // Disable button when loading
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: AppColors.yellow900,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.black) // Show loading indicator
                        : const Text('SIGN IN', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 8,
              ),
              const Text(
                'FORGOT PASSWORD',
                style: TextStyle(color: AppColors.yellow900, fontSize: 16),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: _emailResendController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Colors.red),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                Container(
                  child: const Text(
                      'Your New Password Valid for 10 Minutes Only.',
                      style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your forgot password logic here
                      _resetPassword();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow900,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('GET PASSWORD',
                        style: TextStyle(fontWeight: FontWeight.w800,color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
