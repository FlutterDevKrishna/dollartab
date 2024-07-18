import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scratcher/scratcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class CouponsDetails extends StatefulWidget {
  const CouponsDetails({Key? key}) : super(key: key);

  @override
  State<CouponsDetails> createState() => _CouponsDetailsState();
}

class _CouponsDetailsState extends State<CouponsDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text('Coupon', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: CouponScreen(),
    );
  }
}

class CouponScreen extends StatefulWidget {
  @override
  _CouponScreenState createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  List<DocumentSnapshot> coupons = [];
  List<bool> scratchedCoupons = [];
  int scratchedCount = 0;
  DateTime? lastScratchedTime;

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('coupons')
        .orderBy('timestamp', descending: true)
        .limit(10) // Adjust the limit as needed
        .get();

    List<DocumentSnapshot> fetchedCoupons = querySnapshot.docs;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? scratchedStatusList = prefs.getStringList('scratchedStatus');

    if (scratchedStatusList == null || scratchedStatusList.length != fetchedCoupons.length) {
      scratchedStatusList = List.generate(fetchedCoupons.length, (_) => 'false');
    }

    setState(() {
      coupons = fetchedCoupons;
      scratchedCoupons = (scratchedStatusList ?? []).map((status) => status == 'true').toList();
    });
  }

  void _saveScratchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> scratchedStatusList = scratchedCoupons.map((isScratched) => isScratched.toString()).toList();
    await prefs.setStringList('scratchedStatus', scratchedStatusList);
  }

  void _showCouponDialog(int index) {
    if (!scratchedCoupons[index]) {
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
              onThreshold: () {
                setState(() {
                  scratchedCoupons[index] = true;
                  scratchedCount++;
                  _saveScratchData();
                });
                Navigator.of(context).pop();
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
                  child: Text(
                    coupons[index]['code'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return coupons.isNotEmpty
        ? GridView.builder(
      padding: EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1,
      ),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showCouponDialog(index),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            shadowColor: Colors.grey.withOpacity(0.5),
            child: Center(
              child: scratchedCoupons[index]
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(coupons[index]['imageUrl'], width: 80),
                  SizedBox(height: 10),
                  Text(
                    coupons[index]['code'],
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    coupons[index]['title'],
                    style: TextStyle(
                        fontSize: 16, color: Colors.black54),
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/gift-card.png', width: 80),
                  SizedBox(height: 10),
                  Text(
                    'Scratch to Reveal',
                    style: TextStyle(
                        fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    )
        : Center(
      child: CircularProgressIndicator(),
    );
  }
}
