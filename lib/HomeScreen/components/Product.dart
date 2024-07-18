import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:userdollartab/HomeScreen/components/productSection/ProductDetails.dart';
import 'package:flutter/material.dart';
import '../../components/ProductCart.dart';

class Product extends StatefulWidget {
  const Product({Key? key}) : super(key: key);

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('Error fetching products: ${snapshot.error}');
              return Center(child: Text('Error fetching products',style: TextStyle(color: Colors.white),));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final products = snapshot.data?.docs ?? [];

            return GridView.builder(
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of items per row
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.75, // Adjust the aspect ratio as needed
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                final imageUrl = product['imageUrl'] ;
                final productName = product['title'] ;
                final points = product['points'] ?? 0;

                return ProductCard(
                  imageUrl: imageUrl,
                  productName: productName,
                  points: points,
                  productId: product.id,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
