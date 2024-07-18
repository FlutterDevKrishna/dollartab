import 'package:flutter/material.dart';
class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Image.asset(
            'assets/images/topright.png',
            width: 250,
            height: 250,
            alignment: Alignment.topRight,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Image.asset(
            'assets/images/bottomleft.png',
            width: 250,
            height: 250,
            alignment: Alignment.bottomLeft,
          ),
        ),
      ],
    );
  }
}
