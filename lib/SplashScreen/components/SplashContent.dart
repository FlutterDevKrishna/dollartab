import 'package:flutter/material.dart';
import 'package:userdollartab/constants.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({
    Key? key,
    this.text,
    this.text2,
    this.text3,
    this.text4,
    this.image,
    this.image2,
    this.image3,
  }) : super(key: key);
  final String? text, text2, text3, text4, image, image2, image3;

  @override
  Widget build(BuildContext context) {
    // Get the screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Adjust font size and image size based on screen dimensions
    double baseFontSize =
        screenWidth * 0.04; // Example scaling factor for text size
    double imageSize =
        screenWidth * 0.15; // Example scaling factor for image size
    double spacing = screenHeight * 0.04; // Example scaling factor for spacing

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 20,),
        Image.asset(
          'assets/images/logo.png',
          height: imageSize * 1.5,
          width: imageSize * 1.5,
        ),
        SizedBox(height: 12,),
        Container(
          width: 300,
          child: Text(
            text!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: baseFontSize + 4, // Adjusted font size for title text
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(height: 20,),
        Divider(
          color: Colors.grey, // Set the color to grey
          thickness: 1, // Set the thickness of the line
          indent: 20, // Optional: set the left indent
          endIndent: 20, // Optional: set the right indent
        ),
        SizedBox(height: 20,),
        Column(
          children: [
            Container(
              width: screenWidth * 0.8,
              // Adjust container width based on screen width
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    image!,
                    height: imageSize,
                    width: imageSize,
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: Text(
                      text2!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryTextColor,
                        fontSize: baseFontSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing),
            Container(
              width: screenWidth * 0.8,
              // Adjust container width based on screen width
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    image2!,
                    height: imageSize,
                    width: imageSize,
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: Text(
                      text3!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryTextColor,
                        fontSize: baseFontSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing),
            Container(
              width: screenWidth * 0.8,
              // Adjust container width based on screen width
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    image3!,
                    height: imageSize,
                    width: imageSize,
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: Text(
                      text4!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryTextColor,
                        fontSize: baseFontSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
