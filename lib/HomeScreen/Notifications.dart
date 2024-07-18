import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constants.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
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
    _loadCurrentUserReferralCode();
  }

  void _loadCurrentUserReferralCode() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();
    setState(() {
      currentUserReferralCode = userDoc['referralCode'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Container(
                width: 300,
                height: 300,
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
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue.shade50,
                              child: Icon(Icons.account_circle, size: 40, color: Colors.blue.shade800),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userData['name'] ?? 'No Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    userData['email'] ?? 'No Email',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16, color: Colors.blue.shade800),
                                      SizedBox(width: 4),
                                      Text(
                                        'Joined on ${_formatDate(userData['date'])}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Divider(color: Colors.grey.shade300),
                        SizedBox(height: 16),
                        Text(
                          'Last two transactions:',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(snapshot.data!.docs[index].id)
                              .collection('transactions')
                              .orderBy('date', descending: true)
                              .limit(2)
                              .snapshots(),
                          builder: (context, transactionSnapshot) {
                            if (transactionSnapshot.hasData) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: transactionSnapshot.data!.docs.map((doc) {
                                  var transactionData = doc.data() as Map<String, dynamic>;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      'Type: ${transactionData['type']}, Points: ${transactionData['earnPoints']}',
                                      style: TextStyle(
                                        color: Colors.green.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
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

  Object _formatDate(dynamic date) {
    if (date is Timestamp) {
      return '${date.toDate().day}/${date.toDate().month}/${date.toDate().year}';
    } else {
      return Center(
        child: Container(
          width: 300,
          height: 300,
          child: Image.asset('assets/images/page-not-found.png'),
        ),
      );

    }
  }
}
