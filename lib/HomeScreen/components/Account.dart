import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:userdollartab/Users/Users.dart';
import 'accountSection/FeedbackSection.dart';
import 'accountSection/TrackingReferralCode.dart';
import 'accountSection/ProfileEditScreen.dart';
import 'accountSection/Security.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String? _imageUrl;
  String? _referralCode;
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No data available'));
          }

          var userDoc = snapshot.data!;
          _imageUrl = userDoc['profileImageUrl'] ?? 'https://img.freepik.com/free-vector/blue-circle-with-white-user_78370-4707.jpg?size=626&ext=jpg&ga=GA1.1.749980426.1716019043&semt=ais';
          _referralCode = userDoc['referralCode'];
          _userName = userDoc['name'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageUrl != null
                        ? NetworkImage(_imageUrl!)
                        : AssetImage('assets/images/man.png') as ImageProvider,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    _userName ?? 'Loading...',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Referral Code: ${_referralCode ?? 'Loading...'}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white70,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        buildListTile(Icons.person, 'Profile', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfileEditScreen()),
                          );
                        }),
                        buildDivider(),
                        buildListTile(Icons.share, 'Tracking Referral Code', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TrackingReferralCode()),
                          );
                        }),
                        buildDivider(),
                        buildListTile(Icons.security, 'Security', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Security()),
                          );
                        }),
                        buildDivider(),
                        buildListTile(Icons.feedback, 'Share Your Feedback', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FeedbackSection()),
                          );
                        }),
                        buildDivider(),
                        buildListTile(Icons.logout, 'Logout', () {
                          FirebaseAuth.instance.signOut().then((_) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => UserScreen()),
                            );
                          });
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  ListTile buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.white),
      onTap: onTap,
    );
  }
}
