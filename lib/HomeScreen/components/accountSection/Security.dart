import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constants.dart';

class Security extends StatefulWidget {
  const Security({Key? key}) : super(key: key);

  @override
  _SecurityState createState() => _SecurityState();
}

class _SecurityState extends State<Security> {
  late bool _isSaving;
  late TextEditingController _newPasswordController;
  late TextEditingController _reEnterPasswordController;
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isReEnterPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _isSaving = false;
    _newPasswordController = TextEditingController();
    _reEnterPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _reEnterPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updatePassword(_newPasswordController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password changed successfully'),
              backgroundColor: AppColors.primaryColor,
            ),
          );
          _newPasswordController.clear();
          _reEnterPasswordController.clear();
        }
      } catch (error) {
        print('Error changing password: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change password'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isSaving = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? _validateReEnterPassword(String? value) {
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text('Security', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          margin: EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Password',
                    style: TextStyle(
                      color: AppColors.yellow900,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _reEnterPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Re-Enter New Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isReEnterPasswordVisible ? Icons.visibility : Icons.visibility_off,color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            _isReEnterPasswordVisible = !_isReEnterPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_isReEnterPasswordVisible,
                    validator: _validateReEnterPassword,
                  ),
                  const SizedBox(height: 24.0),
                  _isSaving
                      ? Center(
                    child: CircularProgressIndicator(),
                  )
                      : Center(
                    child: SizedBox(
                      width: 200,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _changePassword,
                        child: Text(
                          'Save & Update',
                          style: TextStyle(fontSize: 18.0, color: AppColors.primaryTextColor),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
