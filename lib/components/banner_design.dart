import 'package:flutter/material.dart';
import 'package:userdollartab/constants.dart';

class BannerPage extends StatelessWidget {
  final Color boxColor;
  final String image;
  final String text;
  final String text2;
  final String buttonText;
  final VoidCallback onPressed;

  const BannerPage({
    Key? key,
    required this.boxColor,
    required this.image,
    required this.text,
    required this.text2,
    required this.buttonText,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          image.isNotEmpty
              ? Image.asset(image)
              : SizedBox.shrink(),
          SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            text2,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow900
              ),
              onPressed: onPressed,
              child: Text(buttonText,style: TextStyle(color: Colors.black),),
            ),
          ),
        ],
      ),
    );
  }
}

