import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'ProviderSection/ProductDetailModel.dart';
import 'ProviderSection/AdvertisementProvider.dart';
import 'ProviderSection/PromotionProvider.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:userdollartab/HomeScreen/Home.dart';
import 'package:userdollartab/SplashScreen/SplashScreen.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(); // Declare the variable here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/logo');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductDetailModel()),
        ChangeNotifierProvider(create: (context) => AdvertisementProvider()),
        ChangeNotifierProvider(create: (context) => PromotionProvider()),
      ],
      child: MyApp(),
    ),
  );

  // Listen to changes in the 'users' collection
  FirebaseFirestore.instance.collection('users').snapshots().listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        var userData = change.doc.data();
        var userName = userData?['name']; // Assuming 'name' is the field in your document
        _showNotification('New User Signed Up', 'A new user has signed up: $userName');
      }
    }
  });

  // Listen to changes in the 'notifications' collection
  FirebaseFirestore.instance.collection('notifications').snapshots().listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        var notificationData = change.doc.data();
        var notificationTitle = notificationData?['title']; // Assuming 'title' is the field in your document
        var notificationBody = notificationData?['body']; // Assuming 'body' is the field in your document
        _showNotification(notificationTitle ?? 'New Notification', notificationBody ?? 'You have a new notification.');
      }
    }
  });

  // Listen to changes in the 'productRedeem' collection
  FirebaseFirestore.instance.collection('productRedeem').snapshots().listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        var redeemData = change.doc.data();
        var redeemPoints = redeemData?['redeemPoints']; // Assuming 'redeemPoints' is the field in your document
        _showNotification('New Product Redeem', 'Points Redeemed: $redeemPoints');
      }
    }
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

Future<void> _showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
      'new_user_alert', // Channel ID
      'Dollar Tab', // Channel name
      channelDescription: 'New user and notification alerts', // Channel description
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      color: Colors.blue,
      largeIcon: DrawableResourceAndroidBitmap('@drawable/large_icon'),
      styleInformation: BigTextStyleInformation(''));

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, title, body, platformChannelSpecifics,
      payload: 'item x');
}
