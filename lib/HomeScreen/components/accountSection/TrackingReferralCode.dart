import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constants.dart';

class TrackingReferralCode extends StatefulWidget {
  const TrackingReferralCode({Key? key}) : super(key: key);

  @override
  State<TrackingReferralCode> createState() => _TrackingReferralCodeState();
}

class _TrackingReferralCodeState extends State<TrackingReferralCode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text('Tracking Referral Code', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: ReferralUsersList(),
    );
  }
}

class ReferralUsersList extends StatefulWidget {
  const ReferralUsersList({Key? key}) : super(key: key);

  @override
  State<ReferralUsersList> createState() => _ReferralUsersListState();
}

class _ReferralUsersListState extends State<ReferralUsersList> {
  late final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  late String currentUserReferralCode = '';

  @override
  void initState() {
    super.initState();
    getUserReferralCode();
  }

  void getUserReferralCode() async {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
    await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();
    String _currentUserReferralCode = userDoc.data()!['referralCode'] ?? '';
    setState(() {
      currentUserReferralCode = _currentUserReferralCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').where('inviteCode', isEqualTo: currentUserReferralCode).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return  Center(
              child: Container(
                width: 300,
                height:300,
                child: Image.asset('assets/images/page-not-found.png'),
              ),
            );
          }

          return Container(
            padding: EdgeInsets.all(16),

            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var userData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.account_circle, size: 40, color: Colors.blue),
                    ),
                    title: Text(
                      userData['name'] ?? 'No Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userData['email'] ?? 'No Email'),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.arrow_right, size: 20, color: Colors.blue),
                            Text(
                              'Joined on ${_formatDate(userData['date'])}',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return '${date.toDate().day}/${date.toDate().month}/${date.toDate().year}';
    } else {
      return 'Date not available';
    }
  }
}
