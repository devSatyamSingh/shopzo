import 'package:flutter/material.dart';
import '../../../res/color_constant.dart';
import '../../../res/text_context.dart';
import '../../../routes/route_name.dart';

class QuickCategoryItem {
  final IconData icon;
  final String label;
  final Color tintColor;

  const QuickCategoryItem({
    required this.icon,
    required this.label,
    this.tintColor = ColorConstant.primaryLight,
  });
}

/// Shopzo — Quick Category shortcuts grid.
/// 👉 once API is wired, replace `_allItems` with the real category
/// list (icon can stay a local mapping/fallback if the API only
/// returns names — see note above `_allItems`).
class QuickCategoryGrid extends StatefulWidget {
  final ValueChanged<int>? onTap;

  const QuickCategoryGrid({super.key, this.onTap});

  @override
  State<QuickCategoryGrid> createState() => _QuickCategoryGridState();
}

class _QuickCategoryGridState extends State<QuickCategoryGrid> {
  bool _expanded = false;

  // how many real categories show before the "More" tile when collapsed
  static const int _collapsedCount = 7;

  // 👉 full category list — API result goes here (drop the trailing
  // "More"/"Hide" logic below stays the same either way)
  static const List<QuickCategoryItem> _allItems = [
    QuickCategoryItem(icon: Icons.laptop_mac_rounded, label: 'Laptops', tintColor: Color(0xFFE9ECF5)),
    QuickCategoryItem(icon: Icons.watch_rounded, label: 'Watches', tintColor: Color(0xFFF3E9E3)),
    QuickCategoryItem(icon: Icons.kitchen_rounded, label: 'Kitchen', tintColor: Color(0xFFF6EFD9)),
    QuickCategoryItem(icon: Icons.health_and_safety_rounded, label: 'Wellness', tintColor: Color(0xFFE6F2E4)),
    QuickCategoryItem(icon: Icons.print_rounded, label: 'Decor', tintColor: Color(0xFFF8E6EC)),
    QuickCategoryItem(icon: Icons.shopping_bag_outlined, label: 'Shoes', tintColor: Color(0xFFE0EEF7)),
    QuickCategoryItem(icon: Icons.luggage_rounded, label: 'Luggage', tintColor: Color(0xFFEFEFEF)),
    QuickCategoryItem(icon: Icons.checkroom_rounded, label: 'Apparel', tintColor: Color(0xFFF3E9E3)),
    QuickCategoryItem(icon: Icons.sports_esports_rounded, label: 'Gaming', tintColor: Color(0xFFE9ECF5)),
    QuickCategoryItem(icon: Icons.toys_rounded, label: 'Toys', tintColor: Color(0xFFF8E6EC)),
    QuickCategoryItem(icon: Icons.pets_rounded, label: 'Pet Care', tintColor: Color(0xFFE6F2E4)),
    QuickCategoryItem(icon: Icons.local_grocery_store_rounded, label: 'Grocery', tintColor: Color(0xFFE6F2E4)),
  ];

  void _onCategoryTap(int index) {
    final item = _allItems[index];
    widget.onTap?.call(index);

    Navigator.pushNamed(
      context,
      RouteName.categoryProducts,
      arguments: {
        'categoryId': item.label,
        'categoryName': item.label,
        'tintColor': item.tintColor,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // how many real category tiles are visible right now
    final visibleCount = _expanded ? _allItems.length : _collapsedCount;
    // +1 slot for the trailing More/Hide toggle tile
    final gridItemCount = visibleCount + 1;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.012,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: gridItemCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 14,
          crossAxisSpacing: 4,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) {
          // ---- last cell: toggle tile ----
          if (index == visibleCount) {
            return _ToggleTile(
              expanded: _expanded,
              onTap: () => setState(() => _expanded = !_expanded),
            );
          }

          // ---- regular category tile ----
          final item = _allItems[index];
          return GestureDetector(
            onTap: () => _onCategoryTap(index),
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

/// ---------------- MORE / HIDE TOGGLE TILE ----------------
class _ToggleTile extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _ToggleTile({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: size.width * 0.15,
            width: size.width * 0.15,
            decoration: BoxDecoration(
              color: ColorConstant.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorConstant.primaryColor.withOpacity(.3)),
            ),
            alignment: Alignment.center,
            child: Icon(
              expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              size: size.width * 0.065,
              color: ColorConstant.primaryColor,
            ),
          ),
          SizedBox(height: size.height * 0.007),
          TextContext(
            text: expanded ? 'Hide' : 'More',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
            color: ColorConstant.primaryColor,
          ),
        ],
      ),
    );
  }
}