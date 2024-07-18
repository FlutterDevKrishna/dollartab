import 'package:userdollartab/constants.dart';
import 'package:flutter/material.dart';
import '../SplashScreen/components/Body.dart';
import 'Signin.dart';
import 'Signup.dart';
import 'package:firebase_auth/firebase_auth.dart';



class UserScreen extends StatelessWidget {
  static String routeName = "/user";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: UserPage(),
    );
  }
}

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _isFirstActive = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _setFirstActive() {
    setState(() {
      _isFirstActive = true;
    });
  }

  void _setSecondActive() {
    setState(() {
      _isFirstActive = false;
    });
  }







  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Body(),
        Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Welcome',
                            style: TextStyle(
                              color: AppColors.primaryTextColor,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Sign in to earn points and redeem gifts',
                            style: TextStyle(
                              color: AppColors.primaryTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 300,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: _isFirstActive ? null : _setFirstActive,
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _isFirstActive
                                    ? AppColors.yellow900
                                    : Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(width: 30),
                          TextButton(
                            onPressed: _isFirstActive ? _setSecondActive : null,
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _isFirstActive
                                    ? Colors.white
                                    : AppColors.yellow900,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _isFirstActive ? Signin() : Signup(),

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
