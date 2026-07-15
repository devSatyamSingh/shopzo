import 'package:flutter/material.dart';
import '../res/color_constant.dart';
import '../res/text_context.dart';

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Shopzo — custom bottom navigation bar.
/// Floating pill-style active tab, cart badge support, fully responsive.
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartCount;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
  });

  static const List<BottomNavItem> _items = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    BottomNavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Categories',
    ),
    BottomNavItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      label: 'Cart',
    ),
    BottomNavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Orders',
    ),
    BottomNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.only(
        left: size.width * 0.025,
        right: size.width * 0.025,
        top: size.height * 0.01,
        bottom: size.height * 0.012,
      ),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.blackColor.withOpacity(.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_items.length, (index) {
            final bool isActive = index == currentIndex;
            final bool isCart = index == 2;

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  margin: EdgeInsets.symmetric(horizontal: size.width * 0.008),
                  padding: EdgeInsets.symmetric(
                    vertical: size.height * 0.009,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? ColorConstant.primaryColor.withOpacity(.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            isActive ? _items[index].activeIcon : _items[index].icon,
                            size: 24,
                            color: isActive
                                ? ColorConstant.primaryColor
                                : ColorConstant.placeholderColor,
                          ),
                          if (isCart && cartCount > 0)
                            Positioned(
                              top: -6,
                              right: -10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                constraints: const BoxConstraints(minWidth: 16),
                                decoration: BoxDecoration(
                                  color: ColorConstant.orangeColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: ColorConstant.whiteColor,
                                    width: 1.4,
                                  ),
                                ),
                                child: Text(
                                  cartCount > 9 ? '9+' : '$cartCount',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.004),
                      TextContext(
                        text: _items[index].label,
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? ColorConstant.primaryColor
                            : ColorConstant.placeholderColor,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}