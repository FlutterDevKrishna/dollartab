import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';

class FortuneWheelPage extends StatefulWidget {
  @override
  _FortuneWheelPageState createState() => _FortuneWheelPageState();
}

class _FortuneWheelPageState extends State<FortuneWheelPage> {
  final StreamController<int> _selectedController = StreamController<int>.broadcast();
  late Stream<int> selected;
  int playCount = 0;
  int points = 100; // Assuming the user starts with 100 points, adjust as needed
  DateTime lastPlayTime = DateTime.now().subtract(Duration(days: 1)); // Initialize to more than 24 hours ago

  final List<String> items = [
    '1 Points',
    '3 Points',
    '5 Points',
    '2 Points',
    '8 Points',
    '7 Points',
    '1 Points',
    '3 Points',
    '5 Points',
    '2 Points',
    '8 Points',
    '7 Points',

  ];

  @override
  void initState() {
    super.initState();
    selected = _selectedController.stream.asBroadcastStream();
    _loadUserData();
    selected.listen((index) async {
      final result = items[index].toString();
      print('Chance To Win');
      await Future.delayed(Duration(seconds: 5)); // Delay for 3 seconds
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Congratulations!',
            style: TextStyle(
              color: Colors.green,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'You have won $result points',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async{
                  Navigator.of(context).pop();
                  String userId = FirebaseAuth.instance.currentUser!.uid;
                  print(userId);
                  DocumentReference<Map<String, dynamic>> userRef =
                  FirebaseFirestore.instance.collection('users').doc(userId);
                  int points = int.parse(result.split(' ')[0]);
                  await userRef.update({
                    'points': FieldValue.increment(points),
                  });

                  // Get updated user points
                  DocumentSnapshot<Map<String, dynamic>> updatedUserSnapshot = await userRef.get();

                  // Record the transaction in Firestore
                  await userRef.collection('transactions').add({
                    'date': Timestamp.now(),
                    'type': 'Spin',
                    'earnPoints': points,
                    'redeemPoints': 0,
                    'balancePoints': updatedUserSnapshot.data()!['points'], // Use updated user points
                  });



              },
              child: Text('OK'),
            ),
          ],
        ),
      );

      setState(() {
        points += int.parse(result.split(' ')[0]);
      });

      _updateUserData();
    });
  }

  @override
  void dispose() {
    _selectedController.close();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      playCount = prefs.getInt('playCount') ?? 0;
      lastPlayTime = DateTime.tryParse(prefs.getString('lastPlayTime') ?? '') ?? DateTime.now().subtract(Duration(days: 1));
      points = prefs.getInt('points') ?? 100;
    });
  }

  Future<void> _updateUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('playCount', playCount);
    await prefs.setString('lastPlayTime', lastPlayTime.toIso8601String());
    await prefs.setInt('points', points);
  }

  void _handleSpin() {
    DateTime now = DateTime.now();
    if (now.difference(lastPlayTime).inHours >= 24) {
      playCount = 0; // Reset play count after 24 hours
    }

    if (playCount < 3) {
      if (playCount == 0 || points >= 10) {
        if (playCount > 0) {
          points -= 10; // Deduct points for the 2nd and 3rd play
        }
        playCount++;
        lastPlayTime = now;
        _updateUserData();
        _selectedController.add(Fortune.randomInt(0, items.length));
      } else {
        // Not enough points
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Not enough points to play.')),
        );
      }
    } else {
      // Play limit reached
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have reached the play limit for today.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text('Spin Wheel', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: FortuneWheel(
                selected: selected,
                items: [
                  for (var it in items) FortuneItem(child: Text(it)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleSpin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // background color
                ),
                child: Text('Play',style: TextStyle(color: Colors.white),),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
