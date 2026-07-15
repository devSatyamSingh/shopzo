import 'package:flutter/material.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';

class TopCategoryItem {
  final IconData icon;
  final String label;

  const TopCategoryItem({required this.icon, required this.label});
}

class CategoryIconsSection extends StatefulWidget {
  final ValueChanged<int>? onSelected;

  const CategoryIconsSection({super.key, this.onSelected});

  @override
  State<CategoryIconsSection> createState() => _CategoryIconsSectionState();
}

class _CategoryIconsSectionState extends State<CategoryIconsSection> {
  int _selectedIndex = 0;

  static const List<TopCategoryItem> _items = [
    TopCategoryItem(icon: Icons.devices_rounded, label: 'Electronics'),
    TopCategoryItem(icon: Icons.checkroom_rounded, label: 'Fashion'),
    TopCategoryItem(icon: Icons.chair_alt_rounded, label: 'Home'),
    TopCategoryItem(icon: Icons.spa_rounded, label: 'Beauty'),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleSize = size.width * 0.15;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.015,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_items.length, (index) {
          final bool isActive = index == _selectedIndex;
          final item = _items[index];

          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = index);
              widget.onSelected?.call(index);
            },
            child: Column(
              children: [
                Container(
                  height: circleSize,
                  width: circleSize,
                  decoration: BoxDecoration(
                    color: isActive
                        ? ColorConstant.primaryLight
                        : ColorConstant.fieldFillColor,
                    shape: BoxShape.circle,
                    border: isActive
                        ? Border.all(color: ColorConstant.primaryColor, width: 1.6)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    item.icon,
                    size: circleSize * 0.42,
                    color: isActive
                        ? ColorConstant.primaryColor
                        : ColorConstant.labelTextColor,
                  ),
                ),
                SizedBox(height: size.height * 0.007),
                TextContext(
                  text: item.label,
                  fontSize: 11.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? ColorConstant.primaryColor
                      : ColorConstant.labelTextColor,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}