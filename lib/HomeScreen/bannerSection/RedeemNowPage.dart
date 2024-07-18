import 'package:flutter/material.dart';
import 'package:userdollartab/HomeScreen/components/Product.dart';

import '../../constants.dart';
class RedeemNowPage extends StatefulWidget {
  const RedeemNowPage({Key? key}) : super(key: key);

  @override
  State<RedeemNowPage> createState() => _RedeemNowPageState();
}

class _RedeemNowPageState extends State<RedeemNowPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text('Redeem Now', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: Product(),
    );
  }
}
