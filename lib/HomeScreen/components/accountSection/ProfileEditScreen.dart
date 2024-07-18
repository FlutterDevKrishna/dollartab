import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:userdollartab/constants.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late String _uid;
  String? _profileImageUrl;
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  String _gender = 'male'; // Default gender value

  @override
  void initState() {
    super.initState();
    getUid();
  }

  void getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _uid = prefs.getString('uid') ?? '';
    });
    getUserDetails();
  }

  void getUserDetails() async {
    if (_uid.isEmpty) return;

    FirebaseFirestore.instance.collection('users').doc(_uid).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _mobileController.text = data['mobile'] ?? '';
          _emailController.text = data['email'] ?? '';
          _addressController.text = data['address'] ?? '';
          _cityController.text = data['city'] ?? '';
          _stateController.text = data['state'] ?? '';
          _gender = data['gender'] ?? 'male'; // Default to male if gender is not set
          _profileImageUrl = data['profileImageUrl'];
        });
      } else {
        print('Document does not exist on the database');
      }
    }).catchError((error) {
      print('Error getting document: $error');
    });
  }

  Future<void> uploadImage(XFile pickedFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/$_uid.jpg');
      final uploadTask = storageRef.putFile(File(pickedFile.path));
      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();

      updateUserDetails(imageUrl);
      setState(() {
        _profileImageUrl = imageUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void updateUserDetails(String? imageUrl) async {
    if (_uid.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> userData = {
      'name': _nameController.text,
      'mobile': _mobileController.text,
      'email': _emailController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'gender': _gender,
      if (imageUrl != null) 'profileImageUrl': imageUrl,
    };

    FirebaseFirestore.instance.collection('users').doc(_uid).update(userData).then((_) {
      print('User updated successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    }).catchError((error) {
      print('Failed to update user: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(20),
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : AssetImage('assets/images/avatar.png') as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            onPressed: () async {
                              final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                uploadImage(pickedFile);
                              }
                            },
                            icon: Icon(Icons.camera_alt),
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person, color: Colors.red),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _mobileController,
                    decoration: InputDecoration(
                      labelText: 'Mobile',
                      prefixIcon: Icon(Icons.phone, color: Colors.red),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Colors.red),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.home, color: Colors.red),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      prefixIcon: Icon(Icons.location_city, color: Colors.red),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _stateController,
                    decoration: InputDecoration(
                      labelText: 'State',
                      prefixIcon: Icon(Icons.maps_home_work, color: Colors.red),
                    ),
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    title: Text('Gender'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio(
                          value: 'male',
                          groupValue: _gender,
                          onChanged: (value) {
                            setState(() {
                              _gender = value.toString();
                            });
                          },
                        ),
                        Text('Male'),
                        Radio(
                          value: 'female',
                          groupValue: _gender,
                          onChanged: (value) {
                            setState(() {
                              _gender = value.toString();
                            });
                          },
                        ),
                        Text('Female'),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        updateUserDetails(null);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor, // background color
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                          : Text(
                        'Update & Save',
                        style: TextStyle(color: AppColors.primaryTextColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }
}
