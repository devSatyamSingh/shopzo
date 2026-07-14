import 'package:flutter/material.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: const SafeArea(
        child: Center(
          child: TextContext(
            text: "Shopzo Home — Ban Jayega Bhaiya",
            fontSize: 15,
            color: ColorConstant.labelTextColor,
          ),
        ),
      ),
    );
  }
}
