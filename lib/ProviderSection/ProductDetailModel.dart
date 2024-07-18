import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';

class ProductDetailModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  bool isButtonEnabled = false;
  bool showConfetti = false;
  bool showinsuffcientbal=false;
  final ConfettiController confettiController = ConfettiController(duration: const Duration(seconds: 2));

  Future<void> fetchProductDetails(String productId) async {
    // Fetch product details logic
    isLoading = false;
    showinsuffcientbal=false;
    notifyListeners();
  }

  Future<void> redeemProduct( BuildContext context,String productId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String referralCode= userData['referralCode'];
       if(await countUsersWithInviteCode(referralCode)>=2)
       {
         // logic to redeem product
         try{
           String userId = FirebaseAuth.instance.currentUser!.uid;
           // Fetch the product details
           DocumentSnapshot productDoc = await FirebaseFirestore.instance
               .collection('products')
               .doc(productId)
               .get();
           int productPoints = productDoc['points'];

           // Fetch the user's points from Firestore
           DocumentSnapshot userDoc = await FirebaseFirestore.instance
               .collection('users')
               .doc(userId)
               .get();
           int userPoints = userDoc['points'];

           if (userPoints >= productPoints) {
             // Subtract the product points from user points
             int updatedPoints = userPoints  - productPoints;

             // Update Firestore with the new points
             await FirebaseFirestore.instance
                 .collection('users')
                 .doc(userId)
                 .update({'points': updatedPoints});

             // Save the transaction details
             await FirebaseFirestore.instance
                 .collection('productRedeem')
                 .add({
               'date': Timestamp.now(),
               'redeemPoints': productPoints,
               'earnPoints': 0,
               'type': 'Redeemed',
               'balancePoints': updatedPoints,
             });


             //saving redeem product details
             await FirebaseFirestore.instance
                 .collection('users')
                 .doc(userId)
                 .collection('transactions')
                 .add({
               'date': Timestamp.now(),
               'productId': productId,
               'userId': userId,
               'type':'Redeemed',
               'ProductPoints': productPoints,
             });

             isButtonEnabled = false;
             notifyListeners();

           }}catch(e){

         }
         // Redeem product logic
         showConfetti = true;
         confettiController.play();
         notifyListeners();
         Future.delayed(const Duration(seconds: 10), () {
           showConfetti = false;
           confettiController.stop();
           notifyListeners();
         });
       }
       else{
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('You need 2 people in your netwoork to redeem this product')),
         );
       }


      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error getting user data: $e');
    }


  }

  //count number of users
  Future<int> countUsersWithInviteCode(String inviteCode) async {
    int userCount = 0;

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('inviteCode', isEqualTo: inviteCode)
          .get();

      userCount = querySnapshot.docs.length;
    } catch (e) {
      print('Error getting users: $e');
    }

    return userCount;
  }
  void showInsufficientBalancePopup() {
    // Trigger the popup showing insufficient balance
    notifyListeners();
  }

  Future<void> checkUserPoints(String productId) async {

    try {
      // Assuming current user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated");

      // Fetch user points from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userPoints = userDoc['points'];

      // Fetch product points requirement from Firestore
      final productDoc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
      final productPoints = productDoc['points'];

      // Check if user has enough points
      if (userPoints >= productPoints) {
        isButtonEnabled = true;
      } else {
        isButtonEnabled = false;
        showinsuffcientbal=true;
        showInsufficientBalancePopup();
        notifyListeners();
      }
    } catch (e) {
      print("Error checking user points: $e");
      isButtonEnabled = false;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }
}
