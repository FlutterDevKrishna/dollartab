import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:userdollartab/Users/Users.dart';
import '../constants.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool _isChecked = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _inviteController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _inviteController.dispose();
    super.dispose();
  }

  String _generateReferralCode() {
    const length = 8;
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
            (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
  }

  Future<String?> getUserIdFromReferralCode(String inviteCode) async {
    try {
      QuerySnapshot referralUserQuery = await FirebaseFirestore.instance.collection('users').where('referralCode', isEqualTo: inviteCode).limit(1).get();
      if (referralUserQuery.docs.isNotEmpty) {
        return referralUserQuery.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Error getting user ID from referral code: $e');
      return null;
    }
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_isChecked == true) {
        setState(() {
          _isLoading = true;
        });

        try {
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          String referralCode = _generateReferralCode();
          String inviteCode=_inviteController.text.trim();
          // Check if referral code is provided
          if (referralCode.isNotEmpty) {
            // Fetch the user document with the provided referral code
            String? referralUserId = await getUserIdFromReferralCode(inviteCode);
            if (referralUserId != null) {
              // Referral user found, give them 50 points
              await FirebaseFirestore.instance.collection('users').doc(referralUserId).update({'points': FieldValue.increment(50)});

              // Fetch current points for the referral user
              DocumentSnapshot referralUserSnapshot = await FirebaseFirestore.instance.collection('users').doc(referralUserId).get();
              int referralUserPoints = referralUserSnapshot['points'];

              // Increment points for the referral user
              int updatedReferralUserPoints = referralUserPoints;





              // Add transaction record for the referral user
              await FirebaseFirestore.instance.collection('users').doc(referralUserId).collection('transactions').add({
                'date': Timestamp.now(),
                'redeemPoints': 0,
                'earnPoints': 5,
                'balancePoints': updatedReferralUserPoints,
                'type': 'invite',
              });
              // Add transaction record for the new user
              await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).collection('transactions').add({
                'date': Timestamp.now(),
                'redeemPoints': 0,
                'earnPoints': 15,
                'balancePoints': FieldValue.increment(100),
                'type': 'New',
              });
              // Add user data to Firestore
              await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                'name': _nameController.text.trim(),
                'email': _emailController.text.trim(),
                'mobile': _phoneController.text.trim(),
                'profileImageUrl':'',
                'referralCode': referralCode,
                'inviteCode': inviteCode,
                'points': 15,
                'status':'0',
                'date':Timestamp.now()
              });
            }
            else{

              // Add user data to Firestorage without invite code
              await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                'name': _nameController.text.trim(),
                'email': _emailController.text.trim(),
                'mobile': _phoneController.text.trim(),
                'profileImageUrl':'',
                'referralCode': referralCode,
                'points': 0,
                'status':0,
                'date':Timestamp.now()
              });
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Signup Successful',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserScreen(),));
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text(e.message!)));
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please agree to the Terms and Conditions')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 690,
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
      margin: EdgeInsets.all(8),
      width: 680,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.all(8),
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
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.red),
                    prefixIcon: Icon(Icons.person, color: Colors.red),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (!RegExp(r"^[a-zA-Z\s'`-]+$").hasMatch(value)) {
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone No',
                    labelStyle: TextStyle(color: Colors.red),
                    prefixIcon: Icon(Icons.phone, color: Colors.red),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!RegExp(r'^\+?[0-9 ]{7,15}$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.red),
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
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.red),
                    prefixIcon: Icon(Icons.lock, color: Colors.red),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
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
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.yellow[900],
                        ),
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Referral Code',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            TextField(
                              controller: _inviteController,
                              maxLength: 8,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                counterText: "",
                                filled: true,
                                fillColor: Colors.white,

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                              ),
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 16.0,  // Increase space between characters
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                CheckboxListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('I agree to the ',
                          style: TextStyle(fontSize: 12, color: Colors.black)),
                      GestureDetector(
                          onTap: () {
                            _showMyDialog(context);
                          },
                          child: Text('Terms And Conditions',
                              style:
                              TextStyle(color: Colors.red, fontSize: 12))),
                    ],
                  ),
                  value: _isChecked,
                  activeColor: AppColors.yellow900,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                SizedBox(height: 20.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: AppColors.yellow900,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.black)
                        : Text('SIGN UP',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black)),
                  ),
                ),
                SizedBox(height: 12.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _showMyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
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
              Text(
                'Terms & Conditions',
                style: TextStyle(
                    color: AppColors.yellow900,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "The Dollar Tab mobile application Terms and Conditions require users to be at least 18 years old and maintain the confidentiality of their accounts, prohibiting illegal use. Users retain ownership of submitted content but grant the app a license to use it. The app's intellectual property is owned by the company, and its use is subject to the Privacy Policy. The app is provided as is, without warranties, and the company is not liable for damages. The company reserves the right to modify the terms, and users agree to the new terms by continuing to use the app. These Terms and Conditions are governed by the laws of the relevant jurisdiction, and any questions can be directed to the company via email.",
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  "The company reserves the right to take appropriate action, including removing content and suspending or terminating accounts, for violations of these Terms and Conditions. By using the app, users agree to abide by these rules and accept the consequences of non-compliance.",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: Container(
                width: 200,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.yellow900),
                  onPressed: () {
                    setState(() {
                      _isChecked = true;
                    });
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('I Agree',style: TextStyle(color: Colors.black),),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
