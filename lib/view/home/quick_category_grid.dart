import 'package:flutter/material.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';

class QuickCategoryItem {
  final IconData icon;
  final String label;

  const QuickCategoryItem({required this.icon, required this.label});
}

class QuickCategoryGrid extends StatelessWidget {
  final ValueChanged<int>? onTap;

  const QuickCategoryGrid({super.key, this.onTap});

  static const List<QuickCategoryItem> _items = [
    QuickCategoryItem(icon: Icons.laptop_mac_rounded, label: 'Laptops'),
    QuickCategoryItem(icon: Icons.watch_rounded, label: 'Watches'),
    QuickCategoryItem(icon: Icons.kitchen_rounded, label: 'Kitchen'),
    QuickCategoryItem(icon: Icons.health_and_safety_rounded, label: 'Wellness'),
    QuickCategoryItem(icon: Icons.print_rounded, label: 'Decor'),
    QuickCategoryItem(icon: Icons.shopping_bag_outlined, label: 'Shoes'),
    QuickCategoryItem(icon: Icons.luggage_rounded, label: 'Luggage'),
    QuickCategoryItem(icon: Icons.more_horiz_rounded, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.012,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 14,
          crossAxisSpacing: 4,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) {
          final item = _items[index];
          return GestureDetector(
            onTap: () => onTap?.call(index),
            child: Column(
              children: [
                Container(
                  height: size.width * 0.15,
                  width: size.width * 0.15,
                  decoration: BoxDecoration(
                    color: ColorConstant.fieldFillColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    item.icon,
                    size: size.width * 0.065,
                    color: ColorConstant.primaryColor,
                  ),
                ),
                SizedBox(height: size.height * 0.007),
                TextContext(
                  text: item.label,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.center,
                  color: ColorConstant.bodyTextColor,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}