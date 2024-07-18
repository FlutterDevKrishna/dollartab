import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../ProviderSection/ProductDetailModel.dart';
import '../../../constants.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<ProductDetailModel>(context, listen: false)
        .fetchProductDetails(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailModel>(
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: AppColors.primaryColor,
          appBar: AppBar(
            title: Text('Product Details', style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.primaryColor,
            iconTheme: IconThemeData(color: Colors.white),
            centerTitle: true,
          ),
          body: Stack(
            children: [
             FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.productId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: TextStyle(color: Colors.red)));
                  }

                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return Center(child: CircularProgressIndicator());
                  // }

                  final product = snapshot.data;

                  if (product == null) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          Container(
                            width: double.infinity,
                            height: 240,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              image: DecorationImage(
                                image: NetworkImage(product['imageUrl']),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          // Product Name
                          Text(
                            '${product['title']}',
                            style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          // Product Points
                          Row(
                            children: [
                              Text(
                                'Points: ',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                              ),
                              Text(
                                '${product['points']}',
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellowAccent,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          // Product Details
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Product Details',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '${product['description']}',
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          // Redeem Button
                          Center(
                            child: ElevatedButton(
                              onPressed: model.isButtonEnabled
                                  ? () {
                                model.redeemProduct(context,widget.productId);
                              }
                                  : () {
                                model.checkUserPoints(widget.productId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: model.isButtonEnabled
                                    ? AppColors.yellow900
                                    : Colors.grey,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 32.0, vertical: 12.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Text(
                                model.isButtonEnabled ? 'Redeem' : 'Check Points',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Additional Information
                          // Add more information or buttons as needed

                        ],
                      ),
                    ),
                  );
                },
              ),
              if (model.showConfetti)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: model.confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      maxBlastForce: 10, // Increase blast force
                      minBlastForce: 5, // Decrease minimum blast force
                      emissionFrequency: 0.03, // Decrease emission frequency
                      numberOfParticles: 20, // Decrease number of particles
                      gravity: 0.1, // Add gravity effect
                      colors: const [
                        Colors.red,
                        Colors.blue,
                        Colors.green,
                        Colors.yellow,
                        Colors.orange,
                        Colors.pink,
                        Colors.purple,
                      ],
                      createParticlePath: _drawStar,
                    ),
                  ),
                ),
              if (model.showinsuffcientbal) _showInsufficientBalancePopup(context),
            ],
          ),
        );
      },
    );
  }
  Widget _showInsufficientBalancePopup(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 10),
          Text(
            'Insufficient Balance',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        'You do not have enough points to make this payment.',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            'OK',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.white,
      elevation: 5,
    );
  }

  Path _drawStar(Size size) {
    final path = Path();
    final double outerRadius = size.width / 2;
    final double innerRadius = size.width / 3.5;
    final double rotation = -pi / 2;
    final double step = pi / 5;

    final double startX = size.width / 2 + outerRadius * cos(rotation);
    final double startY = size.height / 2 + outerRadius * sin(rotation);
    path.moveTo(startX, startY);

    for (double i = rotation + step; i < rotation + 2 * pi; i += step) {
      final double outerX = size.width / 2 + outerRadius * cos(i);
      final double outerY = size.height / 2 + outerRadius * sin(i);
      path.lineTo(outerX, outerY);

      final double innerX = size.width / 2 + innerRadius * cos(i + step / 2);
      final double innerY = size.height / 2 + innerRadius * sin(i + step / 2);
      path.lineTo(innerX, innerY);
    }

    path.close();
    return path;
  }
}