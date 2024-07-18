import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:userdollartab/HomeScreen/bannerSection/ViewPromotions.dart';
import 'package:userdollartab/HomeScreen/components/Account.dart';
import 'package:userdollartab/HomeScreen/components/Advertisement.dart';
import 'package:userdollartab/HomeScreen/components/HomePage.dart';
import 'package:userdollartab/HomeScreen/components/MyPoints.dart';
import 'package:userdollartab/HomeScreen/components/Product.dart';
import 'package:userdollartab/constants.dart';

// Make sure SupportPage is imported from the correct location
import 'Notifications.dart';
import 'components/FloatingWheelSection/SpinWheelSection.dart';
import 'components/customerSupport.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>  with TickerProviderStateMixin{
  int _selectedIndex = 0;
  late AnimationController _animationController;
  List<String> titles = [
    'Home Page',
    'Advertisement',
    'Products',
    'My Points',
    'My Account'
  ];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
    _setupListeners();
  }
  //notification Section logic
  void _setupListeners() {

    final DateTime now = DateTime.now();
    final DateTime last24Hours = now.subtract(Duration(hours: 24));

    _firestore
        .collection('users')
        .where('date', isGreaterThanOrEqualTo: last24Hours)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _notificationCount = snapshot.docs.length;
      });
    });

  }

  void _resetNotificationCount() {
    setState(() {
      _notificationCount = 0;
    });
  }

  void _navigateToAdvertisementPage() {
    _resetNotificationCount();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Notifications()),
    );
  }


  List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    Advertisement(),
    Product(),
    MyPoints(),
    Account(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.black, // Set the background color of the navigation bar
      ),
      child: Scaffold(
        appBar: _selectedIndex == 0
            ? AppBar(
          backgroundColor: AppColors.primaryColor,
          leading: Container(),
          actions: [
            Spacer(),
            InkWell(

              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 4.0),
                child: Material(
                  elevation: 4,
                  shape: CircleBorder(
                    side: BorderSide(
                      color: AppColors.yellow900,
                      width: 1, // Adjust the width as needed
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  color: AppColors.yellow900,
                  child: Ink(
                    decoration: ShapeDecoration(
                      color: AppColors.primaryColor,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.share_rounded,color: Colors.white,),
                      color: Colors.white,
                      onPressed: () {
                        // Add functionality for icon press
                        Share.share(
                            'Check out this amazing app: https://play.google.com/store/apps/details?id=in.gov.bhaskar.negd.g2c&pcampaignid=web_share');
                      },
                    ),
                  ),
                )
              ),
            ),
            Spacer(flex: 8,),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SupportPage()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 4.0),
                child:Material(
                  elevation: 4,
                  shape: CircleBorder(
                    side: BorderSide(
                      color: AppColors.yellow900,
                      width: 1, // Adjust the width as needed
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  color: AppColors.yellow900,
                  child: Ink(
                    decoration: ShapeDecoration(
                      color: AppColors.primaryColor,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.support_agent,color: Colors.white,),
                      color: Colors.white,
                      onPressed: () {
                        // Add functionality for icon press
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SupportPage(),));
                      },
                    ),
                  ),
                )
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                // Add functionality for notifications button
                _navigateToAdvertisementPage();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                child: Stack(
                  children: [
                    Material(
                      elevation: 4,
                      shape: CircleBorder(
                        side: BorderSide(
                          color: AppColors.yellow900,
                          width: 1, // Adjust the width as needed
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      color: AppColors.yellow900,
                      child: IconButton(
                        icon: Icon(Icons.notifications, color: Colors.white),
                        onPressed: () {
                          // Add functionality for icon press
                          _navigateToAdvertisementPage();
                        },
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            _notificationCount.toString(), // Replace '3' with your actual notification count
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 20,),
          ],
        )
            : AppBar(
          backgroundColor: Colors.black,
          leading: Container(),
          actions: [
            Spacer(flex: 2,),
            Text(
              titles[_selectedIndex],
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 20,
                fontFamily: 'Roboto',
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                // Add functionality for notifications button
                _navigateToAdvertisementPage();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                child: Stack(
                  children: [
                    Material(
                      elevation: 4,
                      shape: CircleBorder(
                        side: BorderSide(
                          color: AppColors.yellow900,
                          width: 1, // Adjust the width as needed
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      color: AppColors.yellow900,
                      child: IconButton(
                        icon: Icon(Icons.notifications, color: Colors.white),
                        onPressed: () {
                          // Add functionality for icon press
                        },
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            _notificationCount.toString(), // Replace '3' with your actual notification count
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 20,),


          ],
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign),
              label: 'Advertisement',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on),
              label: 'My Points',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'My Account',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.white70,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w300),
          backgroundColor: Colors.black,
        ),

      //  Floating action Button
        floatingActionButton: RotationTransition(
          turns: _animationController,
          child: Container(
            width: 60.0, // Set width
            height: 60.0, // Set height
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00B4DB), // Light Blue
                  Color(0xFF0083B0), // Dark Blue
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                // Add onPressed functionality
                Navigator.push(context, MaterialPageRoute(builder: (context) => FortuneWheelPage(),));
              },
              elevation: 0.0, // Remove FloatingActionButton's default elevation
              child: Image.asset('assets/images/spinning-wheel.png'),
              backgroundColor: Colors.transparent, // Set background color to transparent
            ),
          ),

      ),
      ),
    );
  }


}
