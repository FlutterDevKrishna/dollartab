import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class AdvertisementProvider extends ChangeNotifier {
  late List<Map<String, dynamic>> _data;
  late Future<List<Map<String, dynamic>>> futureData;

  AdvertisementProvider() {
    futureData = fetchData();
  }

  List<Map<String, dynamic>> get data => _data;

  Future<List<Map<String, dynamic>>> fetchData() async {
    DateTime now = DateTime.now();



    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('advertisements')
        .where('expiryDate', isGreaterThanOrEqualTo: now) // Expiry date is in the future
        .where('startingDate', isLessThanOrEqualTo: now ) // Starting date is in the past
        .get();

    List<Map<String, dynamic>> _data = [];

    // Filter documents based on validity manually
    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      DateTime expiryDate = (data['expiryDate'] as Timestamp).toDate();

      // Check if the advertisement is valid based on starting and expiry dates
      if (expiryDate.isAfter(now)) {
        _data.add({
          ...data,
          'id': doc.id,
        });
      }
    });

    // Notify listeners if you're using a state management solution like Provider
    notifyListeners();

    return _data;
  }

  Future<void> updateCounter(
      BuildContext context, String docId, String type) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference<Map<String, dynamic>> userRef =
    FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userRef.get();

    // Check if the user has status 1
    if (userSnapshot.exists && userSnapshot.data()!['status'] == 1) {
      DocumentReference<Map<String, dynamic>> docRef =
      FirebaseFirestore.instance.collection('advertisements').doc(docId);

      // Check if any user has performed the action on the advertisement
      QuerySnapshot<Map<String, dynamic>> actionSnapshot = await docRef
          .collection(type == 'like'
          ? 'likes'
          : type == 'share'
          ? 'shares'
          : 'views')
          .where('userId', isEqualTo: userId)
          .get();

      if (actionSnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have already ${type}d this advertisement')),
        );
        return;
      }

      // Add the user's action to the subcollection
      await docRef
          .collection(type == 'like' ? 'likes' : type == 'share' ? 'shares' : 'views')
          .add({
        'userId': userId,
      });

      // Update the counter
      await docRef.update({
        type == 'like'
            ? 'likeCount'
            : type == 'share'
            ? 'shareCount'
            : 'viewCount': FieldValue.increment(1),
      });

      // Determine points to be awarded based on action type
      int pointsToAdd = type == 'like' ? 1 : type == 'view' ? 1 : 1;

      // Update the user's points
      await userRef.update({
        'points': FieldValue.increment(pointsToAdd),
      });

      // Get updated user points
      DocumentSnapshot<Map<String, dynamic>> updatedUserSnapshot = await userRef.get();

      // Record the transaction in Firestore
      await userRef.collection('transactions').add({
        'date': Timestamp.now(),
        'type': type,
        'earnPoints': pointsToAdd,
        'redeemPoints': 0,
        'balancePoints': updatedUserSnapshot.data()!['points'], // Use updated user points
      });

      // Update the local data list
      int index = _data.indexWhere((element) => element['id'] == docId);
      if (index != -1) {
        Map<String, dynamic> updatedItem = _data[index];
        updatedItem[type == 'like' ? 'likeCount' : type == 'share' ? 'shareCount' : 'viewCount']++;
        _data[index] = updatedItem;
        notifyListeners();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are not allowed to ${type} this advertisement')),
      );
    }
  }
}
