import 'dart:async';

import 'package:flutter/material.dart';
import 'package:userdollartab/SplashScreen/components/Body.dart';
import 'package:userdollartab/Users/Signin.dart';
import 'package:userdollartab/constants.dart';

import '../Users/Users.dart';
import 'components/SplashContent.dart';

class SliderScreen extends StatefulWidget {
  const SliderScreen({Key? key}) : super(key: key);

  @override
  State<SliderScreen> createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  int currentPage = 0;
  late PageController pageController;
  late Timer _timer;
  List<Map<String, String>> splashData = [
    {
      "text": "Earn points & redeem gifts.",
      "text2": "Utilize your spare time.",
      "text3": "Earn Points.",
      "text4": "Redeem Products.",
      "image": "assets/images/clock.png",
      "image2": "assets/images/points.png",
      "image3": "assets/images/box.png"
    },
    {
      "text": "Dollar tab at your fingertips",
      "text2": "FAQ for easy operation",
      "text3": "Feedback & Message",
      "text4": "Message us for any problem",
      "image": "assets/images/faq.png",
      "image2": "assets/images/feedback.png",
      "image3": "assets/images/smartphone.png"
    },
    {
      "text": "Best Value of your time and efforts to avail goodies ",
      "text0": "Dollar Tab a gift for you",
      "text2": "Collection of product at your fingertips",
      "text3": "Simple participation and earn point to redeem ",
      "text4": "Win bumper Prizes",
      "image": "assets/images/hand-gesture.png",
      "image2": "assets/images/refer.png",
      "image3": "assets/images/jackpot.png"
    }
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentPage);

    // Set up a timer to auto-slide pages every 3 seconds
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (currentPage < splashData.length - 1) {
        currentPage++;
      } else {
        currentPage = 0;
      }
      pageController.animateToPage(
        currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(seconds: 3),
        color: AppColors.primaryColor, // Change the color to match your theme
        child:Stack(
          fit: StackFit.expand,

          children: [
            Body(),
      SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (value) {
                      setState(() {
                        currentPage = value;
                      });
                    },
                    itemCount: splashData.length,
                    itemBuilder: (context, index) => SplashContent(
                      text: splashData[index]['text'],
                      text2: splashData[index]['text2'],
                      text3: splashData[index]['text3'],
                      text4: splashData[index]['text4'],
                      image: splashData[index]["image"],
                      image2: splashData[index]["image2"],
                      image3: splashData[index]["image3"],
                    ),
                  ),
                ),
                SizedBox(height: 20), // Added spacing between PageView and indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    splashData.length,
                        (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      height: 6,
                      width: currentPage == index ? 20 : 6,
                      decoration: BoxDecoration(
                        color: currentPage == index ? AppColors.accentColor : Color(0xFFD8D8D8),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20), // Added spacing between indicators and button

                // Added spacing below the button
              ],
            ),
            Positioned(
              top: 20.0,
              right: 20.0,
              child: GestureDetector(
                onTap: () {
                  // Navigate to the signin screen
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserScreen()));
                },
                child: Text(
                  "Skip",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
          ],
        ),
      ),
    );
  }
}
