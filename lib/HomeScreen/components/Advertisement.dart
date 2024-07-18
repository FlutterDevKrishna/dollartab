import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';

import '../../ProviderSection/AdvertisementProvider.dart';
import '../../constants.dart';

class Advertisement extends StatelessWidget {
  const Advertisement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('advertisements')
              .snapshots()
              .map((snapshot) =>
              snapshot.docs.map((doc) =>
              {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }).toList()
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(color: Colors.yellow[900]);
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return  Center(
                child: Container(
                  width: 300,
                  height:300,
                  child: Image.asset('assets/images/page-not-found.png'),
                ),
              );
            } else {
              return ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(8.0)),
                          child: Image.network(
                            item['imageUrl'] as String? ??
                                'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                            height: 350.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String? ?? 'No title',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Provider.of<AdvertisementProvider>(
                                              context, listen: false)
                                              .updateCounter(
                                              context, item['id'] as String,
                                              'like');
                                        },
                                        icon: Icon(Icons.thumb_up,
                                            color: Colors.white),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '${item['likeCount'] ?? 0}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Provider.of<AdvertisementProvider>(
                                              context, listen: false)
                                              .updateCounter(
                                              context, item['id'] as String,
                                              'view');
                                        },
                                        icon: Icon(Icons.visibility,
                                            color: Colors.white),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '${item['viewCount'] ?? 0}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Provider.of<AdvertisementProvider>(
                                              context, listen: false)
                                              .updateCounter(
                                              context, item['id'] as String,
                                              'share');
                                          Share.share(
                                              'Check out this advertisement: ${item['title']}\n\n${item['description']}');
                                        },
                                        icon: Icon(
                                            Icons.share, color: Colors.white),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '${item['shareCount'] ?? 0}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

