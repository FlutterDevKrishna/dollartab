import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratcher/scratcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';

class ScratchPage extends StatefulWidget {
  const ScratchPage({Key? key}) : super(key: key);

  @override
  State<ScratchPage> createState() => _ScratchPageState();
}

class _ScratchPageState extends State<ScratchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text('Scratch Card', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: ChangeNotifierProvider(
        create: (context) => ScratchCardState(),
        child: CouponScreen(),
      ),
    );
  }
}

class CouponScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Consumer<ScratchCardState>(
        builder: (context, scratchCardState, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (scratchCardState.scratched) ...[
                Text(
                  'Next scratch card available in:',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                CountdownTimer(duration: scratchCardState.timeLeft),
              ] else ...[
                GestureDetector(
                  onTap: () {
                    scratchCardState.showCouponDialog(context);
                  },
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    shadowColor: Colors.grey.withOpacity(0.5),
                    child: Container(
                      height: 220,
                      width: 320,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.purple, Colors.deepPurple],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/lucky-bag.png', width: 80),
                            SizedBox(height: 10),
                            Text(
                              'Scratch to Reveal',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 30),
              Text(
                'Scratch Card History',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: scratchCardState.scratchCardRecords.length,
                  itemBuilder: (context, index) {
                    var record = scratchCardState.scratchCardRecords[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey.shade300],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/money-bag.png', width: 60),
                              SizedBox(height: 10),
                              Center(
                                child: Text(
                                  'You won ${record['earnPoints']} Points',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ScratchCardState extends ChangeNotifier {
  final List<int> points = [0, 1, 2, 3, 4, 5];
  bool scratched = false;
  DateTime? lastScratchedTime;
  Timer? timer;
  Duration timeLeft = Duration.zero;
  List<Map<String, dynamic>> scratchCardRecords = [];

  ScratchCardState() {
    _loadScratchData();
    _startTimer();
    _fetchScratchCardRecords();
  }

  void _loadScratchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    scratched = prefs.getBool('scratched') ?? false;
    int? lastScratchedTimestamp = prefs.getInt('lastScratchedTime');
    if (lastScratchedTimestamp != null) {
      lastScratchedTime = DateTime.fromMillisecondsSinceEpoch(lastScratchedTimestamp);
      _updateTimeLeft();
    }
  }

  void _saveScratchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('scratched', scratched);
    if (lastScratchedTime != null) {
      prefs.setInt('lastScratchedTime', lastScratchedTime!.millisecondsSinceEpoch);
    }
  }

  void _updateTimeLeft() {
    if (lastScratchedTime != null) {
      final now = DateTime.now();
      final elapsed = now.difference(lastScratchedTime!);
      if (elapsed >= Duration(minutes: 30)) {
        timeLeft = Duration.zero;
        scratched = false;
      } else {
        timeLeft = Duration(minutes: 30) - elapsed;
      }
    }
    notifyListeners();
  }

  void _startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      _updateTimeLeft();
    });
  }

  void showCouponDialog(BuildContext context) {
    if (!scratched && timeLeft == Duration.zero) {
      final now = DateTime.now();
      Random random = Random();
      int reward = points[random.nextInt(points.length)];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Scratcher(
              brushSize: 50,
              threshold: 50,
              color: Colors.yellow[900]!,
              onThreshold: () async {
                scratched = true;
                lastScratchedTime = now;
                _saveScratchData();
                _startTimer();
                Navigator.of(context).pop();

                SharedPreferences prefs = await SharedPreferences.getInstance();
                int currentPoints = prefs.getInt('points') ?? 0;
                print(currentPoints.toString());

                if (reward > 0) {
                  currentPoints += reward;
                  prefs.setInt('points', currentPoints);
                  String userId = FirebaseAuth.instance.currentUser!.uid;

                  DocumentReference<Map<String, dynamic>> userRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId);
                  await userRef.update({
                    'points': FieldValue.increment(currentPoints),
                  });

                  DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userRef.get();
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('transactions')
                      .add({
                    'date': Timestamp.now(),
                    'type': 'Scratch',
                    'earnPoints': reward,
                    'redeemPoints': 0,
                    'balancePoints': userSnapshot.data()!['points'],
                  });

                  _fetchScratchCardRecords();
                }

                notifyListeners();
              },
              child: Container(
                height: 200,
                width: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: reward == 0
                      ? Text(
                    'Better luck next time!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  )
                      : Text(
                    'You won $reward points!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      print('Cannot scratch yet');
    }
  }


  void _fetchScratchCardRecords() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('type', isEqualTo:'Scratch')
        .get();

    scratchCardRecords = querySnapshot.docs.map((doc) => doc.data()).toList();
    notifyListeners();
  }
}

class CountdownTimer extends StatelessWidget {
  final Duration duration;

  CountdownTimer({required this.duration});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScratchCardState>(
      builder: (context, scratchCardState, _) {
        return Text(
          '${scratchCardState.timeLeft.inHours.toString().padLeft(2, '0')}:${(scratchCardState.timeLeft.inMinutes % 60).toString().padLeft(2, '0')}:${(scratchCardState.timeLeft.inSeconds % 60).toString().padLeft(2, '0')}',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple),
        );
      },
    );
  }
}
