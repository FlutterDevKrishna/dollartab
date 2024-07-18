import 'package:userdollartab/constants.dart';
import 'package:flutter/material.dart';

import 'SliderScreen.dart';
import 'components/Body.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SliderScreen()),
      );
    });
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: 180,
                      height: 180,
                      child: Image.asset('assets/images/splash_logo.png'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'All Copyright Reserved',
                      style: TextStyle(
                        color: AppColors.primaryTextColor,
                        fontFamily: 'Montserrat',),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}