import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../res/color_constant.dart';
import '../../res/text_context.dart';
import '../account/account_screen.dart';
import '../category/category_screen.dart';
import '../order/order_list_screen.dart';
import 'bottombar_screen.dart';
import '../cart/cart_screen.dart';
import '../home/home_screen.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/cart_viewmodel.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  //  replace with your real cart count (from provider/bloc/state mgmt)
  int _cartCount = 2;

  // tracks the last time back was pressed while on the Home tab
  DateTime? _lastBackPressTime;

  // controls the custom "press again to exit" toast
  bool _showExitToast = false;
  Timer? _toastTimer;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoryScreen(),
    const CartScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  void _onTabTap(int index) {
    setState(() => _currentIndex = index);
  }

  /// Shows the custom exit toast for 2 seconds, then auto-hides it.
  void _triggerExitToast() {
    _toastTimer?.cancel();
    setState(() => _showExitToast = true);
    _toastTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _showExitToast = false);
    });
  }

  /// Handles every system/gesture back press for the whole tab shell.
  Future<void> _handleBackPress() async {
    // 1) Not on Home tab → just switch back to Home, don't exit anything.
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return;
    }

    // 2) On Home tab → require a second back press within 2 seconds to exit.
    final now = DateTime.now();
    final isFirstPressOrExpired = _lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2);

    if (isFirstPressOrExpired) {
      _lastBackPressTime = now;
      _triggerExitToast();
      return;
    }

    // 3) Second press within the window → actually exit the app.
    SystemNavigator.pop();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartViewModel>().fetchCart();
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartViewModel>().itemCount;   // <-- real count

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: ColorConstant.scaffoldBgColor,
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),

            // ---------------- CUSTOM EXIT TOAST ----------------
            _ExitToast(visible: _showExitToast),
          ],
        ),
        bottomNavigationBar: AnimatedNotchBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabTap,
          cartCount: cartCount,
        ),
      ),
    );
  }
}

/// ---------------- CUSTOM EXIT TOAST WIDGET ----------------
/// Small floating pill with the app logo + message, shown above the
/// bottom nav bar when the user presses back once on the Home tab.
class _ExitToast extends StatelessWidget {
  final bool visible;

  const _ExitToast({required this.visible});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      left: size.width * 0.08,
      right: size.width * 0.08,
      bottom: size.height * 0.03,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          child: AnimatedSlide(
            offset: visible ? Offset.zero : const Offset(0, 0.3),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: ColorConstant.headlineTextColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: ColorConstant.blackColor.withOpacity(.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/shopzolo.png',
                      height: 18,
                      width: 18,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.shopping_bag_rounded,
                        size: 18,
                        color: ColorConstant.orangeColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: TextContext(
                      text: 'Press back again to exit Shopzo',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.whiteColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}