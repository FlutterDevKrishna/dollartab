import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPoints extends StatefulWidget {
  const MyPoints({Key? key}) : super(key: key);

  @override
  _MyPointsState createState() => _MyPointsState();
}

class _MyPointsState extends State<MyPoints> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _userName = '';
  int _totalPoints = 0;
  int _userStatus = 0; // 0: Not subscribed, 1: Subscribed

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
        _userStatus = (userData['status'] ?? 0) as int;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        Text(
                          _userName,
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Here are today\'s recommended actions for you.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        SizedBox(height: 24.0),
                        ElevatedButton(
                          onPressed: _userStatus == 0 ? _subscribe : null,
                          child: Text(_userStatus == 0 ? 'Subscribe' : 'Subscribed'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: _userStatus == 0 ? Colors.red : Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            textStyle: TextStyle(fontSize: 16, fontFamily: 'Roboto',color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: CirclePainter(_controller.value),
                                  child: Container(
                                    width: 85.0,
                                    height: 85.0,
                                  ),
                                );
                              },
                            ),
                            Container(
                              width: 70.0,
                              height: 70.0,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.purple, Colors.blue],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _totalPoints.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Total Points',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.0),
              Divider(
                thickness: 1,
                indent: 20,
                endIndent: 20,
                color: Colors.white70,
              ),
              SizedBox(height: 24.0),
              Center(
                child: Text(
                  'Point History',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              SizedBox(height: 24.0),
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

  void _subscribe() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'status': 1});
    setState(() {
      _userStatus = 1;
    });
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
