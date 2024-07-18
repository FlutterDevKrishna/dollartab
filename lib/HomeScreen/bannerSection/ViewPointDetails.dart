import 'package:flutter/material.dart';
import '../../constants.dart';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewPointDetails extends StatefulWidget {
  const ViewPointDetails({Key? key}) : super(key: key);

  @override
  State<ViewPointDetails> createState() => _ViewPointDetailsState();
}

class _ViewPointDetailsState extends State<ViewPointDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text('Points Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: MyPointsDetails(),
    );
  }
}


class MyPointsDetails extends StatefulWidget {
  const MyPointsDetails({Key? key}) : super(key: key);

  @override
  _MyPointsState createState() => _MyPointsState();
}

class _MyPointsState extends State<MyPointsDetails> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _userName = '';
  int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fetchUserData().then((userData) {
      setState(() {
        _userName = userData['name'] ?? 'User';
        _totalPoints = (userData['points'] ?? 0) as int;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
    return userData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchPointsHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<Map<String, dynamic>> pointsHistory = snapshot.data ?? [];
                    if (pointsHistory.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            Icon(Icons.history, size: 100, color: Colors.white70),
                            SizedBox(height: 10),
                            Text(
                              'No data found',
                              style: TextStyle(color: Colors.white70, fontSize: 20),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: pointsHistory.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> transaction = pointsHistory[index];
                        return PointHistoryItem(
                          date: transaction['date'],
                          earnedPoints: transaction['earnedPoints'] ?? 0,
                          redeemedPoints: transaction['redeemedPoints'] ?? 0,
                          balancePoints: transaction['balancePoints'] ?? 0,
                          type: transaction['type'] ?? 'Unknown',
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> _fetchPointsHistory() async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  QuerySnapshot historySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('transactions')
      .orderBy('date', descending: true)
      .get();
  List<Map<String, dynamic>> pointsHistory = historySnapshot.docs.map((doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return {
      'date': data['date'],
      'earnedPoints': data['earnPoints'] ?? 0,
      'redeemedPoints': data['redeemPoints'] ?? 0,
      'type': data['type'] ?? 'Unknown',
      'redeemedPoints': data['redeemPoints'] ?? 0,
      'balancePoints': data['balancePoints'] ?? 0,
    };
  }).toList();
  return pointsHistory;
}
class PointHistoryItem extends StatelessWidget {
  final Timestamp date;
  final int earnedPoints;
  final int redeemedPoints;
  final int balancePoints;
  final String type;

  const PointHistoryItem({
    Key? key,
    required this.date,
    required this.earnedPoints,
    required this.redeemedPoints,
    required this.balancePoints,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date.toDate().toString(), // Convert Timestamp to String
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Earned ',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        earnedPoints > 0 ? "+${earnedPoints.toString()}" : "",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.green,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type ',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        type.toString(),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Redeemed',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        redeemedPoints > 0 ? "-${redeemedPoints.toString()}" : "",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.red,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        balancePoints.toString(),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double _animationValue;

  CirclePainter(this._animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blue, Colors.purple, Colors.pink], // Use your preferred colors
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final radius = size.width / 2;
    final sweepAngle = 2 * pi * _animationValue;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
