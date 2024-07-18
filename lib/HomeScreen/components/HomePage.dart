// home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:userdollartab/HomeScreen/bannerSection/RedeemNowPage.dart';
import 'package:userdollartab/HomeScreen/bannerSection/ScratchPage.dart';
import 'package:userdollartab/components/banner_design.dart';
import '../../constants.dart';

import '../bannerSection/CouponsDetails.dart';
import '../bannerSection/ViewPointDetails.dart';
import '../bannerSection/ViewPromotions.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  String referralCode = '';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchReferralCode();
  }

  Future<void> _fetchUserName() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        userName = userDoc['name'];
      });
    } catch (e) {
      print('Error fetching user name: $e');
      setState(() {
        userName = 'Guest';
      });
    }
  }

  Future<void> _fetchReferralCode() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        referralCode = userDoc['referralCode'];
      });
    } catch (e) {
      print('Error fetching referral code: $e');
      setState(() {
        referralCode = 'N/A';
      });
    }
  }
  //dynamic link
  Future<void> _generateDynamicLink() async {
    Share.share(
        'Check out this amazing app: https://play.google.com/store/apps/details?id=in.gov.bhaskar.negd.g2c&pcampaignid=web_share');
  }

  //Redeem Now Page
  void _redeemNowPage(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => RedeemNowPage(),));
  }

  //view points details
  void _viewPointsDetails(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPointDetails(),));
  }
  //promotional
  void _promotionalDetails(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPromotions(),));
  }
  //coupon
  void _couponDetails(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => CouponsDetails(),));
  }

  //scratch card
  void _scratchcard(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => ScratchPage(),));
  }
  //referral code alert box
  void _showReferralCodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.card_giftcard, color: Colors.yellow[900]),
              SizedBox(width: 10),
              Text(
                'Your Referral Code',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                referralCode.isNotEmpty ? referralCode : 'Loading...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow[900],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Share this code with your friends and earn rewards!',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.yellow[900]),
                overlayColor: MaterialStateProperty.all(Colors.yellow[100]),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: referralCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Referral code copied to clipboard')),
                );
              },
              child: Text(
                'Copy',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.yellow[900]),
                overlayColor: MaterialStateProperty.all(Colors.yellow[100]),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );

      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Hello, ',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                Text(
                  userName.isNotEmpty ? userName : 'Loading...',
                  style: TextStyle(
                    color: AppColors.yellow900,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            SizedBox(height: 20),
            BannerPage(
              boxColor: Colors.yellow[100]!,
              image: 'assets/images/card1_img.png',
              text: 'Get your Referral Id with 10 pts. in just Rs 100',
              text2: "Share your ID with friends and watch your rewards grow. Don't wait, get your Referral ID today and start reaping the benefits!",
              buttonText: 'Get Referral Code',
              onPressed: _showReferralCodeDialog,
            ),
            SizedBox(height: 20),
            BannerPage(
              boxColor: Colors.blue[100]!,
              image: 'assets/images/card2_img.png',
              text: 'Invite Your Friend and Earn Points',
              text2: "With each successful referral, you'll both earn points towards exciting rewards. Start today and enjoy the benefits.",
              buttonText: 'Invite Now',
              onPressed:_generateDynamicLink, // Placeholder callback
            ),
            SizedBox(height: 20),
            BannerPage(
              boxColor: Colors.red[100]!,
              image: 'assets/images/card3_img.png',
              text: 'Redeem Your Points',
              text2: " Choose from a variety of options including discounts, vouchers, and exclusive offers. Start redeeming now",
              buttonText: 'Redeem Now',
              onPressed: _redeemNowPage, // Placeholder callback
            ),
            SizedBox(height: 20),
            BannerPage(
              boxColor: Colors.white!,
              image: '',
              text: 'Get 10 Points on watching advt.,2 pts on sharing,3pts on liking advt',
              text2: 'Earn rewards effortlessly! Start earning rewards today by engaging with our advertisements.',
              buttonText: 'View Point Details',
              onPressed: _viewPointsDetails, // Placeholder callback
            ),
            SizedBox(height: 20),
            BannerPage(
              boxColor: Colors.purple[100]!,
              image: 'assets/images/card5_img.png',
              text: 'Promotions',
              text2: "Explore our promotions for exclusive offers and discounts! Don't miss out on the chance to save big and enjoy great benefits!",
              buttonText: 'Click To View',
              onPressed:_promotionalDetails, // Placeholder callback
            ),
            SizedBox(height: 20),
            BannerPage(
              boxColor: Colors.blueAccent[100]!,
              image: 'assets/images/card6_img.png',
              text: 'Scratch Card',
              text2: "Be part of our journey as we recognize and reward exceptional talent and contributions.",
              buttonText: 'Click To Know',
              onPressed: _scratchcard, // Placeholder callback
            ),
            SizedBox(height: 20),
            BannerPage(
              boxColor: Colors.green[100]!,
              image: 'assets/images/card7_img.png',
              text: 'Coupons',
              text2: "Unlock savings with our coupons! Enjoy discounts on a wide range of products and services.",
              buttonText: 'Click To Get',
              onPressed: _couponDetails, // Placeholder callback
            ),
          ],
        ),
      ),
    );
  }
}




