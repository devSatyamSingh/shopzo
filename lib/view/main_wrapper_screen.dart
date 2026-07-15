import 'package:flutter/material.dart';
import '../res/color_constant.dart';
import 'account_screen.dart';
import 'bottombar_screen.dart';
import 'cart/cart_screen.dart';
import 'home/home_screen.dart';


class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // 👉 replace with your real cart count (from provider/bloc/state mgmt)
  int _cartCount = 2;

  final List<Widget> _screens =  [
    HomeScreen(),
    CartScreen(),
    CartScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onTabTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBgColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AnimatedNotchBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
        cartCount: _cartCount,
      ),
    );
  }
}